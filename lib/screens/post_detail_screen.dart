import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/forum_provider.dart';
import '../providers/user_provider.dart';
import '../providers/course_provider.dart';
import '../models/forum_post.dart';
import '../widgets/reply_card.dart';
import 'edit_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSubmittingReply = false;
  ForumPost? _post;

  @override
  void initState() {
    super.initState();
    _loadPostDetail();
  }

  Future<void> _loadPostDetail() async {
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    await forumProvider.loadPostDetail(widget.postId);
    await forumProvider.loadReplies(widget.postId);
    
    setState(() {
      _post = forumProvider.posts.firstWhere(
        (post) => post.postId == widget.postId,
        orElse: () => throw Exception('Post not found'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帖子详情'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (_post != null && 
                  userProvider.currentUser != null && 
                  _post!.userId == userProvider.currentUser!.userId) {
                return PopupMenuButton<String>(
                  onSelected: _handleMenuAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('编辑'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ForumProvider>(
        builder: (context, forumProvider, child) {
          if (forumProvider.isLoading && _post == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_post == null) {
            return const Center(
              child: Text('帖子不存在或已被删除'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _buildPostContent(),
                      const Divider(height: 1),
                      _buildRepliesSection(),
                    ],
                  ),
                ),
              ),
              _buildReplyInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 课程标签
          if (_post!.courseId != null) _buildCourseTag(),
          
          // 标题
          Text(
            _post!.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          
          // 作者信息
          _buildAuthorInfo(),
          const SizedBox(height: 16),
          
          // 内容
          Text(
            _post!.content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          
          // 统计信息和操作
          _buildPostActions(),
        ],
      ),
    );
  }

  Widget _buildCourseTag() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        final course = courseProvider.allCourses.firstWhere(
          (c) => c.courseId == _post!.courseId,
          orElse: () => throw Exception('Course not found'),
        );
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Chip(
            label: Text(
              course.courseName,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.blue.shade50,
            side: BorderSide(color: Colors.blue.shade200),
          ),
        );
      },
    );
  }

  Widget _buildAuthorInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade300,
          child: Text(
            _post!.userName != null && _post!.userName!.isNotEmpty ? _post!.userName![0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _post!.userName ?? '未知用户',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                _formatTime(_post!.createdAt),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostActions() {
    return Row(
      children: [
        // 浏览量
        Icon(Icons.visibility, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          '${_post!.viewCount}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(width: 16),
        
        // 回复数
        Icon(Icons.comment, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Consumer<ForumProvider>(
          builder: (context, forumProvider, child) {
            final replies = forumProvider.replies;
            return Text(
              '${replies.length}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            );
          },
        ),
        const Spacer(),
        
        // 点赞按钮
        Consumer<ForumProvider>(
          builder: (context, forumProvider, child) {
            return InkWell(
              onTap: () => _toggleLike(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.thumb_up,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_post!.likeCount}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRepliesSection() {
    return Consumer<ForumProvider>(
      builder: (context, forumProvider, child) {
        final replies = forumProvider.replies;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '回复 (${replies.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (replies.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    '暂无回复，快来抢沙发吧！',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...replies.map((reply) => ReplyCard(
                reply: reply,
                onDelete: () => _deleteReply(reply.replyId),
                onLike: () => _toggleReplyLike(reply.replyId),
              )),
          ],
        );
      },
    );
  }

  Widget _buildReplyInput() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.currentUser == null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: const Center(
              child: Text(
                '请登录后参与讨论',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  decoration: const InputDecoration(
                    hintText: '写下你的回复...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLines: null,
                  minLines: 1,
                  maxLength: 500,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSubmittingReply ? null : _submitReply,
                child: _isSubmittingReply
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('发送'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _toggleLike() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    await forumProvider.togglePostLike(
      widget.postId,
      true, // true to like, false to unlike
    );
    
    // 更新本地帖子数据
    setState(() {
      _post = forumProvider.posts.firstWhere(
        (post) => post.postId == widget.postId,
      );
    });
  }

  Future<void> _toggleReplyLike(int replyId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    await forumProvider.toggleReplyLike(
      replyId,
      true, // true to like, false to unlike
    );
  }

  Future<void> _submitReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty) {
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    setState(() {
      _isSubmittingReply = true;
    });

    try {
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      final success = await forumProvider.createReply(
        postId: widget.postId,
        userId: userProvider.currentUser!.userId,
        content: content,
      );

      if (mounted) {
        if (success) {
          _replyController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('回复成功！'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 滚动到底部显示新回复
          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(forumProvider.errorMessage ?? '回复失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('回复失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingReply = false;
        });
      }
    }
  }

  Future<void> _deleteReply(int replyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条回复吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      final success = await forumProvider.deleteReply(replyId, widget.postId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '删除成功' : '删除失败'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'edit':
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => EditPostScreen(post: _post!),
          ),
        );
        if (result == true) {
          _loadPostDetail(); // 重新加载帖子详情
        }
        break;
      case 'delete':
        _deletePost();
        break;
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个帖子吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      final success = await forumProvider.deletePost(widget.postId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('删除成功'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // 返回上一页
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(forumProvider.errorMessage ?? '删除失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}