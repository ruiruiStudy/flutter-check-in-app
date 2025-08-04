import 'package:url_launcher/url_launcher.dart';

class AppLauncherService {
  // 应用包名和跳转URL映射
  static const Map<String, Map<String, List<String>>> _appConfigs = {
    '抖音': {
      'packages': [
        'com.ss.android.ugc.aweme',
        'com.ss.android.ugc.aweme.main',
        'com.ss.android.ugc.aweme.lite',
        'com.ss.android.ugc.aweme.global',
        'com.ss.android.ugc.aweme.pro',
        'com.ss.android.ugc.aweme.work',
        'com.ss.android.ugc.aweme.work.lite',
        'com.ss.android.ugc.aweme.work.pro',
      ],
      'urls': [
        'snssdk1128://user/profile/',
        'snssdk1128://main',
        'snssdk1128://home',
        'douyin://',
        'douyin://home',
        'douyin://user/profile',
      ],
    },
    '抖音极速版': {
      'packages': [
        'com.ss.android.ugc.aweme.lite',
        'com.ss.android.ugc.aweme.main.lite',
      ],
      'urls': [
        'snssdk1128://user/profile/',
        'snssdk1128://main',
        'douyin://',
      ],
    },
    '快手': {
      'packages': [
        'com.smile.gifmaker',
        'com.smile.gifmaker.main',
      ],
      'urls': [
        'gifmaker://user/profile',
        'gifmaker://main',
        'kuaishou://',
      ],
    },
    '快手极速版': {
      'packages': [
        'com.smile.gifmaker.lite',
        'com.smile.gifmaker.main.lite',
      ],
      'urls': [
        'gifmaker://user/profile',
        'gifmaker://main',
        'kuaishou://',
      ],
    },
    '支付宝': {
      'packages': [
        'com.eg.android.AlipayGphone',
        'com.alipay.android.phone.openplatform',
      ],
      'urls': [
        'alipay://platformapi/startapp',
        'alipay://',
      ],
    },
  };

  // 检查任务名称是否包含特定关键词
  static bool shouldShowAppButton(String taskName) {
    return _appConfigs.keys.any((keyword) => taskName.contains(keyword));
  }

  // 获取应用配置
  static Map<String, List<String>>? getAppConfig(String taskName) {
    for (String keyword in _appConfigs.keys) {
      if (taskName.contains(keyword)) {
        return _appConfigs[keyword];
      }
    }
    return null;
  }

  // 获取按钮文本
  static String getButtonText(String taskName) {
    for (String keyword in _appConfigs.keys) {
      if (taskName.contains(keyword)) {
        return '打开$keyword';
      }
    }
    return '打开APP';
  }

  // 跳转到应用
  static Future<bool> launchApp(String taskName) async {
    final config = getAppConfig(taskName);
    if (config == null) {
      print('未找到应用配置: $taskName');
      return false;
    }

    try {
      final packages = config['packages'] as List<String>;
      final urls = config['urls'] as List<String>;

      print('尝试启动应用: $taskName');
      print('可用包名: $packages');
      print('可用URL: $urls');

      // 首先尝试使用包名启动应用
      for (String package in packages) {
        final packageUrl = 'package:$package';
        print('尝试包名: $packageUrl');
        
        final canLaunch = await canLaunchUrl(Uri.parse(packageUrl));
        print('包名 $package 可启动: $canLaunch');
        
        if (canLaunch) {
          final success = await launchUrl(Uri.parse(packageUrl));
          print('包名 $package 启动结果: $success');
          if (success) {
            print('成功启动应用包: $package');
            return true;
          }
        }
      }

      // 如果包名启动失败，尝试使用自定义URL
      for (String url in urls) {
        print('尝试URL: $url');
        
        final canLaunch = await canLaunchUrl(Uri.parse(url));
        print('URL $url 可启动: $canLaunch');
        
        if (canLaunch) {
          final success = await launchUrl(Uri.parse(url));
          print('URL $url 启动结果: $success');
          if (success) {
            print('成功启动应用URL: $url');
            return true;
          }
        }
      }

      print('所有启动方式都失败了');
      return false;
    } catch (e) {
      print('启动应用失败: $e');
      return false;
    }
  }
} 