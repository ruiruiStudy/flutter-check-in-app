import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // GitHub仓库信息
  static const String _owner = 'your-github-username'; // 替换为你的GitHub用户名
  static const String _repo = 'flutter_card_plan'; // 替换为你的仓库名
  
  // 检查更新
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      // 获取当前版本信息
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      print('当前版本: $currentVersion');
      
      // 从GitHub API获取最新版本
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$_owner/$_repo/releases/latest'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'FlutterCardPlan/1.0',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name']?.replaceAll('v', '') ?? '';
        final releaseNotes = data['body'] ?? '';
        final downloadUrl = data['assets']?.firstWhere(
          (asset) => asset['name'].toString().contains('.apk'),
          orElse: () => null,
        )?['browser_download_url'];
        
        print('最新版本: $latestVersion');
        
        if (_compareVersions(latestVersion, currentVersion) > 0) {
          return UpdateInfo(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            releaseNotes: releaseNotes,
            downloadUrl: downloadUrl,
          );
        }
      }
      
      return null;
    } catch (e) {
      print('检查更新失败: $e');
      return null;
    }
  }
  
  // 比较版本号
  static int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();
    
    // 补齐版本号长度
    while (v1Parts.length < v2Parts.length) {
      v1Parts.add(0);
    }
    while (v2Parts.length < v1Parts.length) {
      v2Parts.add(0);
    }
    
    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }
    
    return 0;
  }
  
  // 下载更新
  static Future<bool> downloadUpdate(String downloadUrl) async {
    try {
      if (await canLaunchUrl(Uri.parse(downloadUrl))) {
        return await launchUrl(Uri.parse(downloadUrl));
      }
      return false;
    } catch (e) {
      print('下载更新失败: $e');
      return false;
    }
  }
}

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;
  final String? downloadUrl;
  
  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseNotes,
    this.downloadUrl,
  });
} 