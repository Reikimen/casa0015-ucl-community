import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/user_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 用户信息区域
          _buildUserHeader(context, userProvider, appProvider),

          // 菜单选项
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(appProvider.getLocalizedString('首页', 'Home')),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),

          // 个人资料选项（仅登录后显示）
          if (userProvider.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(appProvider.getLocalizedString('个人资料', 'Profile')),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),

          // 设置选项
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(appProvider.getLocalizedString('设置', 'Settings')),
            onTap: () {
              Navigator.pop(context);
              // TODO: 导航到设置页面
            },
          ),

          // 帮助与反馈
          ListTile(
            leading: const Icon(Icons.help),
            title: Text(appProvider.getLocalizedString('帮助与反馈', 'Help & Feedback')),
            onTap: () {
              Navigator.pop(context);
              // TODO: 导航到帮助页面
            },
          ),

          // 关于我们
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(appProvider.getLocalizedString('关于我们', 'About Us')),
            onTap: () {
              Navigator.pop(context);
              // TODO: 导航到关于页面
            },
          ),

          const Divider(),

          // 登录/注销按钮
          _buildAuthButton(context, userProvider, appProvider),

          const Divider(),

          // 测试翻译按钮
          _buildTestTranslationButton(context, appProvider),

          const SizedBox(height: 10),

          // 自动翻译开关
          _buildAutoTranslateSwitch(context, appProvider),

          const SizedBox(height: 10),

          // 底部语言切换按钮
          _buildLanguageToggle(context, appProvider),
        ],
      ),
    );
  }

  // 构建用户信息头部
  Widget _buildUserHeader(
      BuildContext context,
      UserProvider userProvider,
      AppProvider appProvider
      ) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Color(0xFFE53935),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户头像
          if (userProvider.isLoggedIn && userProvider.currentUser?.avatar != null)
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(userProvider.currentUser!.avatar!),
            )
          else
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFFE53935)),
            ),

          const SizedBox(height: 10),

          // 用户名
          Text(
            userProvider.isLoggedIn
                ? userProvider.currentUser!.username
                : appProvider.getLocalizedString('未登录', 'Not Logged In'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 学号
          if (userProvider.isLoggedIn)
            Text(
              userProvider.currentUser!.studentId,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  // 构建登录/注销按钮
  Widget _buildAuthButton(
      BuildContext context,
      UserProvider userProvider,
      AppProvider appProvider
      ) {
    return ListTile(
      leading: Icon(
        userProvider.isLoggedIn ? Icons.logout : Icons.login,
      ),
      title: Text(
        userProvider.isLoggedIn
            ? appProvider.getLocalizedString('注销', 'Logout')
            : appProvider.getLocalizedString('登录', 'Login'),
      ),
      onTap: () async {
        Navigator.pop(context);

        if (userProvider.isLoggedIn) {
          // 注销登录
          await userProvider.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                appProvider.getLocalizedString('已注销登录', 'Logged out successfully'),
              ),
            ),
          );
        } else {
          // 导航到登录页面
          Navigator.pushNamed(context, '/login');
        }
      },
    );
  }

  // 构建测试翻译按钮
  Widget _buildTestTranslationButton(
      BuildContext context,
      AppProvider appProvider
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        onPressed: () async {
          final result = await appProvider.testTranslation();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('翻译测试结果: "$result"'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        child: Text(
          appProvider.getLocalizedString('测试翻译功能', 'Test Translation'),
        ),
      ),
    );
  }

  // 构建自动翻译开关
  Widget _buildAutoTranslateSwitch(
      BuildContext context,
      AppProvider appProvider
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 自动翻译标签
          Expanded(
            child: Text(
              appProvider.getLocalizedString(
                  '自动翻译内容',
                  'Auto Translate Content'
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // 开关
          Switch(
            value: appProvider.autoTranslate,
            activeColor: const Color(0xFFE53935),
            onChanged: (value) async {
              await appProvider.toggleAutoTranslate();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      appProvider.autoTranslate
                          ? appProvider.getLocalizedString(
                          '自动翻译已开启',
                          'Auto translation enabled'
                      )
                          : appProvider.getLocalizedString(
                          '自动翻译已关闭',
                          'Auto translation disabled'
                      ),
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 构建语言切换按钮
  Widget _buildLanguageToggle(
      BuildContext context,
      AppProvider appProvider
      ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(40),
        ),
        onPressed: () async {
          await appProvider.toggleLanguage();

          // 显示切换语言提示
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  appProvider.isEnglish
                      ? 'Language changed to English'
                      : '语言已切换为中文',
                ),
              ),
            );
          }
        },
        child: Text(
          appProvider.isEnglish
              ? '切换到中文'
              : 'Switch to English',
        ),
      ),
    );
  }
}