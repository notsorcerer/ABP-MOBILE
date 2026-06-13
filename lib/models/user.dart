class User {
  final int id;
  final String name;
  final String email;
  final bool isAdmin;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      isAdmin: json['is_admin'] as bool,
      createdAt: json['created_at'] as String,
    );
  }
}
