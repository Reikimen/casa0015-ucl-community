import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../providers/app_provider.dart';
import '../providers/post_provider.dart';

class ShakeDetector extends StatefulWidget {
  const ShakeDetector({Key? key}) : super(key: key);

  @override
  _ShakeDetectorState createState() => _ShakeDetectorState();
}

class _ShakeDetectorState extends State<ShakeDetector> {
  // 加速度传感器订阅
  late final Stream<AccelerometerEvent> _accelerometerStream;

  // 上次记录的加速度值
  AccelerometerEvent? _lastAcceleration;

  // 上次摇晃时间(防止频繁触发)
  DateTime? _lastShakeTime;

  // 摇晃阈值
  final double _shakeThreshold = 12.0;

  // 最小触发间隔(秒)
  final int _minimumShakeInterval = 2;

  // 是否显示刷新指示器
  bool _showRefreshing = false;

  @override
  void initState() {
    super.initState();

    // 初始化加速度传感器
    _accelerometerStream = accelerometerEvents;

    // 开始监听摇晃事件
    _startListening();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 开始监听摇晃事件
  void _startListening() {
    _accelerometerStream.listen((AccelerometerEvent event) {
      // 如果没有上一次记录的加速度值，则记录当前值
      if (_lastAcceleration == null) {
        _lastAcceleration = event;
        return;
      }

      // 计算当前加速度与上一次的差值
      final double deltaX = event.x - _lastAcceleration!.x;
      final double deltaY = event.y - _lastAcceleration!.y;
      final double deltaZ = event.z - _lastAcceleration!.z;

      // 计算加速度变化总量
      final double acceleration = deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ;

      // 更新上一次加速度值
      _lastAcceleration = event;

      // 判断是否达到摇晃阈值
      if (acceleration > _shakeThreshold * _shakeThreshold) {
        final DateTime now = DateTime.now();

        // 检查是否超过最小触发间隔
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!).inSeconds > _minimumShakeInterval) {
          _lastShakeTime = now;

          // 处理摇晃事件
          _onShake();
        }
      }
    });
  }

  // 处理摇晃事件
  void _onShake() {
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);

      // 显示刷新提示
      setState(() {
        _showRefreshing = true;
      });

      // 刷新内容 - 现在会特别更新推荐页面
      postProvider.refreshCurrentTab().then((_) {
        // 延迟一段时间后隐藏提示
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _showRefreshing = false;
            });
          }
        });

        // 显示刷新成功提示
        if (context.mounted) {
          String message = '';
          // 如果在"发现"标签页的"推荐"分类下，显示特殊消息
          if (postProvider.currentTab == HomeTab.explore &&
              postProvider.currentCategory == ExploreCategory.recommended) {
            message = appProvider.getLocalizedString(
              '摇一摇成功！为您更新了推荐内容',
              'Shake successful! Refreshed recommended content for you',
            );
          } else {
            message = appProvider.getLocalizedString(
              '摇一摇刷新成功，为您更新了内容',
              'Shake refresh successful, content updated for you',
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFFE53935),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('摇一摇刷新出错: $e');
      if (mounted) {
        setState(() {
          _showRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果正在刷新，显示提示
    if (_showRefreshing) {
      final appProvider = Provider.of<AppProvider>(context);

      return Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appProvider.getLocalizedString(
                      '正在刷新内容...',
                      'Refreshing content...',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 不显示任何内容
    return const SizedBox.shrink();
  }
}