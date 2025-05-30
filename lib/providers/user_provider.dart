import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  // 构造函数 - 在应用启动时使用
  UserProvider();

  // 改进后的检查登录状态方法
  Future<void> checkLoginStatus() async {
    _setLoading(true);
    try {
      final storageService = StorageService();
      final token = await storageService.getAuthToken();

      if (token != null && token.isNotEmpty) {
        debugPrint('找到保存的token: $token');

        // 验证 token 是否仍然有效
        final authService = AuthService();
        final user = await authService.getUserProfile();

        if (user != null) {
          _currentUser = user;
          _isLoggedIn = true;
          debugPrint('自动登录成功: ${user.username}');
        } else {
          // Token 可能已过期，清除存储的 token
          await storageService.deleteAuthToken();
          debugPrint('Token 已过期，需要重新登录');
        }
      } else {
        debugPrint('未找到保存的登录信息');
      }
    } catch (e) {
      debugPrint('检查登录状态出错: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 改进后的 NFC 登录方法
  Future<bool> loginWithNfc(String nfcId) async {
    if (nfcId == null || nfcId.isEmpty) {
      debugPrint('UserProvider: NFC ID为空，无法登录');
      return false;
    }

    _setLoading(true);
    try {
      debugPrint('UserProvider: 尝试使用NFC ID登录: $nfcId');

      final authService = AuthService();
      final result = await authService.loginWithNfc(nfcId);

      if (result.success && result.user != null && result.token != null) {
        _currentUser = result.user;
        _isLoggedIn = true;

        // 保存认证令牌
        final storageService = StorageService();
        await storageService.saveAuthToken(result.token!);

        // 验证是否保存成功
        final savedToken = await storageService.getAuthToken();
        debugPrint('令牌保存验证: ${savedToken == result.token}');

        debugPrint('UserProvider: NFC登录成功: ${result.user?.username}');
        notifyListeners();
        return true;
      } else {
        debugPrint('UserProvider: NFC登录失败: ${result.errorMessage}');
        return false;
      }
    } catch (e) {
      debugPrint('UserProvider: NFC登录出错: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 注销登录
  Future<void> logout() async {
    _setLoading(true);
    try {
      final storageService = StorageService();
      await storageService.deleteAuthToken();

      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      debugPrint('注销登录出错: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}