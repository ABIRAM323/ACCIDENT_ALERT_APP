import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/responder_service.dart';
import '../services/location_service.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = true;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  UserProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? profileJson = prefs.getString('user_profile');
      
      if (profileJson != null) {
        _userProfile = UserProfile.fromJson(json.decode(profileJson));
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final String profileJson = json.encode(profile.toJson());
      await prefs.setString('user_profile', profileJson);
      
      _userProfile = profile;
      
      // Register with the responder service if not a regular user
      await ResponderService().registerResponder(profile);
      
      // If they are a responder, try to fetch and save their current location
      if (profile.role != 'User') {
        final locationService = LocationService();
        final hasPermission = await locationService.checkPermission();
        if (hasPermission == null || hasPermission.name.contains('denied')) {
           await locationService.requestPermission();
        }
        
        final position = await locationService.getCurrentLocation();
        if (position != null) {
          await ResponderService().updateResponderLocation(
            profile.phoneNumber,
            position.latitude,
            position.longitude,
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
