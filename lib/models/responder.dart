class Responder {
  final String id;
  final String name;
  final String role;
  final String phoneNumber;
  final double distance; // in km

  Responder({
    required this.id,
    required this.name,
    required this.role,
    required this.phoneNumber,
    required this.distance,
  });

  factory Responder.fromJson(Map<String, dynamic> json) {
    return Responder(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      phoneNumber: json['phoneNumber'] as String,
      distance: (json['distance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'distance': distance,
    };
  }
}
