import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import 'today_check_in_page.dart';
import 'task_list_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TodayCheckInPage(),
    const TaskListPage(),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化时加载任务数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
      // 检查更新
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    try {
      final updateInfo = await UpdateService.checkForUpdate();
      if (updateInfo != null && mounted) {
        final shouldUpdate = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => UpdateDialog(updateInfo: updateInfo),
        );
        
        if (shouldUpdate == true && updateInfo.downloadUrl != null) {
          await UpdateService.downloadUpdate(updateInfo.downloadUrl!);
        }
      }
    } catch (e) {
      print('检查更新失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: '今日打卡',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '任务列表',
          ),
        ],
      ),
    );
  }
} 