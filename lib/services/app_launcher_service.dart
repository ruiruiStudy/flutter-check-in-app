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
        'com.ss.android.ugc.aweme.lite.main',
        'com.ss.android.ugc.aweme.lite.global',
        'com.ss.android.ugc.aweme.lite.pro',
        'com.ss.android.ugc.aweme.lite.work',
        'com.ss.android.ugc.aweme.lite.work.lite',
        'com.ss.android.ugc.aweme.lite.work.pro',
      ],
      'urls': [
        'snssdk1128://user/profile/',
        'snssdk1128://main',
        'snssdk1128://home',
        'snssdk1128://',
        'douyin://',
        'douyin://home',
        'douyin://user/profile',
        'douyin://main',
        'douyin://user',
        'douyin://profile',
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
    // 添加YouTube配置
    'YouTube': {
      'packages': [
        'com.google.android.youtube',
        'com.google.android.youtube.tv',
        'com.google.android.youtube.go',
        'com.google.android.youtube.music',
      ],
      'urls': [
        'youtube://',
        'vnd.youtube://',
        'https://www.youtube.com',
        'https://m.youtube.com',
        'youtube://www.youtube.com',
        'youtube://youtube.com',
        'youtube://m.youtube.com',
        'youtube://www.youtube.com/',
        'youtube://youtube.com/',
        'youtube://m.youtube.com/',
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

      print('=== 应用启动调试信息 ===');
      print('任务名称: $taskName');
      print('可用包名: $packages');
      print('可用URL: $urls');

      // 首先尝试使用包名启动应用
      for (String package in packages) {
        final packageUrl = 'package:$package';
        print('\n--- 尝试包名启动 ---');
        print('包名: $package');
        print('完整URL: $packageUrl');
        
        try {
          final canLaunch = await canLaunchUrl(Uri.parse(packageUrl));
          print('canLaunchUrl 结果: $canLaunch');
          
          if (canLaunch) {
            final success = await launchUrl(
              Uri.parse(packageUrl),
              mode: LaunchMode.externalApplication,
            );
            print('launchUrl 结果: $success');
            if (success) {
              print('✅ 成功启动应用包: $package');
              return true;
            } else {
              print('❌ launchUrl 返回 false');
            }
          } else {
            print('❌ canLaunchUrl 返回 false');
          }
        } catch (e) {
          print('❌ 包名启动异常: $e');
        }
      }

      // 如果包名启动失败，尝试使用自定义URL
      for (String url in urls) {
        print('\n--- 尝试URL启动 ---');
        print('URL: $url');
        
        try {
          final canLaunch = await canLaunchUrl(Uri.parse(url));
          print('canLaunchUrl 结果: $canLaunch');
          
          if (canLaunch) {
            final success = await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            );
            print('launchUrl 结果: $success');
            if (success) {
              print('✅ 成功启动应用URL: $url');
              return true;
            } else {
              print('❌ launchUrl 返回 false');
            }
          } else {
            print('❌ canLaunchUrl 返回 false');
          }
        } catch (e) {
          print('❌ URL启动异常: $e');
        }
      }

      // 最后尝试使用Intent方式启动
      print('\n--- 尝试Intent启动 ---');
      try {
        final intentUrl = 'intent://youtube.com#Intent;package=com.google.android.youtube;end';
        final canLaunch = await canLaunchUrl(Uri.parse(intentUrl));
        print('Intent canLaunchUrl 结果: $canLaunch');
        
        if (canLaunch) {
          final success = await launchUrl(
            Uri.parse(intentUrl),
            mode: LaunchMode.externalApplication,
          );
          print('Intent launchUrl 结果: $success');
          if (success) {
            print('✅ 成功使用Intent启动YouTube');
            return true;
          }
        }
      } catch (e) {
        print('❌ Intent启动异常: $e');
      }

      print('\n❌ 所有启动方式都失败了');
      return false;
    } catch (e) {
      print('❌ 启动应用总体异常: $e');
      return false;
    }
  }
} 