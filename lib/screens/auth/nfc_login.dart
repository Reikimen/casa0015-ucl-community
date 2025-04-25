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
    try {
      // 停止扫描
      NfcManager.instance.stopSession();
    } catch (e) {
      debugPrint('停止NFC会话时出错: $e');
    }
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
      debugPrint('检查NFC可用性时出错: $e');
      setState(() {
        _isError = true;
        _errorMessage = appProvider.getLocalizedString(
          '检查NFC可用性时出错: $e',
          'Error checking NFC availability: $e',
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
          try {
            // 打印完整的标签数据用于调试
            debugPrint('发现NFC标签');

            // 尝试打印标签数据，但捕获异常
            try {
              debugPrint('NFC标签数据: ${tag.data}');

              // 打印完整的标签结构，帮助调试
              debugPrint('完整NFC标签数据结构:');
              tag.data.forEach((key, value) {
                debugPrint('- $key: $value');
                if (value is Map) {
                  value.forEach((subKey, subValue) {
                    debugPrint('  - $subKey: $subValue');
                  });
                }
              });
            } catch (e) {
              debugPrint('打印NFC数据时出错: $e');
            }

            // 获取标签ID
            String? nfcId;
            try {
              nfcId = _getNfcId(tag);
              debugPrint('提取的NFC ID: $nfcId');
            } catch (e) {
              debugPrint('获取NFC ID时出错: $e');
              nfcId = null;
            }

            if (nfcId != null && nfcId.isNotEmpty) {
              bool success = false;
              try {
                // 尝试使用NFC ID登录
                success = await userProvider.loginWithNfc(nfcId);
              } catch (e) {
                debugPrint('调用loginWithNfc时出错: $e');
                success = false;
              }

              if (mounted) {
                setState(() {
                  _isScanning = false;

                  if (success) {
                    _isSuccess = true;
                    // 登录成功后返回上一页
                    Future.delayed(const Duration(seconds: 1), () {
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    });
                  } else {
                    _isError = true;
                    _errorMessage = appProvider.getLocalizedString(
                      '登录失败，此卡未注册或已失效',
                      'Login failed, this card is not registered or has expired',
                    );
                  }
                });
              }

              // 停止NFC会话
              try {
                NfcManager.instance.stopSession();
              } catch (e) {
                debugPrint('停止NFC会话时出错: $e');
              }
            } else {
              if (mounted) {
                setState(() {
                  _isScanning = false;
                  _isError = true;
                  _errorMessage = appProvider.getLocalizedString(
                    '读取NFC卡失败，请重试',
                    'Failed to read NFC card, please try again',
                  );
                });
              }

              // 停止NFC会话
              try {
                NfcManager.instance.stopSession();
              } catch (e) {
                debugPrint('停止NFC会话时出错: $e');
              }
            }
          } catch (e) {
            debugPrint('处理NFC标签时出错: $e');
            if (mounted) {
              setState(() {
                _isScanning = false;
                _isError = true;
                _errorMessage = appProvider.getLocalizedString(
                  '处理NFC卡数据时出错: $e',
                  'Error processing NFC card data: $e',
                );
              });
            }

            // 停止NFC会话
            try {
              NfcManager.instance.stopSession();
            } catch (e) {
              debugPrint('停止NFC会话时出错: $e');
            }
          }
        },
        onError: (error) {
          debugPrint('NFC会话出错: $error');
          if (mounted) {
            setState(() {
              _isScanning = false;
              _isError = true;
              _errorMessage = appProvider.getLocalizedString(
                'NFC扫描出错: $error',
                'NFC scan error: $error',
              );
            });
          }
          return Future<void>.value(); // 添加返回值
        },
      );
    } catch (e) {
      debugPrint('启动NFC扫描时出错: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
          _isError = true;
          _errorMessage = appProvider.getLocalizedString(
            '启动NFC扫描时出错: $e',
            'Error starting NFC scan: $e',
          );
        });
      }
    }
  }

  // 从NFC标签中提取ID
  String? _getNfcId(NfcTag tag) {
    try {
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

      // 尝试获取NfcA格式的ID
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

      // 如果上述方法都失败，尝试备用方法
      return _fallbackGetNfcId(tag);
    } catch (e) {
      debugPrint('提取NFC ID时出错: $e');
      return _fallbackGetNfcId(tag);
    }
  }

  // 备用方法：尝试从任何字节数组中提取ID
  // 修改后的 _fallbackGetNfcId 方法
  String? _fallbackGetNfcId(NfcTag tag) {
    try {
      // 遍历所有数据，找到任何可能的字节数组
      for (final entry in tag.data.entries) {
        final value = entry.value;
        if (value is Map) {
          for (final subEntry in value.entries) {
            if (subEntry.value is List && (subEntry.value as List).isNotEmpty) {
              debugPrint('使用备用方法从 ${entry.key}.${subEntry.key} 提取ID');
              // 修复类型转换问题
              final List<dynamic> dynamicList = subEntry.value as List;
              final List<int> intList = List<int>.from(dynamicList.map((item) => item is int ? item : 0));
              return _bytesToHex(intList);
            }
          }
        } else if (value is List && value.isNotEmpty) {
          debugPrint('使用备用方法从 ${entry.key} 直接提取ID');
          // 修复类型转换问题
          final List<dynamic> dynamicList = value as List;
          final List<int> intList = List<int>.from(dynamicList.map((item) => item is int ? item : 0));
          return _bytesToHex(intList);
        }
      }
      return null;
    } catch (e) {
      debugPrint('备用NFC ID提取方法失败: $e');
      return null;
    }
  }

  // 修改后的 _bytesToHex 方法
  String _bytesToHex(List<int> bytes) {
    try {
      return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    } catch (e) {
      debugPrint('字节转十六进制失败: $e');
      // 更加健壮的实现
      String result = '';
      for (var byte in bytes) {
        try {
          result += byte.toRadixString(16).padLeft(2, '0');
        } catch (e) {
          debugPrint('处理单个字节时出错: $e');
        }
      }
      return result;
    }
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

              // 调试按钮 - 仅用于测试，可以在生产环境中移除
              if (_isScanning)
                ElevatedButton(
                  onPressed: () {
                    // 模拟发现一个固定的NFC ID (对应auth_service.dart中的测试用户)
                    _simulateNfcDetection('04215aa22a0289');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Login As Admin'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 模拟NFC检测 - 仅用于调试
  void _simulateNfcDetection(String mockNfcId) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    debugPrint('模拟NFC扫描，使用ID: $mockNfcId');

    try {
      // 尝试停止任何活动的NFC会话
      NfcManager.instance.stopSession();
    } catch (e) {
      debugPrint('停止NFC会话时出错: $e');
    }

    try {
      final success = await userProvider.loginWithNfc(mockNfcId);

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
    } catch (e) {
      debugPrint('模拟NFC登录时出错: $e');
      setState(() {
        _isScanning = false;
        _isError = true;
        _errorMessage = '模拟登录出错: $e';
      });
    }
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
          try {
            NfcManager.instance.stopSession();
          } catch (e) {
            debugPrint('停止NFC会话时出错: $e');
          }
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