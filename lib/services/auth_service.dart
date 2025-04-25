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

  // 修改 loginWithNfc 方法以生成包含用户ID的 token
  Future<AuthResult> loginWithNfc(String nfcId) async {
    if (nfcId == null || nfcId.isEmpty) {
      debugPrint('NFC ID为空，无法登录');
      return AuthResult(
        success: false,
        errorMessage: 'NFC ID为空',
      );
    }

    debugPrint('尝试使用NFC ID登录: $nfcId');

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (_mockNfcUsers.containsKey(nfcId)) {
        final user = _mockNfcUsers[nfcId]!;
        // 生成包含用户ID的 token
        final token = 'mock_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

        debugPrint('NFC登录成功: ${user.username}');

        return AuthResult(
          success: true,
          user: user,
          token: token,
        );
      } else {
        debugPrint('NFC登录失败: 未找到与ID关联的用户');
        debugPrint('注册的NFC IDs: ${_mockNfcUsers.keys.join(', ')}');
        return AuthResult(
          success: false,
          errorMessage: '未找到与此NFC卡关联的用户',
        );
      }
    } catch (e) {
      debugPrint('NFC登录过程中出错: $e');
      return AuthResult(
        success: false,
        errorMessage: '登录过程出错，请重试',
      );
    }
  }

  // 添加获取当前用户信息的方法
  Future<User?> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final token = await _storageService.getAuthToken();

      if (token != null && token.isNotEmpty) {
        // 检查 token 格式是否正确
        if (token.startsWith('mock_token_')) {
          // 从 token 中解析用户ID
          final parts = token.split('_');
          if (parts.length >= 3) {
            final userId = parts[2];

            // 查找匹配的用户
            for (var entry in _mockNfcUsers.entries) {
              if (entry.value.id == userId) {
                debugPrint('找到匹配的用户: ${entry.value.username}');
                return entry.value;
              }
            }
          }

          // 如果没有找到匹配的用户，返回一个默认用户
          return User(
            id: 'user1',
            username: '测试用户',
            studentId: '2023001',
            bio: '这是一个测试账号',
            followersCount: 10,
            followingCount: 5,
            likesCount: 20,
          );
        }
      }

      return null;
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