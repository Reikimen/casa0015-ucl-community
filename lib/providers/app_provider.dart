import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppProvider extends ChangeNotifier {
  bool _isEnglish = false;
  bool _autoTranslate = false; // 自动翻译功能开关

  // Add translation cache
  final Map<String, String> _translationCache = {};

  bool get isEnglish => _isEnglish;
  bool get autoTranslate => _autoTranslate; // 自动翻译状态的getter

  // 本地翻译映射 - 作为API失败时的备选方案
  final Map<String, String> _localZhToEn = {
    '首页': 'Home',
    '发现': 'Explore',
    '热门': 'Hot',
    '关注': 'Follow',
    '评论': 'Comments',
    '分享': 'Share',
    '登录': 'Login',
    '注销': 'Logout',
    '设置': 'Settings',
    '帮助与反馈': 'Help & Feedback',
    '关于我们': 'About Us',
    '未登录': 'Not Logged In',
    '注销': 'Logout',
    '自动翻译内容': 'Auto Translate Content',
    '自动翻译已开启': 'Auto translation enabled',
    '自动翻译已关闭': 'Auto translation disabled',
    '切换到中文': 'Switch to Chinese',
    '语言已切换为中文': 'Language changed to Chinese',
    '请先登录后再点赞': 'Please login before liking',
    '已分享到其他应用': 'Shared to other apps',
    '已翻译': 'Translated',
    '正在翻译...': 'Translating...',
    '校园': 'Campus',
    '学习': 'Study',
    '活动': 'Activity',
    '美食': 'Food',
    '宿舍': 'Dormitory',
    '请将NFC校园卡靠近手机背面': 'Please place your NFC campus card close to the back of your phone',
    '保持静止直到读取完成': 'Keep still until reading is complete',
    '暂无内容': 'No content yet',
    '试试切换其他分类或下拉刷新': 'Try another category or pull to refresh',
  };

  // 反向映射：英文到中文
  final Map<String, String> _localEnToZh = {
    'Home': '首页',
    'Explore': '发现',
    'Hot': '热门',
    'Follow': '关注',
    'Comments': '评论',
    'Share': '分享',
    'Login': '登录',
    'Logout': '注销',
    'Settings': '设置',
    'Help & Feedback': '帮助与反馈',
    'About Us': '关于我们',
    'Not Logged In': '未登录',
    'Auto Translate Content': '自动翻译内容',
    'Auto translation enabled': '自动翻译已开启',
    'Auto translation disabled': '自动翻译已关闭',
    'Switch to Chinese': '切换到中文',
    'Language changed to Chinese': '语言已切换为中文',
    'Please login before liking': '请先登录后再点赞',
    'Shared to other apps': '已分享到其他应用',
    'Translated': '已翻译',
    'Translating...': '正在翻译...',
    'Campus': '校园',
    'Study': '学习',
    'Activity': '活动',
    'Food': '美食',
    'Dormitory': '宿舍',
    'Please place your NFC campus card close to the back of your phone': '请将NFC校园卡靠近手机背面',
    'Keep still until reading is complete': '保持静止直到读取完成',
    'No content yet': '暂无内容',
    'Try another category or pull to refresh': '试试切换其他分类或下拉刷新',
  };

  AppProvider() {
    _loadPreferences();
  }

  // 加载所有配置
  Future<void> _loadPreferences() async {
    await _loadLanguagePreference();
    await _loadTranslatePreference();
  }

  // 加载语言偏好设置
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnglish = prefs.getBool('isEnglish') ?? false;
    notifyListeners();
  }

  // 加载翻译偏好设置
  Future<void> _loadTranslatePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _autoTranslate = prefs.getBool('autoTranslate') ?? false;
    notifyListeners();
  }

  // 切换语言
  Future<void> toggleLanguage() async {
    _isEnglish = !_isEnglish;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isEnglish', _isEnglish);

    // Clear translation cache when language changes
    _translationCache.clear();

    notifyListeners();
  }

  // 切换自动翻译设置
  Future<void> toggleAutoTranslate() async {
    _autoTranslate = !_autoTranslate;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoTranslate', _autoTranslate);

    // Clear translation cache when setting changes
    _translationCache.clear();

    notifyListeners();
  }

  // 获取当前语言环境下的字符串
  String getLocalizedString(String zhText, String enText) {
    return _isEnglish ? enText : zhText;
  }

  // Generate a cache key for translations
  String _getCacheKey(String text, bool toEnglish) {
    return "${toEnglish ? 'zh2en' : 'en2zh'}_$text";
  }

  // 增强版翻译方法 - with caching
  Future<String> translateText(String text, {bool toEnglish = true}) async {
    if (text.isEmpty) return text;

    // 如果不需要翻译，直接返回原文
    if (!_autoTranslate) return text;

    // 如果当前是中文模式且不需要翻译成英文，或者当前是英文模式且不需要翻译成中文，直接返回原文
    if ((_isEnglish && !toEnglish) || (!_isEnglish && toEnglish)) {
      return text;
    }

    // Generate cache key
    String cacheKey = _getCacheKey(text, toEnglish);

    // Check if translation is already in cache
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    debugPrint('准备翻译文本: "$text" ${toEnglish ? "→ 英文" : "→ 中文"}');

    // 首先尝试本地翻译映射
    if (toEnglish && _localZhToEn.containsKey(text)) {
      final result = _localZhToEn[text]!;
      // Cache the result
      _translationCache[cacheKey] = result;
      debugPrint('使用本地映射翻译: $text -> $result');
      return result;
    } else if (!toEnglish && _localEnToZh.containsKey(text)) {
      final result = _localEnToZh[text]!;
      // Cache the result
      _translationCache[cacheKey] = result;
      debugPrint('使用本地映射翻译: $text -> $result');
      return result;
    }

    // 接下来尝试通过API翻译
    try {
      // Google Cloud Translation API密钥
      const apiKey = 'AIzaSyCQxRgPWPW4vLG1azD7DAVl2RrSyLZsx2c';

      // 设置源语言和目标语言
      final sourceLanguage = toEnglish ? 'zh' : 'en';
      final targetLanguage = toEnglish ? 'en' : 'zh';

      // 构建API请求URL
      final url = Uri.parse(
          'https://translation.googleapis.com/language/translate/v2?key=$apiKey'
      );

      debugPrint('发送翻译请求，源语言: $sourceLanguage, 目标语言: $targetLanguage');

      // 发送翻译请求
      final response = await http.post(
        url,
        body: {
          'q': text,
          'source': sourceLanguage,
          'target': targetLanguage,
          'format': 'text',
        },
      );

      // 处理响应
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('收到翻译响应: ${response.body}');

        if (data.containsKey('data') &&
            data['data'].containsKey('translations') &&
            data['data']['translations'] is List &&
            (data['data']['translations'] as List).isNotEmpty) {

          final translations = data['data']['translations'] as List;
          final result = translations[0]['translatedText'];

          // Cache the result
          _translationCache[cacheKey] = result;

          debugPrint('翻译结果: "$result"');
          return result;
        } else {
          debugPrint('翻译响应格式不正确: ${response.body}');

          // 回退到简单内容替换
          final result = _simpleTranslate(text, toEnglish);

          // Cache the simple translation result
          _translationCache[cacheKey] = result;

          return result;
        }
      } else {
        // 请求失败，记录详细错误信息
        debugPrint('翻译请求失败: ${response.statusCode}');
        debugPrint('错误详情: ${response.body}');

        // 尝试解析错误信息
        try {
          final errorData = json.decode(response.body);
          if (errorData.containsKey('error')) {
            final error = errorData['error'];
            debugPrint('API错误: ${error['message']} (${error['status']})');
          }
        } catch (e) {
          debugPrint('无法解析错误响应: $e');
        }

        // 回退到简单内容替换
        final result = _simpleTranslate(text, toEnglish);

        // Cache the simple translation result
        _translationCache[cacheKey] = result;

        return result;
      }
    } catch (e) {
      debugPrint('翻译过程出错: $e');

      // 回退到简单内容替换
      final result = _simpleTranslate(text, toEnglish);

      // Cache the simple translation result
      _translationCache[cacheKey] = result;

      return result;
    }
  }

  // 简单的内容替换翻译（作为API失败的备选方案）
  String _simpleTranslate(String text, bool toEnglish) {
    String result = text;

    try {
      if (toEnglish) {
        // 中译英：替换常见词汇
        _localZhToEn.forEach((zh, en) {
          result = result.replaceAll(zh, en);
        });
      } else {
        // 英译中：替换常见词汇
        _localEnToZh.forEach((en, zh) {
          result = result.replaceAll(en, zh);
        });
      }

      // 如果替换后内容与原内容相同，说明没有找到匹配项
      if (result == text) {
        debugPrint('简单替换未找到匹配: $text');
        return text;
      } else {
        debugPrint('简单替换结果: $result');
        return result;
      }
    } catch (e) {
      debugPrint('简单替换出错: $e');
      return text;
    }
  }

  // Clear translation cache
  void clearTranslationCache() {
    _translationCache.clear();
    debugPrint('翻译缓存已清空');
  }

  // 测试翻译功能
  Future<String> testTranslation() async {
    final testResult = await translateText('你好，世界', toEnglish: true);
    debugPrint('测试翻译结果: $testResult');
    return testResult;
  }
}