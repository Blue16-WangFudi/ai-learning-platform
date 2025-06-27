import '../models/forum_post.dart';
import '../services/database_service.dart';
import 'dart:convert';

class ForumDao {
  final DatabaseService _db = DatabaseService.instance;

  // 获取所有帖子（分页）
  Future<List<ForumPost>> getAllPosts({int page = 1, int pageSize = 20}) async {
    final offset = (page - 1) * pageSize;
    final result = await _db.query(
      '''SELECT fp.*, u.real_name as user_name, c.course_name,
         (SELECT COUNT(*) FROM Replies r WHERE r.post_id = fp.post_id AND r.status = 1) as reply_count
         FROM ForumPosts fp
         LEFT JOIN Users u ON fp.user_id = u.user_id
         LEFT JOIN Courses c ON fp.course_id = c.course_id
         WHERE fp.status = 1
         ORDER BY fp.created_at DESC
         OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY''',
      {'offset': offset, 'pageSize': pageSize}
    );

    final data = jsonDecode(result);
    if (data is List) {
      return data.map((row) => ForumPost.fromMap(row)).toList();
    }
    return [];
  }

  // 根据课程获取帖子
  Future<List<ForumPost>> getPostsByCourse(int courseId, {int page = 1, int pageSize = 20}) async {
    final offset = (page - 1) * pageSize;
    final result = await _db.query(
      '''SELECT fp.*, u.real_name as user_name, c.course_name,
         (SELECT COUNT(*) FROM Replies r WHERE r.post_id = fp.post_id AND r.status = 1) as reply_count
         FROM ForumPosts fp
         LEFT JOIN Users u ON fp.user_id = u.user_id
         LEFT JOIN Courses c ON fp.course_id = c.course_id
         WHERE fp.course_id = @courseId AND fp.status = 1
         ORDER BY fp.created_at DESC
         OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY''',
      {'courseId': courseId, 'offset': offset, 'pageSize': pageSize}
    );

    final data = jsonDecode(result);
    if (data is List) {
      return data.map((row) => ForumPost.fromMap(row)).toList();
    }
    return [];
  }

  // 获取用户的帖子
  Future<List<ForumPost>> getUserPosts(int userId, {int page = 1, int pageSize = 20}) async {
    final offset = (page - 1) * pageSize;
    final result = await _db.query(
      '''SELECT fp.*, u.real_name as user_name, c.course_name,
         (SELECT COUNT(*) FROM Replies r WHERE r.post_id = fp.post_id AND r.status = 1) as reply_count
         FROM ForumPosts fp
         LEFT JOIN Users u ON fp.user_id = u.user_id
         LEFT JOIN Courses c ON fp.course_id = c.course_id
         WHERE fp.user_id = @userId AND fp.status = 1
         ORDER BY fp.created_at DESC
         OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY''',
      {'userId': userId, 'offset': offset, 'pageSize': pageSize}
    );

    final data = jsonDecode(result);
    if (data is List) {
      return data.map((row) => ForumPost.fromMap(row)).toList();
    }
    return [];
  }

  // 获取帖子详情
  Future<ForumPost?> getPostById(int postId) async {
    final result = await _db.query(
      '''SELECT fp.*, u.real_name as user_name, c.course_name,
         (SELECT COUNT(*) FROM Replies r WHERE r.post_id = fp.post_id AND r.status = 1) as reply_count
         FROM ForumPosts fp
         LEFT JOIN Users u ON fp.user_id = u.user_id
         LEFT JOIN Courses c ON fp.course_id = c.course_id
         WHERE fp.post_id = @postId''',
      {'postId': postId}
    );

    if (result.isNotEmpty) {
      final data = jsonDecode(result);
      if (data is List && data.isNotEmpty) {
        return ForumPost.fromMap(data.first);
      }
    }
    return null;
  }

  // 创建新帖子
  Future<bool> createPost(ForumPost post) async {
    try {
      return await _db.execute(
        '''INSERT INTO ForumPosts (course_id, user_id, title, content, status)
           VALUES (@courseId, @userId, @title, @content, @status)''',
        {
          'courseId': post.courseId,
          'userId': post.userId,
          'title': post.title,
          'content': post.content,
          'status': 1
        }
      );
    } catch (e) {
      print('创建帖子失败: $e');
      return false;
    }
  }

