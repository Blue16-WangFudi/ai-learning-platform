import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/user_provider.dart';
import '../providers/course_provider.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isEnrolled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkEnrollmentStatus();
  }

  void _checkEnrollmentStatus() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    
    if (userProvider.currentUser != null) {
      _isEnrolled = courseProvider.userCourses
          .any((course) => course.courseId == widget.course.courseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.course.courseName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(widget.course.category ?? '未知'),
                      _getCategoryColor(widget.course.category ?? '未知').withOpacity(0.7),
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          _getCategoryIcon(widget.course.category ?? '未知'),
                          size: 64,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.course.category ?? '未知',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 课程基本信息
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '讲师：${widget.course.instructor}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.course.duration}小时',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (widget.course.rating ?? 0.0).toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.signal_cellular_alt,
                                size: 16,
                                color: _getDifficultyColor(widget.course.difficulty),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.course.difficulty,
                                style: TextStyle(
                                  color: _getDifficultyColor(widget.course.difficulty),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 课程描述
                  const Text(
                    '课程介绍',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.course.description ?? '暂无描述',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 课程大纲
                  const Text(
                    '课程大纲',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: _buildCourseOutline(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 选课按钮
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEnrollment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEnrolled 
                            ? Colors.grey.shade400 
                            : Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isEnrolled ? '已选课程' : '选择课程',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCourseOutline() {
    // 模拟课程大纲数据
    final List<String> outline = [
      '第1章：基础概念介绍',
      '第2章：核心理论学习',
      '第3章：实践操作演示',
      '第4章：案例分析讨论',
      '第5章：项目实战练习',
      '第6章：总结与拓展',
    ];

    return outline.asMap().entries.map((entry) {
      final index = entry.key;
      final title = entry.value;
      final isLast = index == outline.length - 1;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isLast ? null : Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.play_circle_outline,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      );
    }).toList();
  }

  void _handleEnrollment() async {
    if (_isEnrolled) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    if (userProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先登录'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await courseProvider.enrollCourse(
        userProvider.currentUser!.userId,
        widget.course.courseId,
      );

      if (courseProvider.errorMessage == null) {
        setState(() {
          _isEnrolled = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('选课成功！'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 重新加载用户课程
        await courseProvider.loadUserCourses(userProvider.currentUser!.userId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(courseProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('选课失败：$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case '人工智能':
        return Colors.blue;
      case '机器学习':
        return Colors.green;
      case '深度学习':
        return Colors.purple;
      case '数据科学':
        return Colors.orange;
      case '自然语言处理':
        return Colors.teal;
      case '计算机视觉':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case '人工智能':
        return Icons.psychology;
      case '机器学习':
        return Icons.auto_graph;
      case '深度学习':
        return Icons.device_hub;
      case '数据科学':
        return Icons.analytics;
      case '自然语言处理':
        return Icons.chat;
      case '计算机视觉':
        return Icons.visibility;
      default:
        return Icons.school;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case '初级':
        return Colors.green;
      case '中级':
        return Colors.orange;
      case '高级':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}