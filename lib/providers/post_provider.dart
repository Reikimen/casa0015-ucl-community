import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

enum HomeTab { stared, explore, hot }
enum ExploreCategory { recommended, study, activity, lostFound, food, accommodation }

class PostProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

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
      notifyListeners();

      // 刷新探索标签的数据
      if (_currentTab == HomeTab.explore) {
        fetchExplorePosts();
      }
    }
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
          fetchExplorePosts();
        }
        break;
      case HomeTab.hot:
        if (_hotPosts.isEmpty) {
          fetchHotPosts();
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
      final posts = await _apiService.getStaredPosts();
      _staredPosts = posts;
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
      final posts = await _apiService.getExplorePosts(
        categoryToString(_currentCategory),
      );
      _explorePosts = posts;
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
      final posts = await _apiService.getHotPosts();
      _hotPosts = posts;
    } catch (e) {
      debugPrint('获取热门帖子出错: $e');
    } finally {
      _isLoadingHot = false;
      notifyListeners();
    }
  }

  // 摇一摇刷新内容
  Future<void> refreshCurrentTab() async {
    switch (_currentTab) {
      case HomeTab.stared:
        await fetchStaredPosts();
        break;
      case HomeTab.explore:
        await fetchExplorePosts();
        break;
      case HomeTab.hot:
        await fetchHotPosts();
        break;
    }
  }

  // 发布新帖子
  Future<bool> createPost(String title, String content, String imageUrl) async {
    try {
      final success = await _apiService.createPost(title, content, imageUrl);
      if (success) {
        // 刷新当前标签数据
        refreshCurrentTab();
        return true;
      }
      return false;
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
      // 实际实现中应该调用API，这里简化为返回成功
      // 例如: final success = await _apiService.sharePost(postId);
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
          posts[i] = posts[i].copyWith(likesCount: posts[i].likesCount - 1);
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