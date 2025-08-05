import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/app_launcher_service.dart';

class TodayCheckInPage extends StatefulWidget {
  const TodayCheckInPage({super.key});

  @override
  State<TodayCheckInPage> createState() => _TodayCheckInPageState();
}

class _TodayCheckInPageState extends State<TodayCheckInPage> {
  final Set<String> _selectedTaskIds = <String>{};



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日打卡'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _selectedTaskIds.isEmpty ? null : _checkInSelected,
            child: const Text('打卡'),
          ),
          TextButton(
            onPressed: _checkInAll,
            child: const Text('一键打卡'),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final todayTasks = taskProvider.todayTasks;

          if (todayTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '今天没有需要打卡的任务',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '太棒了！所有任务都已完成',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 统计信息
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '总任务',
                        todayTasks.length.toString(),
                        Icons.task_alt,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        '已完成',
                        todayTasks.where((task) => task.isTodayChecked).length.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        '待完成',
                        todayTasks.where((task) => !task.isTodayChecked).length.toString(),
                        Icons.pending,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              // 任务列表
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: todayTasks.length,
                      itemBuilder: (context, index) {
                        final task = todayTasks[index];
                        return _buildTaskCard(task);
                      },
                    ),
                    // 添加固定在底部的YouTube按钮
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        // onPressed: _openYouTube,
                        onPressed: () => _launchApp('YouTube'),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        tooltip: '测试打开YouTube',
                        child: const Icon(Icons.video_library),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final isChecked = task.isTodayChecked;
    final isSelected = _selectedTaskIds.contains(task.id);
    final shouldShowAppButton = AppLauncherService.shouldShowAppButton(task.name);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedTaskIds.add(task.id);
              } else {
                _selectedTaskIds.remove(task.id);
              }
            });
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  color: isChecked ? Colors.grey : null,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isChecked ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isChecked ? '已完成' : '待完成',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '进度: ${task.checkedDays}/${task.totalDays}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: task.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isChecked ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(task.progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // 应用跳转按钮
            if (shouldShowAppButton) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchApp(task.name),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(AppLauncherService.getButtonText(task.name)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: isChecked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => _checkInSingleTask(task.id),
              ),
      ),
    );
  }

  Future<void> _launchApp(String taskName) async {
    try {
      print('开始尝试打开应用: $taskName');
      final success = await AppLauncherService.launchApp(taskName);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('正在打开应用...')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('无法打开应用，请检查是否已安装 $taskName'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('应用启动异常: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('打开应用失败: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _checkInSelected() async {
    if (_selectedTaskIds.isEmpty) return;

    try {
      await Provider.of<TaskProvider>(context, listen: false)
          .batchCheckIn(_selectedTaskIds.toList());
      
      setState(() {
        _selectedTaskIds.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('打卡成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打卡失败: $e')),
        );
      }
    }
  }

  Future<void> _checkInAll() async {
    try {
      await Provider.of<TaskProvider>(context, listen: false)
          .checkInAllTodayTasks();
      
      setState(() {
        _selectedTaskIds.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('一键打卡成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('一键打卡失败: $e')),
        );
      }
    }
  }

  Future<void> _checkInSingleTask(String taskId) async {
    try {
      await Provider.of<TaskProvider>(context, listen: false)
          .batchCheckIn([taskId]);
      
      setState(() {
        _selectedTaskIds.remove(taskId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('打卡成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打卡失败: $e')),
        );
      }
    }
  }
} 