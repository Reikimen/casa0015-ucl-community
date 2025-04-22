import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/shake_detector.dart';
import 'stared_tab.dart';
import 'explore_tab.dart';
import 'hot_tab.dart';
import '../post/post_create.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 监听标签切换
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // 更新当前标签
        final provider = Provider.of<PostProvider>(context, listen: false);
        provider.setCurrentTab(HomeTab.values[_tabController.index]);
      }
    });

    // 延迟执行，等待组件完全加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 检查登录状态
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.checkLoginStatus();

      // 加载初始标签数据
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.setCurrentTab(HomeTab.explore); // 默认选中"发现"
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appProvider.getLocalizedString('校园社区', 'Campus Social'),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE53935), // 选中标签颜色
          unselectedLabelColor: Colors.black54, // 未选中标签颜色
          indicatorColor: const Color(0xFFE53935), // 指示器颜色
          tabs: [
            Tab(
              icon: const Icon(Icons.star),
              text: appProvider.getLocalizedString('关注', 'Stared'),
            ),
            Tab(
              icon: const Icon(Icons.explore),
              text: appProvider.getLocalizedString('发现', 'Explore'),
            ),
            Tab(
              icon: const Icon(Icons.whatshot),
              text: appProvider.getLocalizedString('热门', 'Hot'),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // 标签页内容
          TabBarView(
            controller: _tabController,
            children: const [
              StaredTab(),
              ExploreTab(),
              HotTab(),
            ],
          ),

          // 摇一摇检测器
          ShakeDetector(),
        ],
      ),
      // 悬浮按钮 - 创建新帖子
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePostDialog(context);
        },
        backgroundColor: const Color(0xFFE53935),
        child: const Icon(Icons.add),
      ),
    );
  }

  // 显示创建帖子对话框
  void _showCreatePostDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const PostCreateScreen(),
      ),
    );
  }
}