class User {
  final String id;
  final String username;
  final String roleId;
  final String? roleName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.roleId,
    this.roleName,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      roleId: json['roleId'] ?? '',
      roleName: json['roleName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'roleId': roleId,
      'roleName': roleName,
    };
  }
}

class LoginResponse {
  final String token;
  final String userId;
  final String username;
  final String roleId;
  final String? roleName;

  LoginResponse({
    required this.token,
    required this.userId,
    required this.username,
    required this.roleId,
    this.roleName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      roleId: json['roleId'] ?? '',
      roleName: json['roleName'],
    );
  }
}
