import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import '../models/hospital.dart';
import '../services/location_service.dart';
import '../services/hospital_service.dart';
import '../models/responder.dart';
import '../services/responder_service.dart';
import '../services/sms_service.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  List<Hospital> _nearbyHospitals = [];
  List<Responder> _nearbyResponders = [];
  bool _isLoading = false;
  bool _isAlertActivated = false;
  String _statusMessage = '';
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.unknown;
  
  // Countdown State
  bool _isCountingDown = false;
  int _countdownSeconds = 5;
  Timer? _countdownTimer;

  Position? get currentPosition => _currentPosition;
  List<Hospital> get nearbyHospitals => _nearbyHospitals;
  List<Responder> get nearbyResponders => _nearbyResponders;
  bool get isLoading => _isLoading;
  bool get isAlertActivated => _isAlertActivated;
  String get statusMessage => _statusMessage;
  LocationPermissionStatus get permissionStatus => _permissionStatus;
  bool get isCountingDown => _isCountingDown;
  int get countdownSeconds => _countdownSeconds;

  final LocationService _locationService = LocationService();
  final HospitalService _hospitalService = HospitalService();
  final ResponderService _responderService = ResponderService();
  final SmsService _smsService = SmsService();

  void cancelCountdown() {
    _countdownTimer?.cancel();
    _isCountingDown = false;
    _statusMessage = 'SOS Cancelled.';
    notifyListeners();
    // After a delay, clear the status message
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isCountingDown && !_isAlertActivated) {
        _statusMessage = '';
        notifyListeners();
      }
    });
  }

  Future<void> activateEmergencyAlert() async {
    if (_isAlertActivated || _isCountingDown) return;

    // Start 5 second countdown
    _isCountingDown = true;
    _countdownSeconds = 5;
    _statusMessage = 'SOS activating in $_countdownSeconds seconds...';
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_countdownSeconds > 1) {
        _countdownSeconds--;
        _statusMessage = 'SOS activating in $_countdownSeconds seconds...';
        notifyListeners();
      } else {
        timer.cancel();
        _isCountingDown = false;
        await _proceedWithEmergencyAlert();
      }
    });
  }

  Future<void> _proceedWithEmergencyAlert() async {
    _isAlertActivated = true;
    _isLoading = true;
    _statusMessage = 'Activating SOS... Checking permissions...';
    notifyListeners();

    try {
      // Check and request permissions
      final hasPermission = await _checkAndRequestPermissions();
      
      if (!hasPermission) {
        _statusMessage = 'Location permission denied. Please enable it in settings.';
        _permissionStatus = LocationPermissionStatus.denied;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _permissionStatus = LocationPermissionStatus.granted;
      _statusMessage = 'Getting your location...';
      notifyListeners();

      // Get current location
      _currentPosition = await _locationService.getCurrentLocation();
      
      if (_currentPosition == null) {
        _statusMessage = 'Unable to get your location. Please try again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _statusMessage = 'Location obtained! Searching for hospitals...';
      notifyListeners();

      // Update responder location in Firebase if applicable
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? profileJson = prefs.getString('user_profile');
        if (profileJson != null) {
          final profile = UserProfile.fromJson(json.decode(profileJson));
          if (profile.role != 'User') {
            await _responderService.updateResponderLocation(
              profile.phoneNumber,
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            );
          }
        }
      } catch (e) {
        // Silently ignore if failing to update own location
        debugPrint('Failed to update own responder location: $e');
      }

      // Search for nearby hospitals and responders
      final hospitalsFuture = _hospitalService.getNearbyHospitals(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      
      final respondersFuture = _responderService.getNearbyResponders(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      final results = await Future.wait([hospitalsFuture, respondersFuture]);
      _nearbyHospitals = results[0] as List<Hospital>;
      _nearbyResponders = results[1] as List<Responder>;

      // Automatically trigger emergency SMS if profile exists
      try {
        _statusMessage = 'Found ${_nearbyHospitals.length} hospitals. Notifying emergency contact...';
        notifyListeners();
        
        final prefs = await SharedPreferences.getInstance();
        final String? profileJson = prefs.getString('user_profile');
        if (profileJson != null) {
          final profile = UserProfile.fromJson(json.decode(profileJson));
          debugPrint('Triggering SMS to ${profile.emergencyContact}');
          await triggerEmergencySms(profile);
          _statusMessage = 'Emergency contact (${profile.name}) notified via Twilio.';
        } else {
          _statusMessage = 'No user profile found. Please complete registration.';
          debugPrint('No user profile found in SharedPreferences.');
        }
      } catch (e) {
        debugPrint('Failed to auto-trigger SMS: $e');
        _statusMessage = 'Failed to notify emergency contact: ${e.toString()}';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    // Check location services
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  void deactivateAlert() {
    _isAlertActivated = false;
    _isLoading = false;
    _currentPosition = null;
    _nearbyHospitals = [];
    _nearbyResponders = [];
    _statusMessage = '';
    notifyListeners();
  }

  void updateStatusMessage(String message) {
    _statusMessage = message;
    notifyListeners();
  }

  Future<void> fetchNearbyDataOnly() async {
    _isLoading = true;
    _statusMessage = 'Fetching your current location...';
    notifyListeners();

    try {
      final hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        _statusMessage = 'Location permission required for nearby search.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _currentPosition = await _locationService.getFastLocation();
      if (_currentPosition == null) {
        _statusMessage = 'Unable to get location.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _statusMessage = 'Searching for nearby help...';
      notifyListeners();

      final hospitalsFuture = _hospitalService.getNearbyHospitals(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      
      final respondersFuture = _responderService.getNearbyResponders(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      final results = await Future.wait([hospitalsFuture, respondersFuture]);
      _nearbyHospitals = results[0] as List<Hospital>;
      _nearbyResponders = results[1] as List<Responder>;

      _statusMessage = 'Found ${_nearbyHospitals.length} hospitals and ${_nearbyResponders.length} responders';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> triggerEmergencySms(UserProfile userProfile) async {
    if (_currentPosition == null) return;
    
    final nearestHospital = _nearbyHospitals.isNotEmpty ? _nearbyHospitals.first : null;
    
    await _smsService.sendEmergencySms(
      contactNumber: userProfile.emergencyContact,
      position: _currentPosition!,
      nearestHospital: nearestHospital,
      name: userProfile.name,
    );
  }
}

enum LocationPermissionStatus {
  unknown,
  granted,
  denied,
}
