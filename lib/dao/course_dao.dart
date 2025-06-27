import '../models/course.dart';
import '../services/database_service.dart';
import 'dart:convert';

class CourseDao {
  final DatabaseService _db = DatabaseService.instance;
  
  // 获取所有课程
  Future<List<Course>> getAllCourses() async {
    final result = await _db.query(
      'SELECT * FROM Courses WHERE status = 1 ORDER BY created_at DESC'
    );
    
    final data = jsonDecode(result);
    if (data is List) {
      return data.map((row) => Course.fromMap(row)).toList();
    }
    return [];
  }
  
  // 获取用户已选课程
  Future<List<Course>> getUserCourses(int userId) async {
    final result = await _db.query(
      '''SELECT c.* FROM Courses c 
         INNER JOIN Enrollments e ON c.course_id = e.course_id 
         WHERE e.user_id = @userId AND e.status = 1''',
      {'userId': userId}
    );
    
    final data = jsonDecode(result);
    if (data is List) {
      return data.map((row) => Course.fromMap(row)).toList();
    }
    return [];
  }
  
  // 选课
  Future<bool> enrollCourse(int userId, int courseId) async {
    try {
      return await _db.execute(
        'INSERT INTO Enrollments (user_id, course_id, status) VALUES (@userId, @courseId, @status)',
        {'userId': userId, 'courseId': courseId, 'status': 1}
      );
    } catch (e) {
      print('选课失败: $e');
      return false;
    }
  }
  
  // 获取课程详情
  Future<Course?> getCourseById(int courseId) async {
    final result = await _db.query(
      'SELECT * FROM Courses WHERE course_id = @courseId',
      {'courseId': courseId}
    );
    
    if (result.isNotEmpty) {
      final data = jsonDecode(result);
      if (data is List && data.isNotEmpty) {
        return Course.fromMap(data.first);
      }
    }
    return null;
  }
  
  // 搜索课程
  Future<List<Course>> searchCourses(String keyword) async {
    final result = await _db.query(
      '''SELECT * FROM Courses 
         WHERE (course_name LIKE @keyword1 OR description LIKE @keyword2) AND status = 1''',
      {'keyword1': '%$keyword%', 'keyword2': '%$keyword%'}
    );
    
    final data = jsonDecode(result);
    if (data is List) {
      return data.map((row) => Course.fromMap(row)).toList();
    }
    return [];
  }
  
  // 创建课程（教师发布课程）
  Future<bool> createCourse({
    required String courseName,
    required String description,
    required int teacherId,
    String? coverImage,
    int difficultyLevel = 1,
    int estimatedHours = 0,
  }) async {
    try {
      return await _db.execute(
        '''INSERT INTO Courses (course_name, description, cover_image, teacher_id, 
                               difficulty_level, estimated_hours, status, created_at, updated_at)
           VALUES (@courseName, @description, @coverImage, @teacherId, 
                   @difficultyLevel, @estimatedHours, @status, GETDATE(), GETDATE())''',
        {
          'courseName': courseName,
          'description': description,
          'coverImage': coverImage,
          'teacherId': teacherId,
          'difficultyLevel': difficultyLevel,
          'estimatedHours': estimatedHours,
          'status': 0, // 0=草稿，1=已发布
        }
      );
    } catch (e) {
      print('创建课程失败: $e');
      return false;
    }
  }
  
  // 发布课程（将草稿状态改为发布状态）
  Future<bool> publishCourse(int courseId) async {
    try {
      return await _db.execute(
        'UPDATE Courses SET status = 1, updated_at = GETDATE() WHERE course_id = @courseId',
        {'courseId': courseId}
      );
    } catch (e) {
      print('发布课程失败: $e');
      return false;
    }
  }
  
  // 获取教师的课程列表
  Future<List<Course>> getTeacherCourses(int teacherId) async {
    final result = await _db.query(
      'SELECT * FROM Courses WHERE teacher_id = @teacherId ORDER BY created_at DESC',
      {'teacherId': teacherId}
    );
    
    final data = jsonDecode(result);
    if (data is List) {
      return data.map((row) => Course.fromMap(row)).toList();
    }
    return [];
  }
  
  // 更新课程信息
  Future<bool> updateCourse({
    required int courseId,
    required String courseName,
    required String description,
    String? coverImage,
    int? difficultyLevel,
    int? estimatedHours,
  }) async {
    try {
      return await _db.execute(
        '''UPDATE Courses SET 
           course_name = @courseName,
           description = @description,
           cover_image = @coverImage,
           difficulty_level = @difficultyLevel,
           estimated_hours = @estimatedHours,
           updated_at = GETDATE()
           WHERE course_id = @courseId''',
        {
          'courseId': courseId,
          'courseName': courseName,
          'description': description,
          'coverImage': coverImage,
          'difficultyLevel': difficultyLevel ?? 1,
          'estimatedHours': estimatedHours ?? 0,
        }
      );
    } catch (e) {
      print('更新课程失败: $e');
      return false;
    }
  }
  
  // 删除课程
  Future<bool> deleteCourse(int courseId) async {
    try {
      return await _db.execute(
        'UPDATE Courses SET status = -1 WHERE course_id = @courseId',
        {'courseId': courseId}
      );
    } catch (e) {
      print('删除课程失败: $e');
      return false;
    }
  }
}