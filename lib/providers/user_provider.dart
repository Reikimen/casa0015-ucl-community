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

  // 构造函数 - 检查用户是否已登录
  UserProvider() {
    checkLoginStatus();
  }

  // 检查登录状态
  Future<void> checkLoginStatus() async {
    _setLoading(true);
    try {
      final storageService = StorageService();
      final token = await storageService.getAuthToken();

      if (token != null && token.isNotEmpty) {
        final authService = AuthService();
        final user = await authService.getUserProfile();
        if (user != null) {
          _currentUser = user;
          _isLoggedIn = true;
        }
      }
    } catch (e) {
      debugPrint('检查登录状态出错: $e');
    } finally {
      _setLoading(false);
    }
  }

  // NFC登录
  Future<bool> loginWithNfc(String nfcId) async {
    _setLoading(true);
    try {
      debugPrint('UserProvider: 尝试使用NFC ID登录: $nfcId');

      final authService = AuthService();
      final result = await authService.loginWithNfc(nfcId);

      if (result.success) {
        _currentUser = result.user;
        _isLoggedIn = true;

        // 保存认证令牌
        final storageService = StorageService();
        await storageService.saveAuthToken(result.token!);

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