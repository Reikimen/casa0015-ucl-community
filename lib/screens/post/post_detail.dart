import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/app_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../auth/login_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final bool initialShowComments;

  const PostDetailScreen({
    Key? key,
    required this.postId,
    this.initialShowComments = false,
  }) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();

  Post? _post;
  List<Comment> _comments = [];
  bool _isLoadingPost = true;
  bool _isLoadingComments = false;
  bool _showComments = false;
  bool _submittingComment = false;

  @override
  void initState() {
    super.initState();
    _showComments = widget.initialShowComments;
    _fetchPostDetail();
    if (_showComments) {
      _fetchComments();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // 获取帖子详情
  Future<void> _fetchPostDetail() async {
    setState(() {
      _isLoadingPost = true;
    });

    try {
      final post = await _apiService.getPostDetail(widget.postId);

      setState(() {
        _post = post;
        _isLoadingPost = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPost = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('获取帖子详情失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 获取评论列表
  Future<void> _fetchComments() async {
    if (_isLoadingComments) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final comments = await _apiService.getPostComments(widget.postId);

      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('获取评论失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 处理点赞
  Future<void> _handleLike() async {
    if (_post == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    // 检查用户是否登录
    if (!userProvider.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('请先登录后再点赞'),
            action: SnackBarAction(
              label: '登录',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),
        );
      }
      return;
    }

    // 执行点赞或取消点赞
    if (_post!.isLiked) {
      final success = await postProvider.unlikePost(_post!.id);
      if (success && mounted) {
        setState(() {
          _post = _post!.copyWith(
            isLiked: false,
            likesCount: _post!.likesCount - 1,
          );
        });
      }
    } else {
      final success = await postProvider.likePost(_post!.id);
      if (success && mounted) {
        setState(() {
          _post = _post!.copyWith(
            isLiked: true,
            likesCount: _post!.likesCount + 1,
          );
        });
      }
    }
  }

  // 提交评论
  Future<void> _submitComment() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    // 检查用户是否登录
    if (!userProvider.isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appProvider.getLocalizedString(
                '请先登录后再评论',
                'Please login before commenting',
              ),
            ),
            action: SnackBarAction(
              label: appProvider.getLocalizedString('登录', 'Login'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),
        );
      }
      return;
    }

    // 验证评论内容
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appProvider.getLocalizedString(
                '评论内容不能为空',
                'Comment cannot be empty',
              ),
            ),
          ),
        );
      }
      return;
    }

    // 提交评论
    setState(() {
      _submittingComment = true;
    });

    try {
      final success = await _apiService.createComment(widget.postId, comment);

      if (success) {
        // 成功提交评论，刷新评论列表
        _commentController.clear();
        _fetchComments();

        // 更新帖子评论数
        setState(() {
          if (_post != null) {
            _post = _post!.copyWith(
              commentsCount: _post!.commentsCount + 1,
            );
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                appProvider.getLocalizedString(
                  '评论发送失败',
                  'Failed to send comment',
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appProvider.getLocalizedString(
                '评论发送出错: $e',
                'Error sending comment: $e',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _submittingComment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appProvider.getLocalizedString('帖子详情', 'Post Detail'),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          // 分享按钮
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final postProvider = Provider.of<PostProvider>(context, listen: false);
              postProvider.sharePost(widget.postId);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    appProvider.getLocalizedString(
                      '已分享到其他应用',
                      'Shared to other apps',
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoadingPost
          ? const Center(child: CircularProgressIndicator())
          : _post == null
          ? Center(
        child: Text(
          appProvider.getLocalizedString(
            '加载帖子失败',
            'Failed to load post',
          ),
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[700],
          ),
        ),
      )
          : Column(
        children: [
          // 帖子内容
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 帖子封面图片
                  CachedNetworkImage(
                    imageUrl: _post!.imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),

                  // 帖子标题和内容
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Text(
                          _post!.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 作者信息和发布时间
                        Row(
                          children: [
                            // 作者头像
                            if (_post!.authorAvatar != null)
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: CachedNetworkImageProvider(_post!.authorAvatar!),
                              )
                            else
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: Color(0xFFE53935),
                                child: Icon(Icons.person, size: 16, color: Colors.white),
                              ),

                            const SizedBox(width: 8),

                            // 作者名称
                            Text(
                              _post!.authorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Spacer(),

                            // 发布时间
                            Text(
                              _getFormattedDate(_post!.createdAt, appProvider.isEnglish),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 内容
                        Text(
                          _post!.content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 互动按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // 点赞按钮
                            _buildActionButton(
                              icon: _post!.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _post!.isLiked
                                  ? const Color(0xFFE53935)
                                  : Colors.black54,
                              label: '${_post!.likesCount}',
                              onPressed: _handleLike,
                            ),

                            // 评论按钮
                            _buildActionButton(
                              icon: Icons.comment_outlined,
                              label: '${_post!.commentsCount}',
                              onPressed: () {
                                setState(() {
                                  _showComments = !_showComments;
                                  if (_showComments && _comments.isEmpty) {
                                    _fetchComments();
                                  }
                                });
                              },
                            ),

                            // 分享按钮
                            _buildActionButton(
                              icon: Icons.share_outlined,
                              label: appProvider.getLocalizedString('分享', 'Share'),
                              onPressed: () {
                                final postProvider = Provider.of<PostProvider>(context, listen: false);
                                postProvider.sharePost(_post!.id);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      appProvider.getLocalizedString(
                                        '已分享到其他应用',
                                        'Shared to other apps',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        // 评论分割线
                        if (_showComments)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey[400])),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    appProvider.getLocalizedString(
                                      '评论',
                                      'Comments',
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey[400])),
                              ],
                            ),
                          ),

                        // 评论列表
                        if (_showComments)
                          _isLoadingComments
                              ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                              : _comments.isEmpty
                              ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                appProvider.getLocalizedString(
                                  '暂无评论，快来发表第一条评论吧',
                                  'No comments yet, be the first to comment',
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return _buildCommentItem(comment, appProvider);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 评论输入框
          if (_showComments)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 输入框
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: appProvider.getLocalizedString(
                          '写下你的评论...',
                          'Write your comment...',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: 1,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 发送按钮
                  _submittingComment
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
                    ),
                  )
                      : IconButton(
                    icon: const Icon(Icons.send),
                    color: const Color(0xFFE53935),
                    onPressed: _submitComment,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 构建互动按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.black54,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建评论项
  Widget _buildCommentItem(Comment comment, AppProvider appProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户头像
          if (comment.authorAvatar != null)
            CircleAvatar(
              radius: 18,
              backgroundImage: CachedNetworkImageProvider(comment.authorAvatar!),
            )
          else
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE53935),
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),

          const SizedBox(width: 12),

          // 评论内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户名和时间
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _getFormattedDate(comment.createdAt, appProvider.isEnglish),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // 评论内容
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 格式化日期
  String _getFormattedDate(DateTime dateTime, bool isEnglish) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return isEnglish ? '$years years ago' : '$years年前';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return isEnglish ? '$months months ago' : '$months个月前';
    } else if (difference.inDays > 0) {
      return isEnglish ? '${difference.inDays} days ago' : '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return isEnglish ? '${difference.inHours} hours ago' : '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return isEnglish ? '${difference.inMinutes} mins ago' : '${difference.inMinutes}分钟前';
    } else {
      return isEnglish ? 'Just now' : '刚刚';
    }
  }
}