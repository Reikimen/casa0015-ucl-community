// 文件: lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import '../models/comment_model.dart';
import 'storage_service.dart';

class ApiService {
  // API基础URL (这里用模拟地址，实际开发中替换为真实地址)
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

  // 获取关注的帖子
  Future<List<Post>> getStaredPosts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/stared'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('获取关注帖子失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('获取关注帖子出错: $e');
      // 返回空列表，避免UI崩溃
      return [];
    }
  }

  // 获取探索帖子
  Future<List<Post>> getExplorePosts(String category) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/explore?category=$category'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('获取探索帖子失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('获取探索帖子出错: $e');
      return [];
    }
  }

  // 获取热门帖子
  Future<List<Post>> getHotPosts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/hot'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('获取热门帖子失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('获取热门帖子出错: $e');
      return [];
    }
  }

  // 获取帖子详情
  Future<Post?> getPostDetail(String postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/$postId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return Post.fromJson(data);
      } else {
        throw Exception('获取帖子详情失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('获取帖子详情出错: $e');
      return null;
    }
  }

  // 获取帖子评论
  Future<List<Comment>> getPostComments(String postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/$postId/comments'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('获取帖子评论失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('获取帖子评论出错: $e');
      return [];
    }
  }

  // 发布帖子
  Future<bool> createPost(String title, String content, String imageUrl) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/posts'),
        headers: headers,
        body: json.encode({
          'title': title,
          'content': content,
          'image_url': imageUrl,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('发布帖子出错: $e');
      return false;
    }
  }

  // 发表评论
  Future<bool> createComment(String postId, String content) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/posts/$postId/comments'),
        headers: headers,
        body: json.encode({
          'content': content,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('发表评论出错: $e');
      return false;
    }
  }

  // 点赞帖子
  Future<bool> likePost(String postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/posts/$postId/like'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('点赞帖子出错: $e');
      return false;
    }
  }

  // 取消点赞
  Future<bool> unlikePost(String postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/posts/$postId/like'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('取消点赞出错: $e');
      return false;
    }
  }

  // 获取用户发布的帖子
  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/posts'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('获取用户帖子失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('获取用户帖子出错: $e');
      return [];
    }
  }

  // 分享帖子
  Future<bool> sharePost(String postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/posts/$postId/share'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('分享帖子出错: $e');
      return false;
    }
  }
}