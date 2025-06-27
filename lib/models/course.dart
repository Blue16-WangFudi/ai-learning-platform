class Course {
  final int courseId;
  final String courseName;
  final String? description;
  final String? coverImage;
  final int teacherId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int status;
  final int difficultyLevel;
  final int estimatedHours;
  
  // Additional properties for UI compatibility
  final String? category;
  final String? instructor;
  final double? rating;
  
  Course({
    required this.courseId,
    required this.courseName,
    this.description,
    this.coverImage,
    required this.teacherId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.difficultyLevel,
    required this.estimatedHours,
    this.category,
    this.instructor,
    this.rating,
  });
  
  // Convenience getters for UI compatibility
  String get title => courseName;
  int get duration => estimatedHours;
  String get difficulty {
    switch (difficultyLevel) {
      case 1:
        return '初级';
      case 2:
        return '中级';
      case 3:
        return '高级';
      default:
        return '未知';
    }
  }
  
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseId: map['course_id'],
      courseName: map['course_name'],
      description: map['description'],
      coverImage: map['cover_image'],
      teacherId: map['teacher_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      status: map['status'],
      difficultyLevel: map['difficulty_level'],
      estimatedHours: map['estimated_hours'],
      category: map['category'],
      instructor: map['instructor'],
      rating: map['rating']?.toDouble(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'course_name': courseName,
      'description': description,
      'cover_image': coverImage,
      'teacher_id': teacherId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'difficulty_level': difficultyLevel,
      'estimated_hours': estimatedHours,
      'category': category,
      'instructor': instructor,
      'rating': rating,
    };
  }
}