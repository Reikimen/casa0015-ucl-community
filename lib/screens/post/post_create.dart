import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';

class PostCreateScreen extends StatefulWidget {
  const PostCreateScreen({Key? key}) : super(key: key);

  @override
  _PostCreateScreenState createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appProvider.getLocalizedString('创建帖子', 'Create Post'),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          // 发布按钮
          _isLoading
              ? const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
                  strokeWidth: 2,
                ),
              ),
            ),
          )
              : TextButton(
            onPressed: _validateAndSubmit,
            child: Text(
              appProvider.getLocalizedString('发布', 'Post'),
              style: const TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片选择区域
            _buildImagePicker(appProvider),

            const SizedBox(height: 16),

            // 标题输入
            TextField(
              controller: _titleController,
              maxLength: 50,
              decoration: InputDecoration(
                hintText: appProvider.getLocalizedString(
                  '请输入标题（必填）',
                  'Enter title (required)',
                ),
                border: const OutlineInputBorder(),
                counterText: '',
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // 内容输入
            TextField(
              controller: _contentController,
              maxLines: 8,
              maxLength: 2000,
              decoration: InputDecoration(
                hintText: appProvider.getLocalizedString(
                  '请输入正文内容（必填）',
                  'Enter content (required)',
                ),
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建图片选择区域
  Widget _buildImagePicker(AppProvider appProvider) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: _selectedImage != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 60,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 8),
            Text(
              appProvider.getLocalizedString(
                '点击上传封面图片（必选）',
                'Tap to upload cover image (required)',
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 选择图片
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // 处理选择图片出错
      debugPrint('选择图片出错: $e');
    }
  }

  // 验证并提交帖子
  void _validateAndSubmit() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 检查用户是否登录
    if (!userProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appProvider.getLocalizedString(
              '请先登录后再发布',
              'Please login before posting',
            ),
          ),
        ),
      );
      return;
    }

    // 验证表单
    String? errorMessage;

    if (_selectedImage == null) {
      errorMessage = appProvider.getLocalizedString(
        '请选择封面图片',
        'Please select a cover image',
      );
    } else if (_titleController.text.trim().isEmpty) {
      errorMessage = appProvider.getLocalizedString(
        '请输入标题',
        'Please enter a title',
      );
    } else if (_contentController.text.trim().isEmpty) {
      errorMessage = appProvider.getLocalizedString(
        '请输入正文内容',
        'Please enter content',
      );
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    // 提交帖子
    _submitPost();
  }

  // 提交帖子
  Future<void> _submitPost() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      // 在实际应用中，这里应该先上传图片，获取图片URL
      // 为演示目的，这里使用假的图片URL
      const String fakeImageUrl = 'https://example.com/images/post-image.jpg';

      // 创建帖子
      final success = await postProvider.createPost(
        _titleController.text.trim(),
        _contentController.text.trim(),
        fakeImageUrl,
      );

      if (success) {
        // 发布成功
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                appProvider.getLocalizedString(
                  '发布成功',
                  'Post published successfully',
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
          // 返回上一页
          Navigator.pop(context);
        }
      } else {
        // 发布失败
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                appProvider.getLocalizedString(
                  '发布失败，请重试',
                  'Failed to publish post, please try again',
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // 处理错误
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appProvider.getLocalizedString(
                '发布时出错: $e',
                'Error during publishing: $e',
              ),
            ),
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
}