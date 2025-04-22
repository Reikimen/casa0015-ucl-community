import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/post_card.dart';
import '../auth/login_screen.dart';

class StaredTab extends StatelessWidget {
  const StaredTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    // 检查用户是否登录
    if (!userProvider.isLoggedIn) {
      return _buildLoginPrompt(context, appProvider);
    }

    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        // 获取关注的帖子
        final posts = postProvider.staredPosts;
        final isLoading = postProvider.isLoadingStared;

        return isLoading
            ? _buildLoadingIndicator()
            : posts.isEmpty
            ? _buildEmptyView(appProvider)
            : _buildPostsList(posts);
      },
    );
  }

  // 构建登录提示
  Widget _buildLoginPrompt(BuildContext context, AppProvider appProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            appProvider.getLocalizedString(
              '登录后查看关注内容',
              'Login to view stared content',
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              appProvider.getLocalizedString('去登录', 'Login Now'),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // 构建加载指示器
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
      ),
    );
  }

  // 构建空内容视图
  Widget _buildEmptyView(AppProvider appProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            appProvider.getLocalizedString(
              '暂无关注内容',
              'No stared content yet',
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appProvider.getLocalizedString(
              '去"发现"页面关注你感兴趣的内容吧',
              'Go to "Explore" to find content you\'re interested in',
            ),
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

  // 构建帖子列表
  Widget _buildPostsList(List<dynamic> posts) {
    return RefreshIndicator(
      color: const Color(0xFFE53935),
      onRefresh: () async {
        // 下拉刷新
        final postProvider = Provider.of<PostProvider>(
          navigatorKey.currentContext!,
          listen: false,
        );
        await postProvider.fetchStaredPosts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: posts[index]);
        },
      ),
    );
  }

  // 全局导航键
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}