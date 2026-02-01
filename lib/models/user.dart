class User {
  final String id;
  final String username;
  final String roleId;
  final String? roleName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? email;
  final String? phone;
  final int? annualLeaveQuota;
  final String? firstName;
  final String? lastName;
  final String? departmentId;
  final String? departmentName;

  User({
    required this.id,
    required this.username,
    required this.roleId,
    this.roleName,
    this.createdAt,
    this.updatedAt,
    this.email,
    this.phone,
    this.annualLeaveQuota,
    this.firstName,
    this.lastName,
    this.departmentId,
    this.departmentName,
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
      email: json['email'],
      phone: json['phone'],
      annualLeaveQuota: json['annualLeaveQuota'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'roleId': roleId,
      'roleName': roleName,
      'email': email,
      'phone': phone,
      'annualLeaveQuota': annualLeaveQuota,
      'firstName': firstName,
      'lastName': lastName,
      'departmentId': departmentId,
      'departmentName': departmentName,
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
