import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/hospital.dart';
import '../services/location_service.dart';
import '../services/hospital_service.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  List<Hospital> _nearbyHospitals = [];
  bool _isLoading = false;
  bool _isAlertActivated = false;
  String _statusMessage = '';
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.unknown;

  Position? get currentPosition => _currentPosition;
  List<Hospital> get nearbyHospitals => _nearbyHospitals;
  bool get isLoading => _isLoading;
  bool get isAlertActivated => _isAlertActivated;
  String get statusMessage => _statusMessage;
  LocationPermissionStatus get permissionStatus => _permissionStatus;

  final LocationService _locationService = LocationService();
  final HospitalService _hospitalService = HospitalService();

  Future<void> activateEmergencyAlert() async {
    _isAlertActivated = true;
    _isLoading = true;
    _statusMessage = 'Checking location permissions...';
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

      // Search for nearby hospitals
      _nearbyHospitals = await _hospitalService.getNearbyHospitals(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (_nearbyHospitals.isEmpty) {
        _statusMessage = 'No hospitals found nearby. Please try expanding search radius.';
      } else {
        _statusMessage = 'Found ${_nearbyHospitals.length} hospitals nearby';
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
    _statusMessage = '';
    notifyListeners();
  }

  void updateStatusMessage(String message) {
    _statusMessage = message;
    notifyListeners();
  }
}

enum LocationPermissionStatus {
  unknown,
  granted,
  denied,
}
