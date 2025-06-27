import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/forum_provider.dart';
import '../providers/user_provider.dart';
import '../providers/course_provider.dart';

class CreatePostScreen extends StatefulWidget {
  final int? courseId;

  const CreatePostScreen({super.key, this.courseId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int? _selectedCourseId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.courseId;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      if (courseProvider.allCourses.isEmpty) {
        courseProvider.loadAllCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布帖子'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '发布',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCourseSelector(),
              const SizedBox(height: 16),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildContentField(),
              const SizedBox(height: 24),
              _buildTips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择课程（可选）',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Consumer<CourseProvider>(
          builder: (context, courseProvider, child) {
            if (courseProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final courses = courseProvider.allCourses;
            
            return DropdownButtonFormField<int?>(
              value: _selectedCourseId,
              decoration: const InputDecoration(
                hintText: '选择相关课程（可选）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('通用讨论'),
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
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标题',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '请输入帖子标题...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          maxLength: 100,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入标题';
            }
            if (value.trim().length < 5) {
              return '标题至少需要5个字符';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '内容',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(
            hintText: '分享您的想法、问题或经验...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 10,
          minLines: 6,
          maxLength: 2000,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入内容';
            }
            if (value.trim().length < 10) {
              return '内容至少需要10个字符';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '发帖小贴士',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• 使用清晰、描述性的标题\n'
            '• 详细描述您的问题或想法\n'
            '• 选择相关的课程分类\n'
            '• 保持友善和尊重的语调\n'
            '• 避免发布重复内容',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
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
      _isLoading = true;
    });

    try {
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      final success = await forumProvider.createPost(
        courseId: _selectedCourseId,
        userId: userProvider.currentUser!.userId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('发布成功！'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // 返回true表示发布成功
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(forumProvider.errorMessage ?? '发布失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发布失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}