import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/responder.dart';
import '../models/user_profile.dart';

class ResponderService {
  // Singleton pattern
  static final ResponderService _instance = ResponderService._internal();
  factory ResponderService() => _instance;
  ResponderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // National Emergency Helplines
  static final List<Responder> _nationalHelplines = [
    Responder(
      id: 'helpline_112',
      name: 'National Emergency Helpline',
      role: 'Ambulance + Emergency',
      phoneNumber: '112',
      distance: 0.0,
    ),
    Responder(
      id: 'helpline_108',
      name: 'Emergency Ambulance Service',
      role: 'Ambulance',
      phoneNumber: '108',
      distance: 0.0,
    ),
    Responder(
      id: 'helpline_102',
      name: 'Ambulance Service',
      role: 'Pregnancy & Transport',
      phoneNumber: '102',
      distance: 0.0,
    ),
    Responder(
      id: 'helpline_104',
      name: 'Health Helpline',
      role: 'Medical Advice',
      phoneNumber: '104',
      distance: 0.0,
    ),
    Responder(
      id: 'helpline_1075',
      name: 'National Health Helpline',
      role: 'Public Health Emergency',
      phoneNumber: '1075',
      distance: 0.0,
    ),
    Responder(
      id: 'helpline_1066',
      name: 'Poison Control',
      role: 'Anti-Poison',
      phoneNumber: '1066',
      distance: 0.0,
    ),
  ];

  Future<void> registerResponder(UserProfile profile) async {
    // Always save to users collection
    await _firestore.collection('users').doc(profile.phoneNumber).set(profile.toJson(), SetOptions(merge: true));

    if (profile.role != 'User') {
      await _firestore.collection('responders').doc(profile.phoneNumber).set({
        'name': profile.name,
        'role': profile.role,
        'phoneNumber': profile.phoneNumber,
        'bloodGroup': profile.bloodGroup,
        'emergencyContact': profile.emergencyContact,
      }, SetOptions(merge: true));
    } else {
      await _firestore.collection('responders').doc(profile.phoneNumber).delete().catchError((e) => null);
    }
  }

  Future<void> updateResponderLocation(String phoneNumber, double latitude, double longitude) async {
    await _firestore.collection('responders').doc(phoneNumber).update({
      'latitude': latitude,
      'longitude': longitude,
      'lastUpdated': FieldValue.serverTimestamp(),
    }).catchError((e) => null);
  }

  Future<List<Responder>> getNearbyResponders(double latitude, double longitude) async {
    try {
      final snapshot = await _firestore.collection('responders').get();
      List<Responder> allVolunteers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('latitude') && data.containsKey('longitude')) {
          double destLat = data['latitude'];
          double destLng = data['longitude'];
          
          double distanceInMeters = Geolocator.distanceBetween(
            latitude, longitude, destLat, destLng
          );
          
          double distanceInKm = distanceInMeters / 1000;

          allVolunteers.add(
            Responder(
              id: doc.id,
              name: data['name'] ?? 'Unknown',
              role: data['role'] ?? 'Responder',
              phoneNumber: data['phoneNumber'] ?? '',
              distance: double.parse(distanceInKm.toStringAsFixed(1)),
            ),
          );
        }
      }
      
      // Sort volunteers by distance
      allVolunteers.sort((a, b) => a.distance.compareTo(b.distance));

      // Construct final list: [Nearest Volunteer] -> [Helplines] -> [Rest of Volunteers]
      List<Responder> finalResult = [];
      
      if (allVolunteers.isNotEmpty) {
        finalResult.add(allVolunteers.first); // Nearest one
        finalResult.addAll(_nationalHelplines); // Helplines after the nearest one
        if (allVolunteers.length > 1) {
          finalResult.addAll(allVolunteers.sublist(1)); // Remaining volunteers
        }
      } else {
        // Just show helplines if no volunteers exist
        finalResult.addAll(_nationalHelplines);
      }

      return finalResult;
    } catch (e) {
      print('Error getting nearby responders: $e');
      return _nationalHelplines; // Return helplines as fallback
    }
  }
}
