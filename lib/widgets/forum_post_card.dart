import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/forum_post.dart';
import '../providers/forum_provider.dart';
import '../providers/user_provider.dart';
import '../screens/post_detail_screen.dart';
import 'package:intl/intl.dart';

class ForumPostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback? onTap;
  final bool showActions;

  const ForumPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () => _navigateToPostDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildTitle(context),
              const SizedBox(height: 8),
              _buildContent(context),
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            post.userName?.substring(0, 1).toUpperCase() ?? 'U',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.userName ?? '未知用户',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (post.courseName != null)
                Text(
                  post.courseName!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
          ),
        ),
        Text(
          _formatTime(post.createdAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        if (showActions) _buildActionMenu(context),
      ],
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.currentUser?.userId != post.userId) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (value) => _handleAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('编辑'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      post.title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      post.content,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey[700],
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        _buildStatItem(
          context,
          Icons.visibility_outlined,
          post.viewCount.toString(),
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          context,
          Icons.chat_bubble_outline,
          (post.replyCount ?? 0).toString(),
        ),
        const SizedBox(width: 16),
        _buildLikeButton(context),
        const Spacer(),
        if (post.updatedAt.isAfter(post.createdAt.add(const Duration(minutes: 1))))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '已编辑',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange.shade700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String count) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLikeButton(BuildContext context) {
    return Consumer<ForumProvider>(
      builder: (context, forumProvider, child) {
        return InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => _handleLike(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.thumb_up_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  post.likeCount.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
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
      return DateFormat('MM-dd').format(dateTime);
    }
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        _editPost(context);
        break;
      case 'delete':
        _deletePost(context);
        break;
    }
  }

  void _editPost(BuildContext context) {
    // 导航到编辑页面
    Navigator.pushNamed(
      context,
      '/edit_post',
      arguments: post,
    );
  }

  void _deletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除帖子'),
        content: const Text('确定要删除这个帖子吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final forumProvider = Provider.of<ForumProvider>(
                context,
                listen: false,
              );
              
              final success = await forumProvider.deletePost(post.postId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '删除成功' : '删除失败'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _handleLike(BuildContext context) {
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    forumProvider.togglePostLike(post.postId, true);
  }

  void _navigateToPostDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: post.postId),
      ),
    );
  }
}