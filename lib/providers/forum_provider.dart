import 'package:flutter/widgets.dart';
import '../models/forum_post.dart';
import '../dao/forum_dao.dart';

class ForumProvider extends ChangeNotifier {
  List<ForumPost> _posts = [];
  List<ForumPost> _userPosts = [];
  List<ForumPost> _coursePosts = [];
  List<ForumPost> _searchResults = [];
  List<Reply> _replies = [];
  ForumPost? _currentPost;
  bool _isLoading = false;
  bool _isLoadingReplies = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;
  String _currentSearchKeyword = '';
  int? _currentCourseId;

  final ForumDao _forumDao = ForumDao();

  // Getters
  List<ForumPost> get posts => _posts;
  List<ForumPost> get userPosts => _userPosts;
  List<ForumPost> get coursePosts => _coursePosts;
  List<ForumPost> get searchResults => _searchResults;
  List<Reply> get replies => _replies;
  ForumPost? get currentPost => _currentPost;
  bool get isLoading => _isLoading;
  bool get isLoadingReplies => _isLoadingReplies;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

  // 加载所有帖子
  Future<void> loadPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _posts.clear();
    }

    if (!_hasMoreData || _isLoading) return;

    _setLoading(true);
    try {
      final newPosts = await _forumDao.getAllPosts(page: _currentPage);
      if (newPosts.isEmpty) {
        _hasMoreData = false;
      } else {
        if (refresh) {
          _posts = newPosts;
        } else {
          _posts.addAll(newPosts);
        }
        _currentPage++;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '加载帖子失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 根据课程加载帖子
  Future<void> loadPostsByCourse(int courseId, {bool refresh = false}) async {
    if (refresh || _currentCourseId != courseId) {
      _currentPage = 1;
      _hasMoreData = true;
      _coursePosts.clear();
      _currentCourseId = courseId;
    }

    if (!_hasMoreData || _isLoading) return;

    _setLoading(true);
    try {
      final newPosts = await _forumDao.getPostsByCourse(courseId, page: _currentPage);
      if (newPosts.isEmpty) {
        _hasMoreData = false;
      } else {
        if (refresh || _currentCourseId != courseId) {
          _coursePosts = newPosts;
        } else {
          _coursePosts.addAll(newPosts);
        }
        _currentPage++;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '加载课程帖子失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 加载用户帖子
  Future<void> loadUserPosts(int userId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _userPosts.clear();
    }

    if (!_hasMoreData || _isLoading) return;

    _setLoading(true);
    try {
      final newPosts = await _forumDao.getUserPosts(userId, page: _currentPage);
      if (newPosts.isEmpty) {
        _hasMoreData = false;
      } else {
        if (refresh) {
          _userPosts = newPosts;
        } else {
          _userPosts.addAll(newPosts);
        }
        _currentPage++;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '加载用户帖子失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 搜索帖子
  Future<void> searchPosts(String keyword, {bool refresh = false}) async {
    if (refresh || _currentSearchKeyword != keyword) {
      _currentPage = 1;
      _hasMoreData = true;
      _searchResults.clear();
      _currentSearchKeyword = keyword;
    }

    if (!_hasMoreData || _isLoading) return;

    _setLoading(true);
    try {
      final newPosts = await _forumDao.searchPosts(keyword, page: _currentPage);
      if (newPosts.isEmpty) {
        _hasMoreData = false;
      } else {
        if (refresh || _currentSearchKeyword != keyword) {
          _searchResults = newPosts;
        } else {
          _searchResults.addAll(newPosts);
        }
        _currentPage++;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '搜索帖子失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 获取帖子详情
  Future<void> loadPostDetail(int postId) async {
    _setLoading(true);
    try {
      _currentPost = await _forumDao.getPostById(postId);
      if (_currentPost != null) {
        // 增加浏览量
        await _forumDao.incrementViewCount(postId);
        _currentPost = _currentPost!.copyWith(viewCount: _currentPost!.viewCount + 1);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '加载帖子详情失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 加载回复
  Future<void> loadReplies(int postId, {bool refresh = false}) async {
    if (refresh) {
      _replies.clear();
    }

    _setLoadingReplies(true);
    try {
      final newReplies = await _forumDao.getReplies(postId);
      _replies = newReplies;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '加载回复失败: $e';
    } finally {
      _setLoadingReplies(false);
    }
  }

  // 创建帖子
  Future<bool> createPost({
    int? courseId,
    required int userId,
    required String title,
    required String content,
  }) async {
    _setLoading(true);
    try {
      final post = ForumPost(
        postId: 0, // 数据库自动生成
        courseId: courseId,
        userId: userId,
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        viewCount: 0,
        likeCount: 0,
        status: 1,
      );

      final success = await _forumDao.createPost(post);
      if (success) {
        // 刷新帖子列表
        await loadPosts(refresh: true);
        if (courseId != null) {
          await loadPostsByCourse(courseId, refresh: true);
        }
      }
      return success;
    } catch (e) {
      _errorMessage = '创建帖子失败: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 更新帖子
  Future<bool> updatePost(int postId, String title, String content) async {
    _setLoading(true);
    try {
      final success = await _forumDao.updatePost(postId, title, content);
      if (success) {
        // 更新当前帖子
        if (_currentPost?.postId == postId) {
          _currentPost = _currentPost!.copyWith(
            title: title,
            content: content,
            updatedAt: DateTime.now(),
          );
        }
        // 刷新相关列表
        await loadPosts(refresh: true);
      }
      return success;
    } catch (e) {
      _errorMessage = '更新帖子失败: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 删除帖子
  Future<bool> deletePost(int postId) async {
    try {
      final success = await _forumDao.deletePost(postId);
      if (success) {
        // 从列表中移除
        _posts.removeWhere((post) => post.postId == postId);
        _userPosts.removeWhere((post) => post.postId == postId);
        _coursePosts.removeWhere((post) => post.postId == postId);
        _searchResults.removeWhere((post) => post.postId == postId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = '删除帖子失败: $e';
      return false;
    }
  }

  // 点赞帖子
  Future<bool> togglePostLike(int postId, bool isLike) async {
    try {
      final success = await _forumDao.toggleLike(postId, isLike);
      if (success) {
        // 更新本地数据
        _updatePostLikeCount(postId, isLike ? 1 : -1);
      }
      return success;
    } catch (e) {
      _errorMessage = '点赞操作失败: $e';
      return false;
    }
  }

  // 创建回复
  Future<bool> createReply({
    required int postId,
    required int userId,
    required String content,
  }) async {
    try {
      final reply = Reply(
        replyId: 0, // 数据库自动生成
        postId: postId,
        userId: userId,
        content: content,
        createdAt: DateTime.now(),
        likeCount: 0,
        status: 1,
      );

      final success = await _forumDao.createReply(reply);
      if (success) {
        // 刷新回复列表
        await loadReplies(postId, refresh: true);
        // 更新帖子回复数
        _updatePostReplyCount(postId, 1);
      }
      return success;
    } catch (e) {
      _errorMessage = '创建回复失败: $e';
      return false;
    }
  }

  // 删除回复
  Future<bool> deleteReply(int replyId, int postId) async {
    try {
      final success = await _forumDao.deleteReply(replyId);
      if (success) {
        // 从列表中移除
        _replies.removeWhere((reply) => reply.replyId == replyId);
        // 更新帖子回复数
        _updatePostReplyCount(postId, -1);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = '删除回复失败: $e';
      return false;
    }
  }

  // 回复点赞
  Future<bool> toggleReplyLike(int replyId, bool isLike) async {
    try {
      final success = await _forumDao.toggleReplyLike(replyId, isLike);
      if (success) {
        // 更新本地数据
        _updateReplyLikeCount(replyId, isLike ? 1 : -1);
      }
      return success;
    } catch (e) {
      _errorMessage = '回复点赞操作失败: $e';
      return false;
    }
  }

  // 清除错误信息
  void clearError() {
    _errorMessage = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // 重置状态
  void reset() {
    _posts.clear();
    _userPosts.clear();
    _coursePosts.clear();
    _searchResults.clear();
    _replies.clear();
    _currentPost = null;
    _currentPage = 1;
    _hasMoreData = true;
    _currentSearchKeyword = '';
    _currentCourseId = null;
    _errorMessage = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setLoadingReplies(bool loading) {
    _isLoadingReplies = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _updatePostLikeCount(int postId, int increment) {
    // 更新各个列表中的点赞数
    for (var post in _posts) {
      if (post.postId == postId) {
        post = post.copyWith(likeCount: post.likeCount + increment);
        break;
      }
    }
    for (var post in _userPosts) {
      if (post.postId == postId) {
        post = post.copyWith(likeCount: post.likeCount + increment);
        break;
      }
    }
    for (var post in _coursePosts) {
      if (post.postId == postId) {
        post = post.copyWith(likeCount: post.likeCount + increment);
        break;
      }
    }
    for (var post in _searchResults) {
      if (post.postId == postId) {
        post = post.copyWith(likeCount: post.likeCount + increment);
        break;
      }
    }
    if (_currentPost?.postId == postId) {
      _currentPost = _currentPost!.copyWith(likeCount: _currentPost!.likeCount + increment);
    }
    notifyListeners();
  }

  void _updatePostReplyCount(int postId, int increment) {
    // 更新各个列表中的回复数
    for (var post in _posts) {
      if (post.postId == postId) {
        post = post.copyWith(replyCount: (post.replyCount ?? 0) + increment);
        break;
      }
    }
    for (var post in _userPosts) {
      if (post.postId == postId) {
        post = post.copyWith(replyCount: (post.replyCount ?? 0) + increment);
        break;
      }
    }
    for (var post in _coursePosts) {
      if (post.postId == postId) {
        post = post.copyWith(replyCount: (post.replyCount ?? 0) + increment);
        break;
      }
    }
    for (var post in _searchResults) {
      if (post.postId == postId) {
        post = post.copyWith(replyCount: (post.replyCount ?? 0) + increment);
        break;
      }
    }
    if (_currentPost?.postId == postId) {
      _currentPost = _currentPost!.copyWith(replyCount: (_currentPost!.replyCount ?? 0) + increment);
    }
    notifyListeners();
  }

  void _updateReplyLikeCount(int replyId, int increment) {
    for (var reply in _replies) {
      if (reply.replyId == replyId) {
        reply = reply.copyWith(likeCount: reply.likeCount + increment);
        break;
      }
    }
    notifyListeners();
  }
}

// 扩展方法用于复制对象
extension ForumPostCopyWith on ForumPost {
  ForumPost copyWith({
    int? postId,
    int? courseId,
    int? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    int? likeCount,
    int? status,
    String? userName,
    String? courseName,
    int? replyCount,
  }) {
    return ForumPost(
      postId: postId ?? this.postId,
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      status: status ?? this.status,
      userName: userName ?? this.userName,
      courseName: courseName ?? this.courseName,
      replyCount: replyCount ?? this.replyCount,
    );
  }
}

extension ReplyCopyWith on Reply {
  Reply copyWith({
    int? replyId,
    int? postId,
    int? userId,
    String? content,
    DateTime? createdAt,
    int? likeCount,
    int? status,
    String? userName,
  }) {
    return Reply(
      replyId: replyId ?? this.replyId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      status: status ?? this.status,
      userName: userName ?? this.userName,
    );
  }
}