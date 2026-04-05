class UserProfile {
  final String name;
  final String phoneNumber;
  final String bloodGroup;
  final String emergencyContact;
  final String role;

  UserProfile({
    required this.name,
    required this.phoneNumber,
    required this.bloodGroup,
    required this.emergencyContact,
    this.role = 'User',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'bloodGroup': bloodGroup,
      'emergencyContact': emergencyContact,
      'role': role,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      emergencyContact: json['emergencyContact'] ?? '',
      role: json['role'] ?? 'User',
    );
  }
}
