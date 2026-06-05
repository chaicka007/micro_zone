import 'package:equatable/equatable.dart';

enum UserRole { user, admin }

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
        UserRole.user => 'Пользователь',
        UserRole.admin => 'Администратор',
      };
}

class UserModel extends Equatable {
  final String name;
  final String email;
  final String password;
  final UserRole role;

  const UserModel({
    required this.name,
    required this.email,
    required this.password,
    this.role = UserRole.user,
  });

  UserModel copyWith({UserRole? role}) => UserModel(
        name: name,
        email: email,
        password: password,
        role: role ?? this.role,
      );

  Map<String, Object?> toMap() => {
        'email': email,
        'name': name,
        'password': password,
        'role': role.name,
      };

  factory UserModel.fromMap(Map<String, Object?> map) => UserModel(
        email: map['email'] as String,
        name: map['name'] as String,
        password: map['password'] as String,
        role: UserRole.values.firstWhere(
          (r) => r.name == map['role'],
          orElse: () => UserRole.user,
        ),
      );

  @override
  List<Object> get props => [email];
}
