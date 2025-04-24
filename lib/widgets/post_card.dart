import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post_model.dart';
import '../providers/app_provider.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';
import '../screens/post/post_detail.dart';
import '../screens/auth/login_screen.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String _translatedTitle = '';
  String _translatedContent = '';
  bool _isTranslating = false;
  bool _translationCompleted = false;
  // Add a flag to track if translation is needed
  bool _needsTranslation = false;
  // Add language state tracking
  bool _lastIsEnglish = false;
  bool _lastAutoTranslate = false;

  @override
  void initState() {
    super.initState();
    _translatedTitle = widget.post.title;
    _translatedContent = widget.post.content;

    // Initial check for translation needs will be done in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final appProvider = Provider.of<AppProvider>(context, listen: false);

    // Track if language settings have changed
    bool settingsChanged = appProvider.isEnglish != _lastIsEnglish ||
        appProvider.autoTranslate != _lastAutoTranslate;

    // Update cached settings
    _lastIsEnglish = appProvider.isEnglish;
    _lastAutoTranslate = appProvider.autoTranslate;

    // Only translate if settings changed or it wasn't translated before
    if ((settingsChanged || !_translationCompleted) &&
        appProvider.isEnglish &&
        appProvider.autoTranslate &&
        !_isTranslating) {
      _translateContent();
    }
  }

  // Simplified translation content method
  Future<void> _translateContent() async {
    // Prevent duplicate translation requests
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);

      // Translate title
      final translatedTitle = await appProvider.translateText(
        widget.post.title,
        toEnglish: appProvider.isEnglish,
      );

      // Translate content
      final translatedContent = await appProvider.translateText(
        widget.post.content,
        toEnglish: appProvider.isEnglish,
      );

      if (mounted) {
        setState(() {
          _translatedTitle = translatedTitle;
          _translatedContent = translatedContent;
          _isTranslating = false;
          _translationCompleted = true;
          _needsTranslation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          // Don't mark as completed if there was an error
          _needsTranslation = true;
        });
      }
      debugPrint('翻译内容出错: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Determine if we need to display translated content
    final shouldShowTranslated = appProvider.isEnglish &&
        appProvider.autoTranslate &&
        _translationCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // 点击进入帖子详情页
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(postId: widget.post.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 帖子封面图片
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.post.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),

            // 帖子内容
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题 (可能是翻译后的)
                  _isTranslating
                      ? _buildTranslatingIndicator()
                      : Text(
                    shouldShowTranslated ? _translatedTitle : widget.post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // 内容预览 (可能是翻译后的)
                  _isTranslating
                      ? _buildTranslatingIndicator()
                      : Text(
                    shouldShowTranslated ? _translatedContent : widget.post.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // 作者信息和发布时间
                  Row(
                    children: [
                      // 作者头像
                      if (widget.post.authorAvatar != null)
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: CachedNetworkImageProvider(widget.post.authorAvatar!),
                        )
                      else
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFE53935),
                          child: Icon(Icons.person, size: 20, color: Colors.white),
                        ),

                      const SizedBox(width: 8),

                      // 作者名称
                      Expanded(
                        child: Text(
                          widget.post.authorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 发布时间
                      Text(
                        _getFormattedDate(widget.post.createdAt, appProvider.isEnglish),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // 互动按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // 点赞按钮
                      _buildActionButton(
                        icon: widget.post.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.post.isLiked
                            ? const Color(0xFFE53935)
                            : Colors.black54,
                        label: '${widget.post.likesCount}',
                        onPressed: () {
                          _handleLike(context, userProvider, postProvider);
                        },
                      ),

                      // 评论按钮
                      _buildActionButton(
                        icon: Icons.comment_outlined,
                        label: '${widget.post.commentsCount}',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                postId: widget.post.id,
                                initialShowComments: true,
                              ),
                            ),
                          );
                        },
                      ),

                      // 分享按钮
                      _buildActionButton(
                        icon: Icons.share_outlined,
                        label: appProvider.getLocalizedString('分享', 'Share'),
                        onPressed: () {
                          // 调用分享功能
                          postProvider.sharePost(widget.post.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(appProvider.getLocalizedString(
                                '已分享到其他应用',
                                'Shared to other apps',
                              )),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建翻译中指示器
  Widget _buildTranslatingIndicator() {
    return Row(
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Translating...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 处理点赞逻辑
  void _handleLike(
      BuildContext context,
      UserProvider userProvider,
      PostProvider postProvider,
      ) {
    // 检查用户是否登录
    if (!userProvider.isLoggedIn) {
      // 提示用户登录
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
      return;
    }

    // 如果已经点赞，则取消点赞，否则添加点赞
    if (widget.post.isLiked) {
      postProvider.unlikePost(widget.post.id);
    } else {
      postProvider.likePost(widget.post.id);
    }
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