  // 更新帖子
  Future<bool> updatePost(int postId, String title, String content) async {
    try {
      return await _db.execute(
        '''UPDATE ForumPosts 
           SET title = @title, content = @content, updated_at = GETDATE()
           WHERE post_id = @postId''',
        {
          'postId': postId,
          'title': title,
          'content': content
        }
      );
    } catch (e) {
      print('更新帖子失败: $e');
      return false;
    }
  }

  // 删除帖子（软删除）
  Future<bool> deletePost(int postId) async {
    try {
      return await _db.execute(
        'UPDATE ForumPosts SET status = 0 WHERE post_id = @postId',
        {'postId': postId}
      );
    } catch (e) {
      print('删除帖子失败: $e');
      return false;
    }
  }

  // 增加浏览量
  Future<void> incrementViewCount(int postId) async {
    try {
      await _db.execute(
        'UPDATE ForumPosts SET view_count = view_count + 1 WHERE post_id = @postId',
        {'postId': postId}
      );
    } catch (e) {
      print('更新浏览量失败: $e');
    }
  }

  // 点赞/取消点赞
  Future<bool> toggleLike(int postId, bool isLike) async {
    try {
      final increment = isLike ? 1 : -1;
      return await _db.execute(
        'UPDATE ForumPosts SET like_count = like_count + @increment WHERE post_id = @postId',
        {'postId': postId, 'increment': increment}
      );
    } catch (e) {
      print('点赞操作失败: $e');
      return false;
    }
  }

  // 搜索帖子
  Future<List<ForumPost>> searchPosts(String keyword, {int page = 1, int pageSize = 20}) async {
    final offset = (page - 1) * pageSize;
    final result = await _db.query(
      '''SELECT fp.*, u.real_name as user_name, c.course_name,
         (SELECT COUNT(*) FROM Replies r WHERE r.post_id = fp.post_id AND r.status = 1) as reply_count
         FROM ForumPosts fp
         LEFT JOIN Users u ON fp.user_id = u.user_id
         LEFT JOIN Courses c ON fp.course_id = c.course_id
         WHERE (fp.title LIKE @keyword1 OR fp.content LIKE @keyword2) AND fp.status = 1
         ORDER BY fp.created_at DESC
         OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY''',
      {
        'keyword1': '%$keyword%',
        'keyword2': '%$keyword%',
        'offset': offset,
        'pageSize': pageSize
      }
    );

    final data = jsonDecode(result);
    if (data is List) {
      return data.map((row) => ForumPost.fromMap(row)).toList();
    }
    return [];
  }

  // 获取帖子的回复
  Future<List<Reply>> getReplies(int postId, {int page = 1, int pageSize = 20}) async {
    final offset = (page - 1) * pageSize;
    final result = await _db.query(
      '''SELECT r.*, u.real_name as user_name
         FROM Replies r
         LEFT JOIN Users u ON r.user_id = u.user_id
         WHERE r.post_id = @postId AND r.status = 1
         ORDER BY r.created_at ASC
         OFFSET @offset ROWS FETCH NEXT @pageSize ROWS ONLY''',
      {'postId': postId, 'offset': offset, 'pageSize': pageSize}
    );

    final data = jsonDecode(result);
    if (data is List) {
      return data.map((row) => Reply.fromMap(row)).toList();
    }
    return [];
  }

  // 创建回复
  Future<bool> createReply(Reply reply) async {
    try {
      return await _db.execute(
        '''INSERT INTO Replies (post_id, user_id, content, status)
           VALUES (@postId, @userId, @content, @status)''',
        {
          'postId': reply.postId,
          'userId': reply.userId,
          'content': reply.content,
          'status': 1
        }
      );
    } catch (e) {
      print('创建回复失败: $e');
      return false;
    }
  }

  // 删除回复（软删除）
  Future<bool> deleteReply(int replyId) async {
    try {
      return await _db.execute(
        'UPDATE Replies SET status = 0 WHERE reply_id = @replyId',
        {'replyId': replyId}
      );
    } catch (e) {
      print('删除回复失败: $e');
      return false;
    }
  }

  // 回复点赞/取消点赞
  Future<bool> toggleReplyLike(int replyId, bool isLike) async {
    try {
      final increment = isLike ? 1 : -1;
      return await _db.execute(
        'UPDATE Replies SET like_count = like_count + @increment WHERE reply_id = @replyId',
        {'replyId': replyId, 'increment': increment}
      );
    } catch (e) {
      print('回复点赞操作失败: $e');
      return false;
    }
  }
}