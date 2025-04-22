import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/auth/login_screen.dart';

class CampusSocialApp extends StatelessWidget {
  const CampusSocialApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return MaterialApp(
          title: '校园社区社交平台',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: ThemeData(
            primarySwatch: Colors.red,
            primaryColor: const Color(0xFFE53935),
            scaffoldBackgroundColor: Colors.white,
            fontFamily: appProvider.isEnglish ? 'Roboto' : 'SourceHanSans',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 本地化支持
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // 英文
            Locale('zh', ''), // 中文
          ],
          locale: appProvider.isEnglish ? const Locale('en', '') : const Locale('zh', ''),

          // 设置默认路由
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/login': (context) => const LoginScreen(),
          },
        );
      },
    );
  }
}