import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../dao/user_dao.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  final UserDao _userDao = UserDao();
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  
  // 登录
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final user = await _userDao.login(username, password);
      if (user != null) {
        _currentUser = user;
        await _userDao.updateLastLogin(user.userId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = '用户名或密码错误';
        return false;
      }
    } catch (e) {
      _errorMessage = '登录失败: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 注册
  Future<bool> register(User user, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final success = await _userDao.register(user, password);
      if (!success) {
        _errorMessage = '注册失败，用户名或邮箱已存在';
      }
      return success;
    } catch (e) {
      _errorMessage = '注册失败: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 登出
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}