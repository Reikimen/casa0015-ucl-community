import 'package:flutter/material.dart';
import 'dart:math';
import '../models/post_model.dart';
import '../services/api_service.dart';

enum HomeTab { stared, explore, hot }
enum ExploreCategory { recommended, study, activity, lostFound, food, accommodation }

class PostProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Random _random = Random();

  // 当前选中的主标签
  HomeTab _currentTab = HomeTab.explore;

  // 当前选中的子分类 (仅在Explore标签下有效)
  ExploreCategory _currentCategory = ExploreCategory.recommended;

  // 帖子数据
  List<Post> _staredPosts = [];
  List<Post> _explorePosts = [];
  List<Post> _hotPosts = [];

  // 加载状态
  bool _isLoadingStared = false;
  bool _isLoadingExplore = false;
  bool _isLoadingHot = false;

  // Getters
  HomeTab get currentTab => _currentTab;
  ExploreCategory get currentCategory => _currentCategory;

  List<Post> get staredPosts => _staredPosts;
  List<Post> get explorePosts => _explorePosts;
  List<Post> get hotPosts => _hotPosts;

  bool get isLoadingStared => _isLoadingStared;
  bool get isLoadingExplore => _isLoadingExplore;
  bool get isLoadingHot => _isLoadingHot;

  // 当前标签下的帖子列表
  List<Post> get currentPosts {
    switch (_currentTab) {
      case HomeTab.stared:
        return _staredPosts;
      case HomeTab.explore:
        return _explorePosts;
      case HomeTab.hot:
        return _hotPosts;
    }
  }

  // 预定义的内置帖子集合
  final List<Post> _builtInPosts = [
    // 推荐分类帖子
    Post(
      id: 'rec1',
      title: '校园社区App正式发布啦！',
      content: '今天，我们很高兴地宣布校园社区App正式发布！欢迎大家下载使用，分享校园生活的精彩瞬间。',
      imageUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1',
      authorId: 'admin1',
      authorName: '校园官方',
      authorAvatar: 'https://randomuser.me/api/portraits/men/1.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likesCount: 120,
      commentsCount: 28,
    ),
    Post(
      id: 'rec2',
      title: '如何高效利用图书馆资源？',
      content: '图书馆不仅有丰富的纸质书籍，还有各种电子资源和学习空间。本文分享如何充分利用这些资源提升学习效果。',
      imageUrl: 'https://images.unsplash.com/photo-1521587760476-6c12a4b040da',
      authorId: 'prof1',
      authorName: '学习达人',
      authorAvatar: 'https://randomuser.me/api/portraits/women/2.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      likesCount: 88,
      commentsCount: 15,
    ),
    Post(
      id: 'rec3',
      title: '校园美食攻略：隐藏的美食地图',
      content: '除了食堂，校园周围还有很多美食宝藏等你发现。跟着这份地图，品尝不一样的校园生活！',
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
      authorId: 'foodie1',
      authorName: '美食猎人',
      authorAvatar: 'https://randomuser.me/api/portraits/men/3.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      likesCount: 156,
      commentsCount: 42,
    ),
    Post(
      id: 'rec4',
      title: '校园摄影大赛获奖作品展示',
      content: '上周举办的校园摄影大赛圆满结束，这里展示部分获奖作品，感受同学们眼中的校园之美。',
      imageUrl: 'https://images.unsplash.com/photo-1606761568499-6d2451b23c66',
      authorId: 'photo1',
      authorName: '摄影社',
      authorAvatar: 'https://randomuser.me/api/portraits/women/4.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      likesCount: 210,
      commentsCount: 35,
    ),
    Post(
      id: 'rec5',
      title: '期末复习指南：高效备考策略',
      content: '期末季即将到来，如何高效备考？本文分享时间管理和学习方法，帮你轻松应对期末考试。',
      imageUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173',
      authorId: 'study1',
      authorName: '学霸笔记',
      authorAvatar: 'https://randomuser.me/api/portraits/men/5.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      likesCount: 175,
      commentsCount: 48,
    ),

    // 学习分类帖子
    Post(
      id: 'study1',
      title: '高数期中复习重点总结',
      content: '整理了高等数学上册期中考试的重点内容和典型题目分析，希望对大家有所帮助。',
      imageUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173',
      authorId: 'math1',
      authorName: '数学爱好者',
      authorAvatar: 'https://randomuser.me/api/portraits/men/10.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      likesCount: 95,
      commentsCount: 23,
    ),
    Post(
      id: 'study2',
      title: '英语四六级备考资料分享',
      content: '整理了一份英语四六级考试的备考资料，包括听力、阅读、写作等各部分的技巧和练习方法。',
      imageUrl: 'https://images.unsplash.com/photo-1495465798138-718f86d1a4bc',
      authorId: 'english1',
      authorName: '英语角',
      authorAvatar: 'https://randomuser.me/api/portraits/women/11.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      likesCount: 128,
      commentsCount: 36,
    ),

    // 活动分类帖子
    Post(
      id: 'activity1',
      title: '校园歌手大赛报名开始啦！',
      content: '一年一度的校园歌手大赛正式开始报名，欢迎所有热爱音乐的同学参与，展示你的才华！',
      imageUrl: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a',
      authorId: 'music1',
      authorName: '校园音乐会',
      authorAvatar: 'https://randomuser.me/api/portraits/men/20.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likesCount: 87,
      commentsCount: 19,
    ),
    Post(
      id: 'activity2',
      title: '志愿者服务活动招募',
      content: '本周末将组织社区关爱老人志愿服务，欢迎有爱心的同学参与，共同传递温暖。',
      imageUrl: 'https://images.unsplash.com/photo-1559027615-cd4628902d4a',
      authorId: 'volunteer1',
      authorName: '志愿者协会',
      authorAvatar: 'https://randomuser.me/api/portraits/women/21.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      likesCount: 65,
      commentsCount: 12,
    ),

    // 失物招领分类帖子
    Post(
      id: 'lost1',
      title: '寻物启事：黑色笔记本电脑',
      content: '昨天下午在图书馆三楼遗失一台黑色Dell笔记本电脑，有发现的同学请联系我，万分感谢！',
      imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853',
      authorId: 'user30',
      authorName: '小明',
      authorAvatar: 'https://randomuser.me/api/portraits/men/30.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 15)),
      likesCount: 12,
      commentsCount: 8,
    ),
    Post(
      id: 'lost2',
      title: '招领：一把银色钥匙',
      content: '在教学楼B区捡到一把银色钥匙，上面有蓝色挂饰，失主请与我联系认领。',
      imageUrl: 'https://images.unsplash.com/photo-1582879304271-6f93bd8324e4',
      authorId: 'user31',
      authorName: '小红',
      authorAvatar: 'https://randomuser.me/api/portraits/women/31.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likesCount: 8,
      commentsCount: 3,
    ),

    // 美食分类帖子
    Post(
      id: 'food1',
      title: '学校周边新开的泰国料理，太好吃了！',
      content: '昨天发现学校北门新开了一家泰国料理店，菜品正宗美味，价格也很实惠，强烈推荐大家尝试！',
      imageUrl: 'https://images.unsplash.com/photo-1559847844-5315695dadae',
      authorId: 'foodie2',
      authorName: '吃货小王',
      authorAvatar: 'https://randomuser.me/api/portraits/men/40.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likesCount: 78,
      commentsCount: 25,
    ),
    Post(
      id: 'food2',
      title: '食堂隐藏菜单大公开',
      content: '整理了学校各个食堂的"隐藏菜单"，告诉你如何点出不在菜单上的美味佳肴！',
      imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352',
      authorId: 'foodie3',
      authorName: '校园美食家',
      authorAvatar: 'https://randomuser.me/api/portraits/women/41.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      likesCount: 132,
      commentsCount: 47,
    ),

    // 住宿分类帖子
    Post(
      id: 'accommodation1',
      title: '宿舍布置技巧分享',
      content: '分享如何利用有限空间，打造温馨舒适的宿舍环境，让你的大学生活更有品质。',
      imageUrl: 'https://images.unsplash.com/photo-1554995207-c18c203602cb',
      authorId: 'design1',
      authorName: '宿舍改造王',
      authorAvatar: 'https://randomuser.me/api/portraits/men/50.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      likesCount: 95,
      commentsCount: 31,
    ),
    Post(
      id: 'accommodation2',
      title: '校外租房注意事项',
      content: '计划校外租房的同学必看！总结了租房流程、合同陷阱、安全隐患等方面的注意事项。',
      imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
      authorId: 'house1',
      authorName: '租房顾问',
      authorAvatar: 'https://randomuser.me/api/portraits/women/51.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      likesCount: 86,
      commentsCount: 29,
    ),
  ];

  // 为推荐分类准备的额外帖子，用于摇一摇更新
  final List<Post> _extraRecommendedPosts = [
    Post(
      id: 'recextra1',
      title: '校园新增自习室指南',
      content: '学校最近新增了三处24小时自习室，本文详细介绍位置、设施和使用规则，助你找到理想学习场所。',
      imageUrl: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c',
      authorId: 'admin2',
      authorName: '校园指南',
      authorAvatar: 'https://randomuser.me/api/portraits/women/60.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      likesCount: 42,
      commentsCount: 8,
    ),
    Post(
      id: 'recextra2',
      title: '大学生心理健康守护指南',
      content: '学业、社交、未来…大学生活充满各种压力。本文分享如何保持心理健康，从容面对挑战。',
      imageUrl: 'https://images.unsplash.com/photo-1474632601473-add916fc4109',
      authorId: 'psych1',
      authorName: '心理咨询中心',
      authorAvatar: 'https://randomuser.me/api/portraits/men/61.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likesCount: 89,
      commentsCount: 27,
    ),
    Post(
      id: 'recextra3',
      title: '校园里的这些小景点，你去过几个？',
      content: '除了标志性建筑，校园里还隐藏着许多小众景点，每一处都有其独特魅力和故事。',
      imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f',
      authorId: 'tour1',
      authorName: '校园探索者',
      authorAvatar: 'https://randomuser.me/api/portraits/women/62.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      likesCount: 112,
      commentsCount: 31,
    ),
    Post(
      id: 'recextra4',
      title: '如何平衡学习、社交和兼职？',
      content: '大学生活多姿多彩，但也面临时间管理的挑战。分享如何合理规划时间，兼顾多方面发展。',
      imageUrl: 'https://images.unsplash.com/photo-1484981184820-2e84ea0af397',
      authorId: 'balance1',
      authorName: '时间管理大师',
      authorAvatar: 'https://randomuser.me/api/portraits/men/63.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      likesCount: 76,
      commentsCount: 18,
    ),
    Post(
      id: 'recextra5',
      title: '校园APP使用技巧大全',
      content: '充分利用校园APP的各项功能，让你的校园生活更加便捷高效！本文详解各大功能的使用技巧。',
      imageUrl: 'https://images.unsplash.com/photo-1551650975-87deedd944c3',
      authorId: 'tech1',
      authorName: '科技达人',
      authorAvatar: 'https://randomuser.me/api/portraits/women/64.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      likesCount: 54,
      commentsCount: 11,
    ),
  ];

  // 构造函数初始化
  PostProvider() {
    // 预加载一些模拟数据到各分类
    _preloadMockData();
  }

  // 预加载模拟数据
  void _preloadMockData() {
    // 为每个分类选择相应的内置帖子
    _explorePosts = _getPostsForCategory(_currentCategory);
    _hotPosts = _getRandomPostsFromBuiltIn(6); // 热门帖子随机选6个
    // 关注帖子暂时留空，需要用户登录才会显示
  }

  // 设置当前标签
  void setCurrentTab(HomeTab tab) {
    if (_currentTab != tab) {
      _currentTab = tab;
      notifyListeners();

      // 首次切换到该标签时加载数据
      _loadTabDataIfNeeded();
    }
  }

  // 设置当前子分类
  void setCurrentCategory(ExploreCategory category) {
    if (_currentCategory != category) {
      _currentCategory = category;

      // 刷新探索标签的数据
      if (_currentTab == HomeTab.explore) {
        // 使用内置数据
        _explorePosts = _getPostsForCategory(category);
      }

      notifyListeners();
    }
  }

  // 根据分类获取内置帖子
  List<Post> _getPostsForCategory(ExploreCategory category) {
    switch (category) {
      case ExploreCategory.recommended:
      // 从推荐帖子中随机选择3-5个
        return _getRandomPostsFromList(_builtInPosts.where((post) =>
            post.id.startsWith('rec')).toList(), _random.nextInt(3) + 3);
      case ExploreCategory.study:
        return _builtInPosts.where((post) =>
            post.id.startsWith('study')).toList();
      case ExploreCategory.activity:
        return _builtInPosts.where((post) =>
            post.id.startsWith('activity')).toList();
      case ExploreCategory.lostFound:
        return _builtInPosts.where((post) =>
            post.id.startsWith('lost')).toList();
      case ExploreCategory.food:
        return _builtInPosts.where((post) =>
            post.id.startsWith('food')).toList();
      case ExploreCategory.accommodation:
        return _builtInPosts.where((post) =>
            post.id.startsWith('accommodation')).toList();
    }
  }

  // 从指定列表中随机选择n个帖子
  List<Post> _getRandomPostsFromList(List<Post> sourceList, int count) {
    if (sourceList.isEmpty) return [];
    if (sourceList.length <= count) return List.from(sourceList);

    // 复制原列表，避免修改原始数据
    final shuffled = List<Post>.from(sourceList);
    // 打乱顺序
    shuffled.shuffle(_random);
    // 返回前count个元素
    return shuffled.take(count).toList();
  }

  // 从所有内置帖子中随机选择n个
  List<Post> _getRandomPostsFromBuiltIn(int count) {
    return _getRandomPostsFromList(_builtInPosts, count);
  }

  // 加载当前标签的数据（如果尚未加载）
  void _loadTabDataIfNeeded() {
    switch (_currentTab) {
      case HomeTab.stared:
        if (_staredPosts.isEmpty) {
          fetchStaredPosts();
        }
        break;
      case HomeTab.explore:
        if (_explorePosts.isEmpty) {
          // 使用内置数据
          _explorePosts = _getPostsForCategory(_currentCategory);
          notifyListeners();
        }
        break;
      case HomeTab.hot:
        if (_hotPosts.isEmpty) {
          // 使用内置数据
          _hotPosts = _getRandomPostsFromBuiltIn(6);
          notifyListeners();
        }
        break;
    }
  }

  // 获取关注标签的帖子
  Future<void> fetchStaredPosts() async {
    if (_isLoadingStared) return;

    _isLoadingStared = true;
    notifyListeners();

    try {
      // 使用少量内置数据模拟关注的帖子
      await Future.delayed(const Duration(milliseconds: 800)); // 模拟网络延迟
      _staredPosts = _getRandomPostsFromBuiltIn(3); // 随机选3个帖子
    } catch (e) {
      debugPrint('获取关注帖子出错: $e');
    } finally {
      _isLoadingStared = false;
      notifyListeners();
    }
  }

  // 获取探索标签的帖子
  Future<void> fetchExplorePosts() async {
    if (_isLoadingExplore) return;

    _isLoadingExplore = true;
    notifyListeners();

    try {
      // 使用内置数据，模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 800));
      _explorePosts = _getPostsForCategory(_currentCategory);
    } catch (e) {
      debugPrint('获取探索帖子出错: $e');
    } finally {
      _isLoadingExplore = false;
      notifyListeners();
    }
  }

  // 获取热门标签的帖子
  Future<void> fetchHotPosts() async {
    if (_isLoadingHot) return;

    _isLoadingHot = true;
    notifyListeners();

    try {
      // 使用内置数据，模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 800));
      _hotPosts = _getRandomPostsFromBuiltIn(6);
    } catch (e) {
      debugPrint('获取热门帖子出错: $e');
    } finally {
      _isLoadingHot = false;
      notifyListeners();
    }
  }

  // 摇一摇刷新内容 - 现在会更新推荐内容
  Future<void> refreshCurrentTab() async {
    switch (_currentTab) {
      case HomeTab.stared:
        await fetchStaredPosts();
        break;
      case HomeTab.explore:
      // 如果是推荐分类，则特殊处理
        if (_currentCategory == ExploreCategory.recommended) {
          _updateRecommendedPostsOnShake();
        } else {
          await fetchExplorePosts();
        }
        break;
      case HomeTab.hot:
        await fetchHotPosts();
        break;
    }
  }

  // 摇一摇时更新推荐帖子
  void _updateRecommendedPostsOnShake() {
    _isLoadingExplore = true;
    notifyListeners();

    // 延迟执行以显示加载动画
    Future.delayed(const Duration(milliseconds: 800), () {
      // 合并常规推荐帖子和额外推荐帖子
      final allRecommendedPosts = [
        ..._builtInPosts.where((post) => post.id.startsWith('rec')).toList(),
        ..._extraRecommendedPosts
      ];

      // 随机选择3-5个帖子
      _explorePosts = _getRandomPostsFromList(allRecommendedPosts, _random.nextInt(3) + 3);

      _isLoadingExplore = false;
      notifyListeners();
    });
  }

  // 发布新帖子
  Future<bool> createPost(String title, String content, String imageUrl) async {
    try {
      // 在实际应用中应该调用API
      // 模拟成功响应
      await Future.delayed(const Duration(seconds: 1));

      // 创建新帖子
      final newPost = Post(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        content: content,
        imageUrl: imageUrl,
        authorId: 'current_user', // 实际应用中应该使用当前用户ID
        authorName: '当前用户', // 实际应用中应该使用当前用户名
        authorAvatar: null,
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
      );

      // 将新帖子添加到相应分类
      _explorePosts = [newPost, ..._explorePosts];

      // 刷新当前标签数据
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('发布帖子出错: $e');
      return false;
    }
  }

  // 点赞帖子
  Future<bool> likePost(String postId) async {
    try {
      final success = await _apiService.likePost(postId);
      if (success) {
        // 更新本地数据状态
        _updatePostLikeStatus(postId, true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('点赞帖子出错: $e');
      return false;
    }
  }

  // 取消点赞
  Future<bool> unlikePost(String postId) async {
    try {
      final success = await _apiService.unlikePost(postId);
      if (success) {
        // 更新本地数据状态
        _updatePostLikeStatus(postId, false);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('取消点赞出错: $e');
      return false;
    }
  }

  // 分享帖子
  Future<bool> sharePost(String postId) async {
    try {
      // 在实际实现中，这可能是调用分享API或系统分享功能
      // 这里简化为模拟成功
      debugPrint('分享帖子: $postId');
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      debugPrint('分享帖子出错: $e');
      return false;
    }
  }

  // 更新帖子点赞状态
  void _updatePostLikeStatus(String postId, bool isLiked) {
    // 更新所有标签下的帖子状态
    _updatePostList(_staredPosts, postId, isLiked);
    _updatePostList(_explorePosts, postId, isLiked);
    _updatePostList(_hotPosts, postId, isLiked);
    notifyListeners();
  }

  // 辅助方法：更新特定列表中的帖子点赞状态
  void _updatePostList(List<Post> posts, String postId, bool isLiked) {
    for (int i = 0; i < posts.length; i++) {
      if (posts[i].id == postId) {
        posts[i] = posts[i].copyWith(isLiked: isLiked);
        if (isLiked) {
          posts[i] = posts[i].copyWith(likesCount: posts[i].likesCount + 1);
        } else {
          posts[i] = posts[i].copyWith(likesCount: max(0, posts[i].likesCount - 1));
        }
        break;
      }
    }
  }

// 将枚举转换为字符串
  String categoryToString(ExploreCategory category) {
    switch (category) {
      case ExploreCategory.recommended:
        return 'recommended';
      case ExploreCategory.study:
        return 'study';
      case ExploreCategory.activity:
        return 'activity';
      case ExploreCategory.lostFound:
        return 'lost_found';
      case ExploreCategory.food:
        return 'food';
      case ExploreCategory.accommodation:
        return 'accommodation';
    }
  }
}