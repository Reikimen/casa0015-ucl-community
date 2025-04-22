import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppHelpers {
  // 格式化日期
  static String formatDate(DateTime date, {bool showTime = false, String locale = 'zh'}) {
    final formatter = locale == 'zh'
        ? DateFormat('yyyy年MM月dd日${showTime ? ' HH:mm' : ''}')
        : DateFormat('MMM dd, yyyy${showTime ? ' HH:mm' : ''}');

    return formatter.format(date);
  }

  // 格式化相对时间（多久之前）
  static String formatRelativeTime(DateTime dateTime, {String locale = 'zh'}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (locale == 'zh') {
      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years年前';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months个月前';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}天前';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}小时前';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}分钟前';
      } else {
        return '刚刚';
      }
    } else {
      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'Just now';
      }
    }
  }

  // 裁剪字符串（如果太长）
  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  // 防抖函数
  static Timer? _debounceTimer;

  static void debounce(Function callback, {Duration duration = const Duration(milliseconds: 500)}) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(duration, () {
      callback();
    });
  }

  // 节流函数
  static DateTime? _throttleTime;

  static bool throttle({Duration duration = const Duration(milliseconds: 1000)}) {
    final now = DateTime.now();

    if (_throttleTime == null || now.difference(_throttleTime!) > duration) {
      _throttleTime = now;
      return true;
    }

    return false;
  }

  // 显示加载对话框
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? '加载中...'),
          ],
        ),
      ),
    );
  }

  // 显示确认对话框
  static Future<bool> showConfirmDialog(
      BuildContext context, {
        required String title,
        required String content,
        String? confirmText,
        String? cancelText,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText ?? '取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText ?? '确认'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // 显示底部操作表
  static Future<T?> showActionSheet<T>(
      BuildContext context, {
        required List<ActionSheetItem<T>> items,
        String? title,
      }) async {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖动条
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 标题
            if (title != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // 选项列表
            ...items.map((item) => ListTile(
              leading: item.icon != null ? Icon(item.icon) : null,
              title: Text(item.title),
              onTap: () => Navigator.pop(context, item.value),
              textColor: item.isDestructive ? Colors.red : null,
              iconColor: item.isDestructive ? Colors.red : null,
            )),

            // 底部安全区域
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  // 显示定制Snackbar
  static void showSnackBar(
      BuildContext context, {
        required String message,
        Color? backgroundColor,
        Duration duration = const Duration(seconds: 2),
        SnackBarAction? action,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  // 验证邮箱格式
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  // 验证URL格式
  static bool isValidUrl(String url) {
    final urlRegExp = RegExp(
      r'^(http|https)://[a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)',
    );
    return urlRegExp.hasMatch(url);
  }
}

// 操作表选项
class ActionSheetItem<T> {
  final String title;
  final IconData? icon;
  final T value;
  final bool isDestructive;

  ActionSheetItem({
    required this.title,
    this.icon,
    required this.value,
    this.isDestructive = false,
  });
}