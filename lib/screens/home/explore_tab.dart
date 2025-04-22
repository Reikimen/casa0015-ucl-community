import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post_card.dart';
import '../../widgets/subcategory_bar.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        // 获取当前探索分类的帖子
        final posts = postProvider.explorePosts;
        final isLoading = postProvider.isLoadingExplore;

        return Column(
          children: [
            // 子分类导航栏
            const SubcategoryBar(),

            // 帖子列表
            Expanded(
              child: isLoading
                  ? _buildLoadingIndicator()
                  : posts.isEmpty
                  ? _buildEmptyView()
                  : _buildPostsList(posts),
            ),
          ],
        );
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
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无内容',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试切换其他分类或下拉刷新',
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
        await postProvider.fetchExplorePosts();
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