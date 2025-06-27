import '../models/user.dart';
import '../services/database_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserDao {
  final DatabaseService _db = DatabaseService.instance;
  
  // 用户登录
  Future<User?> login(String username, String password) async {
    final hashedPassword = _hashPassword(password);
    
    final result = await _db.query(
      '''SELECT u.*, STRING_AGG(r.role_name, ',') as roles
         FROM Users u
         LEFT JOIN UserRoles ur ON u.user_id = ur.user_id
         LEFT JOIN Roles r ON ur.role_id = r.role_id
         WHERE u.username = @username AND u.password_hash = @password AND u.status = 1
         GROUP BY u.user_id, u.username, u.password_hash, u.email, u.real_name, u.phone, u.created_at, u.last_login, u.status''',
      {'username': username, 'password': hashedPassword}
    );
    
    if (result.isNotEmpty) {
      // 解析JSON结果
      final data = jsonDecode(result);
      if (data is List && data.isNotEmpty) {
        final userData = data.first;
        // 处理角色数据
        if (userData['roles'] != null) {
          userData['roles'] = userData['roles'].toString().split(',').where((role) => role.isNotEmpty).toList();
        } else {
          userData['roles'] = <String>[];
        }
        return User.fromMap(userData);
      }
    }
    return null;
  }
  
  // 用户注册
  Future<bool> register(User user, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      
      return await _db.execute(
        '''INSERT INTO Users (username, password_hash, email, real_name, phone, status) 
           VALUES (@username, @password, @email, @realName, @phone, @status)''',
        {
          'username': user.username,
          'password': hashedPassword,
          'email': user.email,
          'realName': user.realName,
          'phone': user.phone ?? '',
          'status': 1
        }
      );
    } catch (e) {
      print('用户注册失败: $e');
      return false;
    }
  }
  
  // 获取用户信息
  Future<User?> getUserById(int userId) async {
    final result = await _db.query(
      '''SELECT u.*, STRING_AGG(r.role_name, ',') as roles
         FROM Users u
         LEFT JOIN UserRoles ur ON u.user_id = ur.user_id
         LEFT JOIN Roles r ON ur.role_id = r.role_id
         WHERE u.user_id = @userId
         GROUP BY u.user_id, u.username, u.password_hash, u.email, u.real_name, u.phone, u.created_at, u.last_login, u.status''',
      {'userId': userId}
    );
    
    if (result.isNotEmpty) {
      final data = jsonDecode(result);
      if (data is List && data.isNotEmpty) {
        final userData = data.first;
        // 处理角色数据
        if (userData['roles'] != null) {
          userData['roles'] = userData['roles'].toString().split(',').where((role) => role.isNotEmpty).toList();
        } else {
          userData['roles'] = <String>[];
        }
        return User.fromMap(userData);
      }
    }
    return null;
  }
  
  // 更新最后登录时间
  Future<void> updateLastLogin(int userId) async {
    await _db.execute(
      'UPDATE Users SET last_login = GETDATE() WHERE user_id = @userId',
      {'userId': userId}
    );
  }
  
  // 密码哈希
  String _hashPassword(String password) {
    final bytes = utf8.encode('${password}salt_key');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}