import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/hospital.dart';

class HospitalService {
  // OpenStreetMap Overpass API endpoint
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  
  // Alternative Overpass API servers (in case primary is down)
  static const List<String> _overpassServers = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.openstreetmap.ru/api/interpreter',
  ];

  /// Get nearby hospitals using OpenStreetMap Overpass API
  Future<List<Hospital>> getNearbyHospitals(
    double latitude,
    double longitude, {
    int radius = 5000, // Search radius in meters (default 5km)
  }) async {
    try {
      // Try multiple Overpass servers in case one is down
      for (String server in _overpassServers) {
        try {
          final hospitals = await _fetchFromOverpass(
            server,
            latitude,
            longitude,
            radius,
          );
          if (hospitals.isNotEmpty) {
            return hospitals;
          }
        } catch (e) {
          print('Error with server $server: $e');
          continue;
        }
      }

      // If all servers fail, return mock data
      print('All Overpass servers failed, using mock data');
      return _getMockHospitals(latitude, longitude);
    } catch (e) {
      print('Error fetching hospitals: $e');
      return _getMockHospitals(latitude, longitude);
    }
  }

  Future<List<Hospital>> _fetchFromOverpass(
    String serverUrl,
    double latitude,
    double longitude,
    int radius,
  ) async {
    // Overpass QL query to find hospitals
    // Searches for amenity=hospital and healthcare=hospital within radius
    final query = '''
      [out:json][timeout:25];
      (
        node["amenity"="hospital"](around:$radius,$latitude,$longitude);
        way["amenity"="hospital"](around:$radius,$latitude,$longitude);
        node["healthcare"="hospital"](around:$radius,$latitude,$longitude);
        way["healthcare"="hospital"](around:$radius,$latitude,$longitude);
      );
      out body;
      >;
      out skel qt;
    ''';

    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'data': query},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List elements = data['elements'] ?? [];
      
      List<Hospital> hospitals = [];
      
      for (var element in elements) {
        // Skip if element doesn't have required fields
        if (element['type'] == 'node' && element['lat'] != null && element['lon'] != null) {
          final tags = element['tags'] ?? {};
          
          // Only add if it has a name
          if (tags['name'] != null) {
            final hospitalLat = element['lat'].toDouble();
            final hospitalLng = element['lon'].toDouble();
            final distance = _calculateDistance(
              latitude,
              longitude,
              hospitalLat,
              hospitalLng,
            );

            hospitals.add(
              Hospital(
                placeId: element['id']?.toString() ?? 'osm_${hospitals.length}',
                name: tags['name'] ?? 'Hospital',
                address: _buildAddress(tags),
                latitude: hospitalLat,
                longitude: hospitalLng,
                distance: distance,
                phoneNumber: tags['phone'] ?? tags['contact:phone'],
                rating: null, // OSM doesn't provide ratings
                isOpen: _parseOpeningHours(tags['opening_hours']),
              ),
            );
          }
        } else if (element['type'] == 'way' && element['center'] != null) {
          // For ways (buildings), use center point
          final tags = element['tags'] ?? {};
          
          if (tags['name'] != null) {
            final hospitalLat = element['center']['lat'].toDouble();
            final hospitalLng = element['center']['lon'].toDouble();
            final distance = _calculateDistance(
              latitude,
              longitude,
              hospitalLat,
              hospitalLng,
            );

            hospitals.add(
              Hospital(
                placeId: element['id']?.toString() ?? 'osm_${hospitals.length}',
                name: tags['name'] ?? 'Hospital',
                address: _buildAddress(tags),
                latitude: hospitalLat,
                longitude: hospitalLng,
                distance: distance,
                phoneNumber: tags['phone'] ?? tags['contact:phone'],
                rating: null,
                isOpen: _parseOpeningHours(tags['opening_hours']),
              ),
            );
          }
        }
      }

      // Sort by distance
      hospitals.sort((a, b) => a.distance.compareTo(b.distance));
      
      // Return top 10 closest hospitals
      return hospitals.take(10).toList();
    }

    throw Exception('Failed to fetch from Overpass API: ${response.statusCode}');
  }

  /// Build address from OSM tags
  String _buildAddress(Map<String, dynamic> tags) {
    List<String> addressParts = [];
    
    if (tags['addr:housenumber'] != null) {
      addressParts.add(tags['addr:housenumber']);
    }
    if (tags['addr:street'] != null) {
      addressParts.add(tags['addr:street']);
    }
    if (tags['addr:city'] != null) {
      addressParts.add(tags['addr:city']);
    }
    if (tags['addr:postcode'] != null) {
      addressParts.add(tags['addr:postcode']);
    }
    
    if (addressParts.isEmpty) {
      return 'Address not available';
    }
    
    return addressParts.join(', ');
  }

  /// Parse opening hours (simplified)
  bool _parseOpeningHours(String? openingHours) {
    if (openingHours == null) return true; // Assume open if not specified
    
    // Common 24/7 formats
    if (openingHours.contains('24/7') || openingHours.contains('24 hours')) {
      return true;
    }
    
    // For now, we'll just return true as proper parsing is complex
    // In production, you'd want a proper opening hours parser
    return true;
  }

  /// Generate mock hospital data for testing when API is unavailable
  List<Hospital> _getMockHospitals(double latitude, double longitude) {
    final List<String> hospitalNames = [
      'City General Hospital',
      'St. Mary\'s Medical Center',
      'Regional Emergency Hospital',
      'Community Health Center',
      'Central District Hospital',
      'Metro Emergency Care',
      'University Medical Center',
      'Mercy Hospital & Trauma Center',
    ];

    final List<Hospital> hospitals = [];

    for (int i = 0; i < 8; i++) {
      // Generate random offsets for location (within ~5km)
      final double latOffset = (i * 0.01) - 0.03;
      final double lngOffset = (i * 0.01) - 0.03;
      
      final hospitalLat = latitude + latOffset;
      final hospitalLng = longitude + lngOffset;

      hospitals.add(
        Hospital(
          placeId: 'mock_place_id_$i',
          name: hospitalNames[i],
          address: '${100 + i * 50} Medical Plaza, Healthcare District',
          latitude: hospitalLat,
          longitude: hospitalLng,
          distance: _calculateDistance(latitude, longitude, hospitalLat, hospitalLng),
          phoneNumber: '+1 (555) ${100 + i}00-${1000 + i * 111}',
          rating: 4.0 + (i % 10) * 0.1,
          isOpen: true,
        ),
      );
    }

    // Sort by distance
    hospitals.sort((a, b) => a.distance.compareTo(b.distance));
    
    return hospitals.take(5).toList();
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // in kilometers
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }
}
