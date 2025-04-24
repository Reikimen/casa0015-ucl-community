import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/auth_result.dart';
import 'storage_service.dart';

class AuthService {
  // API基础URL
  final String _baseUrl = 'https://api.campussocial.example.com';
  final StorageService _storageService = StorageService();

  // 构建带认证的Headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  // 用于测试的NFC ID到用户的映射
  final Map<String, User> _mockNfcUsers = {
    // 测试用户1
    'abc123456789': User(
      id: 'user1',
      username: '测试用户',
      studentId: '2023001',
      avatar: null,
      bio: '这是一个测试账号',
      followersCount: 10,
      followingCount: 5,
      likesCount: 20,
    ),
    // 测试用户2
    '04d23a5a985d80': User(
      id: 'user2',
      username: '学生测试',
      studentId: '2023002',
      avatar: null,
      bio: '校园社区测试账号',
      followersCount: 5,
      followingCount: 8,
      likesCount: 15,
    ),
    // 用户提供的NFC卡UID
    '04215aa22a0289': User(
      id: 'user3',
      username: 'Dankao',
      studentId: '114514',
      avatar: null,
      bio: 'A stupid guy who developed this APP',
      followersCount: 3,
      followingCount: 7,
      likesCount: 12,
    ),
  };

  // NFC卡登录
  Future<AuthResult> loginWithNfc(String nfcId) async {
    // 安全检查
    if (nfcId == null || nfcId.isEmpty) {
      debugPrint('NFC ID为空，无法登录');
      return AuthResult(
        success: false,
        errorMessage: 'NFC ID为空',
      );
    }

    debugPrint('尝试使用NFC ID登录: $nfcId');

    // 在实际生产环境中，应该调用后端API
    // 以下是模拟后端验证的代码，用于测试目的

    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 1));

      // 模拟登录逻辑 - 在实际应用中，这应该是一个API调用
      if (_mockNfcUsers.containsKey(nfcId)) {
        // 登录成功
        final user = _mockNfcUsers[nfcId]!;
        final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

        // 打印登录信息用于调试
        debugPrint('NFC登录成功: ${user.username}');

        return AuthResult(
          success: true,
          user: user,
          token: token,
        );
      } else {
        // 登录失败 - 未找到关联用户
        debugPrint('NFC登录失败: 未找到与ID关联的用户');
        debugPrint('注册的NFC IDs: ${_mockNfcUsers.keys.join(', ')}');
        return AuthResult(
          success: false,
          errorMessage: '未找到与此NFC卡关联的用户',
        );
      }
    } catch (e) {
      // 处理错误
      debugPrint('NFC登录过程中出错: $e');
      return AuthResult(
        success: false,
        errorMessage: '登录过程出错，请重试',
      );
    }

    // 实际的API调用代码（目前注释掉）
    /*
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/nfc-login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nfc_id': nfcId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AuthResult(
          success: true,
          user: User.fromJson(data['user']),
          token: data['token'],
        );
      } else {
        final data = json.decode(response.body);
        return AuthResult(
          success: false,
          errorMessage: data['message'] ?? '登录失败',
        );
      }
    } catch (e) {
      debugPrint('NFC登录出错: $e');
      return AuthResult(
        success: false,
        errorMessage: '网络错误，请稍后再试',
      );
    }
    */
  }

  // 获取当前用户信息
  Future<User?> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/user/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('获取用户信息出错: $e');
      return null;
    }
  }

  // 获取其他用户个人资料
  Future<User?> getUserById(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('获取用户信息出错: $e');
      return null;
    }
  }

  // 关注用户
  Future<bool> followUser(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/users/$userId/follow'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('关注用户出错: $e');
      return false;
    }
  }

  // 取消关注
  Future<bool> unfollowUser(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/users/$userId/follow'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('取消关注出错: $e');
      return false;
    }
  }

  // 更新用户资料
  Future<bool> updateUserProfile({String? username, String? bio, String? avatar}) async {
    try {
      final headers = await _getHeaders();
      final Map<String, dynamic> data = {};

      if (username != null) data['username'] = username;
      if (bio != null) data['bio'] = bio;
      if (avatar != null) data['avatar'] = avatar;

      final response = await http.put(
        Uri.parse('$_baseUrl/user/profile'),
        headers: headers,
        body: json.encode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('更新用户资料出错: $e');
      return false;
    }
  }
}