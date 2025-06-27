class User {
  final int userId;
  final String username;
  final String email;
  final String realName;
  final String? phone;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final int status;
  final List<String> roles;
  
  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.realName,
    this.phone,
    required this.createdAt,
    this.lastLogin,
    required this.status,
    this.roles = const [],
  });
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      username: map['username'],
      email: map['email'],
      realName: map['real_name'],
      phone: map['phone'],
      createdAt: DateTime.parse(map['created_at']),
      lastLogin: map['last_login'] != null 
          ? DateTime.parse(map['last_login']) 
          : null,
      status: map['status'],
      roles: map['roles'] != null ? List<String>.from(map['roles']) : [],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'real_name': realName,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'status': status,
      'roles': roles,
    };
  }
  
  // Helper methods for role checking
  bool get isTeacher => roles.contains('teacher') || roles.contains('教师');
  bool get isStudent => roles.contains('student') || roles.contains('学生');
  bool get isAdmin => roles.contains('admin') || roles.contains('管理员');
}