import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/forum_provider.dart';
import '../providers/user_provider.dart';
import '../providers/course_provider.dart';
import '../models/forum_post.dart';
import '../widgets/forum_post_card.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  int? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    _tabController.addListener(_onTabChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    
    forumProvider.loadPosts(refresh: true);
    courseProvider.loadAllCourses();
  }

  void _onTabChanged() {
    if (_tabController.index == 2) { // "我的" tab
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (userProvider.currentUser != null && forumProvider.userPosts.isEmpty) {
        forumProvider.loadUserPosts(userProvider.currentUser!.userId, refresh: true);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      
      switch (_tabController.index) {
        case 0:
          forumProvider.loadPosts();
          break;
        case 1:
          if (_selectedCourseId != null) {
            forumProvider.loadPostsByCourse(_selectedCourseId!);
          }
          break;
        case 2:
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          if (userProvider.currentUser != null) {
            forumProvider.loadUserPosts(userProvider.currentUser!.userId);
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习论坛'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部', icon: Icon(Icons.public)),
            Tab(text: '课程', icon: Icon(Icons.school)),
            Tab(text: '我的', icon: Icon(Icons.person)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_tabController.index == 1) _buildCourseFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllPostsTab(),
                _buildCoursePostsTab(),
                _buildMyPostsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewPost,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCourseFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          final courses = courseProvider.allCourses;
          
          return DropdownButtonFormField<int?>(
            value: _selectedCourseId,
            decoration: const InputDecoration(
              labelText: '选择课程',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('全部课程'),
              ),
              ...courses.map((course) => DropdownMenuItem<int?>(
                value: course.courseId,
                child: Text(course.courseName),
              )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCourseId = value;
              });
              
              final forumProvider = Provider.of<ForumProvider>(context, listen: false);
              if (value != null) {
                forumProvider.loadPostsByCourse(value, refresh: true);
              } else {
                forumProvider.loadPosts(refresh: true);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildAllPostsTab() {
    return Consumer<ForumProvider>(
      builder: (context, forumProvider, child) {
        if (forumProvider.isLoading && forumProvider.posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (forumProvider.posts.isEmpty) {
          return _buildEmptyState('还没有帖子', '成为第一个发帖的人吧！');
        }

        return RefreshIndicator(
          onRefresh: () => forumProvider.loadPosts(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: forumProvider.posts.length + 
                (forumProvider.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == forumProvider.posts.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              return ForumPostCard(
                post: forumProvider.posts[index],
                onTap: () => _navigateToPostDetail(forumProvider.posts[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCoursePostsTab() {
    return Consumer<ForumProvider>(
      builder: (context, forumProvider, child) {
        if (_selectedCourseId == null) {
          return _buildEmptyState('请选择课程', '选择一个课程查看相关讨论');
        }

        if (forumProvider.isLoading && forumProvider.coursePosts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (forumProvider.coursePosts.isEmpty) {
          return _buildEmptyState('该课程还没有讨论', '开始第一个讨论吧！');
        }

        return RefreshIndicator(
          onRefresh: () => forumProvider.loadPostsByCourse(_selectedCourseId!, refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: forumProvider.coursePosts.length + 
                (forumProvider.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == forumProvider.coursePosts.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              return ForumPostCard(
                post: forumProvider.coursePosts[index],
                onTap: () => _navigateToPostDetail(forumProvider.coursePosts[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMyPostsTab() {
    return Consumer2<ForumProvider, UserProvider>(
      builder: (context, forumProvider, userProvider, child) {
        if (userProvider.currentUser == null) {
          return _buildEmptyState('请先登录', '登录后查看您的帖子');
        }

        if (forumProvider.isLoading && forumProvider.userPosts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (forumProvider.userPosts.isEmpty) {
          return _buildEmptyState('您还没有发布帖子', '发布第一个帖子分享您的想法！');
        }

        return RefreshIndicator(
          onRefresh: () => forumProvider.loadUserPosts(
            userProvider.currentUser!.userId, 
            refresh: true
          ),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: forumProvider.userPosts.length + 
                (forumProvider.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == forumProvider.userPosts.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              return ForumPostCard(
                post: forumProvider.userPosts[index],
                onTap: () => _navigateToPostDetail(forumProvider.userPosts[index]),
                showActions: true, // 显示编辑/删除按钮
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索帖子'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '输入关键词...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                Navigator.pop(context);
                _performSearch(_searchController.text);
              }
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String keyword) {
    final forumProvider = Provider.of<ForumProvider>(context, listen: false);
    forumProvider.searchPosts(keyword, refresh: true);
    
    // 显示搜索结果页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(keyword: keyword),
      ),
    );
  }

  void _createNewPost() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(
          courseId: _selectedCourseId,
        ),
      ),
    );
  }

  void _navigateToPostDetail(ForumPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(postId: post.postId),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// 搜索结果页面
class SearchResultsScreen extends StatelessWidget {
  final String keyword;

  const SearchResultsScreen({super.key, required this.keyword});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('搜索: $keyword'),
      ),
      body: Consumer<ForumProvider>(
        builder: (context, forumProvider, child) {
          if (forumProvider.isLoading && forumProvider.searchResults.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (forumProvider.searchResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '没有找到相关帖子',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '尝试使用其他关键词搜索',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: forumProvider.searchResults.length,
            itemBuilder: (context, index) {
              return ForumPostCard(
                post: forumProvider.searchResults[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(
                        postId: forumProvider.searchResults[index].postId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}