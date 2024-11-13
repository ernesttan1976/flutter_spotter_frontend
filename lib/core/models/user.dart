import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final DateTime expiryTime;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.expiryTime,
  });

  factory User.fromJson(String source) {
    final Map<String, dynamic> map = json.decode(source);
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      expiryTime: DateTime.parse(map['expiryTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'expiryTime': expiryTime.toIso8601String(),
    };
  }
}