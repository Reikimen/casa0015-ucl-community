import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../../providers/app_provider.dart';
import '../../providers/user_provider.dart';

class NfcLoginScreen extends StatefulWidget {
  const NfcLoginScreen({Key? key}) : super(key: key);

  @override
  _NfcLoginScreenState createState() => _NfcLoginScreenState();
}

class _NfcLoginScreenState extends State<NfcLoginScreen> with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  bool _isSuccess = false;
  bool _isError = false;
  String _errorMessage = '';

  // 动画控制器
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 初始化动画
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // 循环播放动画
    _animationController.repeat(reverse: true);

    // 检查NFC可用性
    _checkNfcAvailability();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // 停止扫描
    NfcManager.instance.stopSession();
    super.dispose();
  }

  // 检查NFC是否可用
  void _checkNfcAvailability() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        // 开始NFC扫描
        _startNfcScan();
      } else {
        setState(() {
          _isError = true;
          _errorMessage = appProvider.getLocalizedString(
            '您的设备不支持NFC功能',
            'Your device does not support NFC',
          );
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = appProvider.getLocalizedString(
          '检查NFC可用性时出错',
          'Error checking NFC availability',
        );
      });
    }
  }

  // 开始NFC扫描
  void _startNfcScan() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      _isScanning = true;
    });

    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          // 打印完整的标签数据用于调试
          debugPrint('发现NFC标签: ${tag.data}');

          // 获取标签ID
          final nfcId = _getNfcId(tag);

          if (nfcId != null) {
            debugPrint('提取的NFC ID: $nfcId');

            // 尝试使用NFC ID登录
            final success = await userProvider.loginWithNfc(nfcId);

            setState(() {
              _isScanning = false;

              if (success) {
                _isSuccess = true;
                // 登录成功后返回上一页
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pop(context);
                });
              } else {
                _isError = true;
                _errorMessage = appProvider.getLocalizedString(
                  '登录失败，此卡未注册或已失效',
                  'Login failed, this card is not registered or has expired',
                );
              }
            });

            // 停止NFC会话
            NfcManager.instance.stopSession();
          } else {
            setState(() {
              _isScanning = false;
              _isError = true;
              _errorMessage = appProvider.getLocalizedString(
                '读取NFC卡失败，请重试',
                'Failed to read NFC card, please try again',
              );
            });

            // 停止NFC会话
            NfcManager.instance.stopSession();
          }
        },
        onError: (error) {
          setState(() {
            _isScanning = false;
            _isError = true;
            _errorMessage = appProvider.getLocalizedString(
              'NFC扫描出错: $error',
              'NFC scan error: $error',
            );
          });
          return Future<void>.value(); // 添加返回值
        },
      );
    } catch (e) {
      setState(() {
        _isScanning = false;
        _isError = true;
        _errorMessage = appProvider.getLocalizedString(
          '启动NFC扫描时出错',
          'Error starting NFC scan',
        );
      });
    }
  }

  // 从NFC标签中提取ID
  String? _getNfcId(NfcTag tag) {
    debugPrint('NFC标签数据: ${tag.data}');

    // 尝试获取NDEF格式的ID
    if (tag.data.containsKey('ndef')) {
      final ndef = tag.data['ndef'];
      if (ndef != null && ndef['identifier'] != null) {
        return _bytesToHex(ndef['identifier']);
      }
    }

    // 尝试获取MIFARE格式的ID
    if (tag.data.containsKey('mifare')) {
      final mifare = tag.data['mifare'];
      if (mifare != null && mifare['identifier'] != null) {
        return _bytesToHex(mifare['identifier']);
      }
    }

    // 尝试获取ISO15693格式的ID
    if (tag.data.containsKey('iso15693')) {
      final iso15693 = tag.data['iso15693'];
      if (iso15693 != null && iso15693['identifier'] != null) {
        return _bytesToHex(iso15693['identifier']);
      }
    }

    // 尝试获取ISO14443格式的ID
    if (tag.data.containsKey('iso14443')) {
      final iso14443 = tag.data['iso14443'];
      if (iso14443 != null && iso14443['identifier'] != null) {
        return _bytesToHex(iso14443['identifier']);
      }
    }

    // 一般的标签ID
    if (tag.data.containsKey('nfca')) {
      final nfca = tag.data['nfca'];
      if (nfca != null && nfca['identifier'] != null) {
        return _bytesToHex(nfca['identifier']);
      }
    }

    // 尝试获取NfcA格式的ID (更多格式支持)
    if (tag.data.containsKey('nfca')) {
      final nfca = tag.data['nfca'];
      if (nfca != null) {
        if (nfca['identifier'] != null) {
          return _bytesToHex(nfca['identifier']);
        }
        if (nfca['id'] != null) {
          return _bytesToHex(nfca['id']);
        }
      }
    }

    // 尝试获取NfcB格式的ID
    if (tag.data.containsKey('nfcb')) {
      final nfcb = tag.data['nfcb'];
      if (nfcb != null && nfcb['applicationData'] != null) {
        return _bytesToHex(nfcb['applicationData']);
      }
    }

    // 尝试获取全部原始数据
    for (final key in tag.data.keys) {
      final data = tag.data[key];
      if (data is Map && data.containsKey('identifier')) {
        return _bytesToHex(data['identifier']);
      }
    }

    return null;
  }

  // 将字节数组转换为十六进制字符串
  String _bytesToHex(List<int> bytes) {
    return bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appProvider.getLocalizedString('NFC卡登录', 'NFC Card Login'),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 状态图标
              _buildStatusIcon(),

              const SizedBox(height: 32),

              // 状态文本
              _buildStatusText(appProvider),

              const SizedBox(height: 24),

              // 操作按钮
              _buildActionButton(appProvider),
            ],
          ),
        ),
      ),
    );
  }

  // 构建状态图标
  Widget _buildStatusIcon() {
    if (_isSuccess) {
      // 登录成功
      return const Icon(
        Icons.check_circle,
        size: 100,
        color: Colors.green,
      );
    } else if (_isError) {
      // 出现错误
      return const Icon(
        Icons.error,
        size: 100,
        color: Colors.red,
      );
    } else {
      // 正在扫描
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE53935),
                width: 2,
              ),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 波纹动画
                  Container(
                    width: 150 * _animation.value,
                    height: 150 * _animation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE53935).withOpacity(0.3 - 0.3 * _animation.value),
                    ),
                  ),
                  // NFC图标
                  const Icon(
                    Icons.nfc,
                    size: 80,
                    color: Color(0xFFE53935),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  // 构建状态文本
  Widget _buildStatusText(AppProvider appProvider) {
    if (_isSuccess) {
      // 登录成功
      return Text(
        appProvider.getLocalizedString(
          '登录成功！',
          'Login successful!',
        ),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
        textAlign: TextAlign.center,
      );
    } else if (_isError) {
      // 出现错误
      return Column(
        children: [
          Text(
            appProvider.getLocalizedString(
              '出错了',
              'Error Occurred',
            ),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      // 正在扫描
      return Column(
        children: [
          Text(
            appProvider.getLocalizedString(
              '请将NFC校园卡靠近手机背面',
              'Please place your NFC campus card close to the back of your phone',
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            appProvider.getLocalizedString(
              '保持静止直到读取完成',
              'Keep still until reading is complete',
            ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
  }

  // 构建操作按钮
  Widget _buildActionButton(AppProvider appProvider) {
    if (_isError) {
      // 出现错误，显示重试按钮
      return ElevatedButton(
        onPressed: () {
          setState(() {
            _isError = false;
            _errorMessage = '';
          });
          // 重新开始扫描
          _checkNfcAvailability();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          appProvider.getLocalizedString(
            '重试',
            'Retry',
          ),
          style: const TextStyle(fontSize: 16),
        ),
      );
    } else if (_isSuccess) {
      // 登录成功，显示确定按钮
      return ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          appProvider.getLocalizedString(
            '确定',
            'OK',
          ),
          style: const TextStyle(fontSize: 16),
        ),
      );
    } else {
      // 正在扫描，显示取消按钮
      return TextButton(
        onPressed: () {
          // 停止扫描并返回
          NfcManager.instance.stopSession();
          Navigator.pop(context);
        },
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFE53935),
        ),
        child: Text(
          appProvider.getLocalizedString(
            '取消',
            'Cancel',
          ),
          style: const TextStyle(fontSize: 16),
        ),
      );
    }
  }
}