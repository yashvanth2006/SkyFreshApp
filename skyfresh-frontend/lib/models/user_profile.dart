class UserProfile {
  final String id;
  final String name;
  final String phone;
  final DateTime joinedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.joinedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}
