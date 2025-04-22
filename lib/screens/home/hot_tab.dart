import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post_card.dart';

class HotTab extends StatelessWidget {
  const HotTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        // 获取热门帖子
        final posts = postProvider.hotPosts;
        final isLoading = postProvider.isLoadingHot;

        return isLoading
            ? _buildLoadingIndicator()
            : posts.isEmpty
            ? _buildEmptyView(appProvider)
            : _buildPostsList(posts);
      },
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
            Icons.whatshot_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            appProvider.getLocalizedString(
              '暂无热门内容',
              'No hot content yet',
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
              '下拉刷新试试',
              'Pull to refresh',
            ),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
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
        await postProvider.fetchHotPosts();
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