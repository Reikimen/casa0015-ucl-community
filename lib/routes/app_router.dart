import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/nfc_login.dart';
import '../screens/post/post_detail.dart';
import '../screens/post/post_create.dart';
import '../utils/constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.profile:
      // 获取路由参数（用户ID）
        final args = settings.arguments;
        String? userId;

        if (args != null && args is Map<String, dynamic>) {
          userId = args['userId'];
        }

        return MaterialPageRoute(
          builder: (_) => ProfileScreen(userId: userId),
        );

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.nfcLogin:
        return MaterialPageRoute(builder: (_) => const NfcLoginScreen());

      case AppRoutes.postDetail:
      // 获取帖子ID参数
        final args = settings.arguments;

        if (args != null && args is Map<String, dynamic>) {
          final postId = args['postId'];
          final initialShowComments = args['initialShowComments'] ?? false;

          if (postId != null) {
            return MaterialPageRoute(
              builder: (_) => PostDetailScreen(
                postId: postId,
                initialShowComments: initialShowComments,
              ),
            );
          }
        }

        return _errorRoute('Missing or invalid post ID');

      case AppRoutes.createPost:
        return MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const PostCreateScreen(),
        );

      case AppRoutes.settings:
      // TODO: 实现设置页面
        return _errorRoute('Settings page not implemented yet');

      case AppRoutes.about:
      // TODO: 实现关于页面
        return _errorRoute('About page not implemented yet');

      case AppRoutes.help:
      // TODO: 实现帮助页面
        return _errorRoute('Help page not implemented yet');

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  // 错误路由页面
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('错误'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  '页面加载错误',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 导航到主页
  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
          (route) => false,
    );
  }

  // 导航到个人资料页
  static void navigateToProfile(BuildContext context, {String? userId}) {
    Navigator.pushNamed(
      context,
      AppRoutes.profile,
      arguments: userId != null ? {'userId': userId} : null,
    );
  }

  // 导航到登录页
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.login);
  }

  // 导航到NFC登录页
  static void navigateToNfcLogin(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.nfcLogin);
  }

  // 导航到帖子详情页
  static void navigateToPostDetail(
      BuildContext context, {
        required String postId,
        bool initialShowComments = false,
      }) {
    Navigator.pushNamed(
      context,
      AppRoutes.postDetail,
      arguments: {
        'postId': postId,
        'initialShowComments': initialShowComments,
      },
    );
  }

  // 导航到创建帖子页
  static void navigateToCreatePost(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.createPost);
  }

  // 导航到设置页
  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  // 导航到关于页
  static void navigateToAbout(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.about);
  }

  // 导航到帮助页
  static void navigateToHelp(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.help);
  }
}