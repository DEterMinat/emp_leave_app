class Employee {
  final String id;
  final String userId;
  final String departmentId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? address;
  final String? departmentName;
  final String? username;
  final String? position;
  final double? salary;

  Employee({
    required this.id,
    required this.userId,
    required this.departmentId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.address,
    this.departmentName,
    this.username,
    this.position,
    this.salary,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      departmentId: json['departmentId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      departmentName: json['departmentName'],
      username: json['username'],
      position: json['position'],
      salary: json['salary'] != null
          ? (json['salary'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'departmentId': departmentId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'position': position,
      'salary': salary,
    };
  }
}
