import 'dart:math' as math;

class Hospital {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance;
  final String? phoneNumber;
  final double? rating;
  final bool isOpen;

  Hospital({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.phoneNumber,
    this.rating,
    this.isOpen = true,
  });

  factory Hospital.fromJson(Map<String, dynamic> json, double userLat, double userLng) {
    final location = json['geometry']['location'];
    final lat = location['lat'];
    final lng = location['lng'];
    
    return Hospital(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? 'Unknown Hospital',
      address: json['vicinity'] ?? json['formatted_address'] ?? 'Address not available',
      latitude: lat,
      longitude: lng,
      distance: _calculateDistance(userLat, userLng, lat, lng),
      phoneNumber: json['formatted_phone_number'],
      rating: json['rating']?.toDouble(),
      isOpen: json['opening_hours']?['open_now'] ?? true,
    );
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  String get distanceText {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
    return '${distance.toStringAsFixed(2)} km';
  }

  int get estimatedDriveTime {
    // Assuming average speed of 30 km/h in city
    return (distance / 30 * 60).ceil();
  }
}
