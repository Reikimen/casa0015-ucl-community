import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  bool _isEnglish = false;

  bool get isEnglish => _isEnglish;

  AppProvider() {
    _loadLanguagePreference();
  }

  // 加载语言偏好设置
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnglish = prefs.getBool('isEnglish') ?? false;
    notifyListeners();
  }

  // 切换语言
  Future<void> toggleLanguage() async {
    _isEnglish = !_isEnglish;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isEnglish', _isEnglish);
    notifyListeners();
  }

  // 获取当前语言环境下的字符串
  String getLocalizedString(String zhText, String enText) {
    return _isEnglish ? enText : zhText;
  }
}