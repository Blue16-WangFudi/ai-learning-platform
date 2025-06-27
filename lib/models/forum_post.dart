class ForumPost {
  final int postId;
  final int? courseId;
  final int userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final int likeCount;
  final int status;
  final String? userName;
  final String? courseName;
  final int? replyCount;

  ForumPost({
    required this.postId,
    this.courseId,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.viewCount,
    required this.likeCount,
    required this.status,
    this.userName,
    this.courseName,
    this.replyCount,
  });

  factory ForumPost.fromMap(Map<String, dynamic> map) {
    return ForumPost(
      postId: map['post_id'],
      courseId: map['course_id'],
      userId: map['user_id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      viewCount: map['view_count'] ?? 0,
      likeCount: map['like_count'] ?? 0,
      status: map['status'],
      userName: map['user_name'],
      courseName: map['course_name'],
      replyCount: map['reply_count'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'post_id': postId,
      'course_id': courseId,
      'user_id': userId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'view_count': viewCount,
      'like_count': likeCount,
      'status': status,
    };
  }
}

class Reply {
  final int replyId;
  final int postId;
  final int userId;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final int status;
  final String? userName;

  Reply({
    required this.replyId,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.status,
    this.userName,
  });

  factory Reply.fromMap(Map<String, dynamic> map) {
    return Reply(
      replyId: map['reply_id'],
      postId: map['post_id'],
      userId: map['user_id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      likeCount: map['like_count'] ?? 0,
      status: map['status'],
      userName: map['user_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reply_id': replyId,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'like_count': likeCount,
      'status': status,
    };
  }
}