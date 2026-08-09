import 'role.dart';

enum UserStatus { active, inactive }

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final Role role;
  final UserStatus status;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.status = UserStatus.active,
  });

  AppUser copyWith({
    String? id,
    String? fullName,
    String? email,
    Role? role,
    UserStatus? status,
  }) => AppUser(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    role: role ?? this.role,
    status: status ?? this.status,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'role': role.toJson(),
    'status': status.name,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    role: Role.fromJson(json['role'] as Map<String, dynamic>),
    status: UserStatus.values.byName(json['status'] as String),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AppUser && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
