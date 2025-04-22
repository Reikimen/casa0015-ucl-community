import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/app_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../models/post_model.dart';
import '../../widgets/post_card.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Post> _userPosts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 创建标签控制器（发布内容和收藏内容）
    _tabController = TabController(length: 2, vsync: this);

    // 延迟加载用户帖子
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserPosts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 加载用户发布的帖子
  Future<void> _loadUserPosts() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 如果用户未登录，无需加载
    if (!userProvider.isLoggedIn) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final userId = widget.userId ?? userProvider.currentUser!.id;
      final posts = await apiService.getUserPosts(userId);

      setState(() {
        _userPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // 检查用户是否登录
    if (!userProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            appProvider.getLocalizedString('个人资料', 'Profile'),
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                appProvider.getLocalizedString(
                  '请先登录',
                  'Please login first',
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  appProvider.getLocalizedString('去登录', 'Login Now'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            // 顶部应用栏（头像、用户名、数据统计）
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.black),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(userProvider.currentUser!),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFE53935),
                unselectedLabelColor: Colors.black54,
                indicatorColor: const Color(0xFFE53935),
                tabs: [
                  Tab(text: appProvider.getLocalizedString('发布', 'Posts')),
                  Tab(text: appProvider.getLocalizedString('收藏', 'Collections')),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // 发布内容标签页
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _userPosts.isEmpty
                ? _buildEmptyView(
              appProvider.getLocalizedString(
                '暂无发布内容',
                'No posts yet',
              ),
              appProvider.getLocalizedString(
                '你的发布内容将显示在这里',
                'Your posts will appear here',
              ),
            )
                : _buildPostsGrid(_userPosts),

            // 收藏内容标签页
            _buildEmptyView(
              appProvider.getLocalizedString(
                '暂无收藏内容',
                'No collections yet',
              ),
              appProvider.getLocalizedString(
                '你收藏的内容将显示在这里',
                'Your collected posts will appear here',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建个人资料头部
  Widget _buildProfileHeader(dynamic user) {
    final appProvider = Provider.of<AppProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),

          // 用户头像和基本信息
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFFE53935),
                backgroundImage: user.avatar != null
                    ? CachedNetworkImageProvider(user.avatar)
                    : null,
                child: user.avatar == null
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),

              const SizedBox(width: 16),

              // 用户名和学号
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.studentId,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 个人简介
                    if (user.bio != null && user.bio.isNotEmpty)
                      Text(
                        user.bio,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // 编辑按钮
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: 导航到编辑资料页面
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        appProvider.getLocalizedString(
                          '编辑资料功能即将推出',
                          'Edit profile feature coming soon',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 数据统计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                user.followersCount.toString(),
                appProvider.getLocalizedString('粉丝', 'Followers'),
              ),
              _buildStatItem(
                user.followingCount.toString(),
                appProvider.getLocalizedString('关注', 'Following'),
              ),
              _buildStatItem(
                user.likesCount.toString(),
                appProvider.getLocalizedString('获赞', 'Likes'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建数据统计项
  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 构建空视图
  Widget _buildEmptyView(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 构建帖子网格
  Widget _buildPostsGrid(List<Post> posts) {
    return RefreshIndicator(
      onRefresh: _loadUserPosts,
      color: const Color(0xFFE53935),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];

            return GestureDetector(
              onTap: () {
                // TODO: 导航到帖子详情页
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 帖子封面图片
                    CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: index % 3 == 0 ? 200 : 150, // 不同高度的图片，形成错落感
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        height: index % 3 == 0 ? 200 : 150,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        height: index % 3 == 0 ? 200 : 150,
                        child: const Icon(Icons.error),
                      ),
                    ),

                    // 帖子标题
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        post.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // 互动数据
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.likesCount.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.comment,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.commentsCount.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}