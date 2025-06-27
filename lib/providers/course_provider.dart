import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../dao/course_dao.dart';

class CourseProvider extends ChangeNotifier {
  List<Course> _allCourses = [];
  List<Course> _userCourses = [];
  List<Course> _teacherCourses = [];
  List<Course> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  final CourseDao _courseDao = CourseDao();
  
  List<Course> get allCourses => _allCourses;
  List<Course> get userCourses => _userCourses;
  List<Course> get teacherCourses => _teacherCourses;
  List<Course> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // 加载所有课程
  Future<void> loadAllCourses() async {
    _setLoading(true);
    try {
      _allCourses = await _courseDao.getAllCourses();
    } catch (e) {
      _errorMessage = '加载课程失败: $e';
    } finally {
      _setLoading(false);
    }
  }
  
  // 加载用户课程
  Future<void> loadUserCourses(int userId) async {
    _setLoading(true);
    try {
      _userCourses = await _courseDao.getUserCourses(userId);
    } catch (e) {
      _errorMessage = '加载用户课程失败: $e';
    } finally {
      _setLoading(false);
    }
  }
  
  // 选课
  Future<bool> enrollCourse(int userId, int courseId) async {
    try {
      final success = await _courseDao.enrollCourse(userId, courseId);
      if (success) {
        await loadUserCourses(userId);
      }
      return success;
    } catch (e) {
      _errorMessage = '选课失败: $e';
      return false;
    }
  }
  
  // 搜索课程
  Future<void> searchCourses(String keyword) async {
    _setLoading(true);
    try {
      _searchResults = await _courseDao.searchCourses(keyword);
    } catch (e) {
      _errorMessage = '搜索失败: $e';
    } finally {
      _setLoading(false);
    }
  }
  
  // 加载教师课程
  Future<void> loadTeacherCourses(int teacherId) async {
    _setLoading(true);
    try {
      _teacherCourses = await _courseDao.getTeacherCourses(teacherId);
    } catch (e) {
      _errorMessage = '加载教师课程失败: $e';
    } finally {
      _setLoading(false);
    }
  }
  
  // 创建课程
  Future<bool> createCourse({
    required String courseName,
    required String description,
    required int teacherId,
    String? coverImage,
    int difficultyLevel = 1,
    int estimatedHours = 0,
  }) async {
    _setLoading(true);
    try {
      final success = await _courseDao.createCourse(
        courseName: courseName,
        description: description,
        teacherId: teacherId,
        coverImage: coverImage,
        difficultyLevel: difficultyLevel,
        estimatedHours: estimatedHours,
      );
      if (success) {
        await loadTeacherCourses(teacherId);
        await loadAllCourses();
      }
      return success;
    } catch (e) {
      _errorMessage = '创建课程失败: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 发布课程
  Future<bool> publishCourse(int courseId, int teacherId) async {
    try {
      final success = await _courseDao.publishCourse(courseId);
      if (success) {
        await loadTeacherCourses(teacherId);
        await loadAllCourses();
      }
      return success;
    } catch (e) {
      _errorMessage = '发布课程失败: $e';
      return false;
    }
  }
  
  // 更新课程
  Future<bool> updateCourse({
    required int courseId,
    required String courseName,
    required String description,
    required int teacherId,
    String? coverImage,
    int? difficultyLevel,
    int? estimatedHours,
  }) async {
    try {
      final success = await _courseDao.updateCourse(
        courseId: courseId,
        courseName: courseName,
        description: description,
        coverImage: coverImage,
        difficultyLevel: difficultyLevel,
        estimatedHours: estimatedHours,
      );
      if (success) {
        await loadTeacherCourses(teacherId);
        await loadAllCourses();
      }
      return success;
    } catch (e) {
      _errorMessage = '更新课程失败: $e';
      return false;
    }
  }
  
  // 删除课程
  Future<bool> deleteCourse(int courseId, int teacherId) async {
    try {
      final success = await _courseDao.deleteCourse(courseId);
      if (success) {
        await loadTeacherCourses(teacherId);
        await loadAllCourses();
      }
      return success;
    } catch (e) {
      _errorMessage = '删除课程失败: $e';
      return false;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}