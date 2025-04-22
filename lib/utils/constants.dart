import 'package:flutter/material.dart';

class AppConstants {
  // 应用主题颜色
  static const Color primaryColor = Color(0xFFE53935);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // 边距和圆角
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;

  // 字体大小
  static const double headingFontSize = 20.0;
  static const double titleFontSize = 18.0;
  static const double bodyFontSize = 16.0;
  static const double smallFontSize = 14.0;
  static const double captionFontSize = 12.0;

  // 图片尺寸
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 40.0;
  static const double avatarSizeLarge = 80.0;

  // 持久化存储键
  static const String languageKey = 'language';
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';

  // API路径
  static const String baseApiUrl = 'https://api.campussocial.example.com';

  // 图像占位符
  static const String placeholderImage = 'assets/images/placeholder.png';
  static const String avatarPlaceholder = 'assets/images/avatar_placeholder.png';

  // 分类映射表
  static const Map<String, String> categoriesZh = {
    'recommended': '推荐',
    'study': '学习',
    'activity': '活动',
    'lost_found': '失物招领',
    'food': '美食',
    'accommodation': '住宿',
  };

  static const Map<String, String> categoriesEn = {
    'recommended': 'Recommended',
    'study': 'Study',
    'activity': 'Activities',
    'lost_found': 'Lost & Found',
    'food': 'Food',
    'accommodation': 'Accommodation',
  };

  // 默认配置
  static const int defaultPageSize = 20;
  static const int maxTitleLength = 50;
  static const int maxContentLength = 2000;

  // 防抖和节流时间
  static const int debounceTimeMs = 500;
  static const int throttleTimeMs = 1000;
}

// 本地化字符串
class AppStrings {
  static const Map<String, String> zh = {
    'app_name': '校园社区社交平台',
    'home': '首页',
    'profile': '个人资料',
    'stared': '关注',
    'explore': '发现',
    'hot': '热门',
    'login': '登录',
    'logout': '注销',
    'settings': '设置',
    'language': '语言',
    'about': '关于',
    'help': '帮助与反馈',
    'create_post': '创建帖子',
    'post_detail': '帖子详情',
    'comments': '评论',
    'likes': '点赞',
    'share': '分享',
    'follow': '关注',
    'unfollow': '取消关注',
    'followers': '粉丝',
    'following': '关注',
    'posts': '帖子',
    'collections': '收藏',
    'edit_profile': '编辑资料',
    'save': '保存',
    'cancel': '取消',
    'submit': '提交',
    'delete': '删除',
    'confirm': '确认',
    'loading': '加载中...',
    'error': '出错了',
    'try_again': '重试',
    'no_data': '暂无数据',
    'refresh': '刷新',
    'network_error': '网络错误，请稍后再试',
    'login_required': '请先登录',
    'logout_confirm': '确定要注销登录吗？',
    'yes': '是',
    'no': '否',
    'success': '成功',
    'failed': '失败',
    'send': '发送',
    'write_comment': '写下你的评论...',
    'no_comments': '暂无评论，快来发表第一条评论吧',
    'input_title': '请输入标题（必填）',
    'input_content': '请输入正文内容（必填）',
    'select_image': '点击上传封面图片（必选）',
    'shake_to_refresh': '摇一摇刷新内容',
    'shake_refreshing': '正在刷新内容...',
    'shake_success': '摇一摇刷新成功，为您推荐了新内容',
    'nfc_login': 'NFC校园卡登录',
    'nfc_login_hint': '将校园卡靠近手机背面',
    'nfc_keep_still': '保持静止直到读取完成',
    'nfc_success': '登录成功！',
    'nfc_error': '读取NFC卡失败，请重试',
    'nfc_not_supported': '您的设备不支持NFC功能',
    'switch_to_english': 'Switch to English',
    'more_coming_soon': '更多功能即将推出',
  };

  static const Map<String, String> en = {
    'app_name': 'Campus Social App',
    'home': 'Home',
    'profile': 'Profile',
    'stared': 'Stared',
    'explore': 'Explore',
    'hot': 'Hot',
    'login': 'Login',
    'logout': 'Logout',
    'settings': 'Settings',
    'language': 'Language',
    'about': 'About',
    'help': 'Help & Feedback',
    'create_post': 'Create Post',
    'post_detail': 'Post Detail',
    'comments': 'Comments',
    'likes': 'Likes',
    'share': 'Share',
    'follow': 'Follow',
    'unfollow': 'Unfollow',
    'followers': 'Followers',
    'following': 'Following',
    'posts': 'Posts',
    'collections': 'Collections',
    'edit_profile': 'Edit Profile',
    'save': 'Save',
    'cancel': 'Cancel',
    'submit': 'Submit',
    'delete': 'Delete',
    'confirm': 'Confirm',
    'loading': 'Loading...',
    'error': 'Error Occurred',
    'try_again': 'Try Again',
    'no_data': 'No Data',
    'refresh': 'Refresh',
    'network_error': 'Network error, please try again later',
    'login_required': 'Please login first',
    'logout_confirm': 'Are you sure you want to logout?',
    'yes': 'Yes',
    'no': 'No',
    'success': 'Success',
    'failed': 'Failed',
    'send': 'Send',
    'write_comment': 'Write your comment...',
    'no_comments': 'No comments yet, be the first to comment',
    'input_title': 'Enter title (required)',
    'input_content': 'Enter content (required)',
    'select_image': 'Tap to upload cover image (required)',
    'shake_to_refresh': 'Shake to refresh content',
    'shake_refreshing': 'Refreshing content...',
    'shake_success': 'Shake refresh successful, new content recommended for you',
    'nfc_login': 'NFC Campus Card Login',
    'nfc_login_hint': 'Place your campus card near the back of your phone',
    'nfc_keep_still': 'Keep still until reading is complete',
    'nfc_success': 'Login successful!',
    'nfc_error': 'Failed to read NFC card, please try again',
    'nfc_not_supported': 'Your device does not support NFC',
    'switch_to_chinese': '切换到中文',
    'more_coming_soon': 'More features coming soon',
  };
}

// 路由名称
class AppRoutes {
  static const String home = '/';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String nfcLogin = '/nfc-login';
  static const String postDetail = '/post-detail';
  static const String createPost = '/create-post';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String help = '/help';
}

// 资源路径
class AppAssets {
  static const String logo = 'assets/images/logo.png';
  static const String placeholder = 'assets/images/placeholder.png';
  static const String avatarPlaceholder = 'assets/images/avatar_placeholder.png';
  static const String bgPattern = 'assets/images/bg_pattern.png';
  static const String emptyState = 'assets/images/empty_state.png';
  static const String errorState = 'assets/images/error_state.png';
}