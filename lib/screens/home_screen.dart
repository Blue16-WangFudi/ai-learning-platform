import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/user_provider.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';
import 'profile_screen.dart';
import 'forum_screen.dart';
import 'create_course_screen.dart';
import 'teacher_courses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // 加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // 根据用户角色初始化TabController
      final isTeacher = userProvider.currentUser?.isTeacher ?? false;
      _tabController = TabController(length: isTeacher ? 3 : 2, vsync: this);
      
      courseProvider.loadAllCourses();
      if (userProvider.currentUser != null) {
        courseProvider.loadUserCourses(userProvider.currentUser!.userId);
        if (isTeacher) {
          courseProvider.loadTeacherCourses(userProvider.currentUser!.userId);
        }
      }
      
      // 触发重建以显示正确的标签页
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const ForumScreen();
      case 2:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _getSelectedScreen(),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey.shade600,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  activeIcon: Icon(Icons.home_rounded),
                  label: '首页',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum_outlined),
                  activeIcon: Icon(Icons.forum),
                  label: '论坛',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: '我的',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: const Text(
                '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade400,
                      Colors.purple.shade500,
                      Colors.pink.shade400,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // 背景装饰
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // 主要内容
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 50),
                          Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              return Text(
                                '欢迎回来，${userProvider.currentUser?.realName ?? '王同学'}！',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '开始您的学习之旅',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: Column(
        children: [
          // 搜索栏
          Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索您感兴趣的课程...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey.shade600,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          final courseProvider = Provider.of<CourseProvider>(context, listen: false);
                          courseProvider.loadAllCourses();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  final courseProvider = Provider.of<CourseProvider>(context, listen: false);
                  courseProvider.searchCourses(value);
                }
              },
            ),
          ),
          // 标签栏
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final isTeacher = userProvider.currentUser?.isTeacher ?? false;
              
              // 如果TabController还未初始化，显示加载状态
              if (_tabController == null) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  tabs: [
                    const Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('全部课程'),
                      ),
                    ),
                    const Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('我的课程'),
                      ),
                    ),
                    if (isTeacher)
                      const Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('我的教学'),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          // 展开的标签页视图
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final isTeacher = userProvider.currentUser?.isTeacher ?? false;
                  
                  // 如果TabController还未初始化，显示加载状态
                  if (_tabController == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllCoursesTab(),
                      _buildMyCoursesTab(),
                      if (isTeacher) _buildTeacherCoursesTab(),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCoursesTab() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        if (courseProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final courses = _searchController.text.isNotEmpty
            ? courseProvider.searchResults
            : courseProvider.allCourses;

        if (courses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isNotEmpty ? '未找到相关课程' : '暂无课程',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CourseCard(
                course: course,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CourseDetailScreen(course: course),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyCoursesTab() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        if (courseProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final courses = courseProvider.userCourses;

        if (courses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  '您还没有选择任何课程',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '去全部课程中选择感兴趣的课程吧！',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CourseCard(
                course: course,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CourseDetailScreen(course: course),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTeacherCoursesTab() {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        if (courseProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final courses = courseProvider.teacherCourses;

        return Column(
          children: [
            // 创建课程按钮
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateCourseScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('创建新课程'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            // 课程管理按钮
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TeacherCoursesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.manage_accounts_rounded),
                label: const Text('管理我的课程'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // 课程列表
            Expanded(
              child: courses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '您还没有创建任何课程',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '点击上方按钮开始创建您的第一门课程！',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CourseCard(
                            course: course,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailScreen(course: course),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileContent() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('个人中心'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade600, Colors.purple.shade600],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            user?.realName.substring(0, 1) ?? 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user?.realName ?? '未知用户',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildProfileItem(
                  icon: Icons.person,
                  title: '用户名',
                  subtitle: user?.username ?? '',
                ),
                _buildProfileItem(
                  icon: Icons.email,
                  title: '邮箱',
                  subtitle: user?.email ?? '',
                ),
                _buildProfileItem(
                  icon: Icons.phone,
                  title: '手机号',
                  subtitle: user?.phone ?? '未设置',
                ),
                _buildProfileItem(
                  icon: Icons.access_time,
                  title: '最后登录',
                  subtitle: user?.lastLogin?.toString().split('.')[0] ?? '未知',
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      _showLogoutDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('退出登录'),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('您确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}