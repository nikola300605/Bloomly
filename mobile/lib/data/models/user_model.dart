class UserModel {
  final String id;
  final String name;
  final String handle;
  final String email;
  final String? avatar;
  final String? location;
  final String? climateZone;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.handle,
    required this.email,
    this.avatar,
    this.location,
    this.climateZone,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as String,
        name: j['name'] as String,
        handle: j['handle'] as String,
        email: j['email'] as String,
        avatar: j['avatar'] as String?,
        location: j['location'] as String?,
        climateZone: j['climate_zone'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
