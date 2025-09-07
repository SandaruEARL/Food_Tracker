// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String type;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      type: json['type'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type,
      'token': token,
    };
  }
}