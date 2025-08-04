import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import 'add_edit_task_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdate() async {
    try {
      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final updateInfo = await UpdateService.checkForUpdate();
      
      // 关闭加载指示器
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (updateInfo != null && mounted) {
        final shouldUpdate = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => UpdateDialog(updateInfo: updateInfo),
        );
        
        if (shouldUpdate == true && updateInfo.downloadUrl != null) {
          await UpdateService.downloadUpdate(updateInfo.downloadUrl!);
        }
      } else if (mounted) {
        // 没有更新时显示提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('当前已是最新版本'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 关闭加载指示器
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('检查更新失败: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务列表'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '进行中'),
            Tab(text: '已完成'),
            Tab(text: '未开始'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update),
            tooltip: '检查更新',
            onPressed: _checkForUpdate,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddEditTaskPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(TaskStatus.inProgress),
          _buildTaskList(TaskStatus.completed),
          _buildTaskList(TaskStatus.notStarted),
        ],
      ),
    );
  }

  Widget _buildTaskList(TaskStatus status) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        List<Task> tasks;
        switch (status) {
          case TaskStatus.inProgress:
            tasks = taskProvider.inProgressTasks;
            break;
          case TaskStatus.completed:
            tasks = taskProvider.completedTasks;
            break;
          case TaskStatus.notStarted:
            tasks = taskProvider.notStartedTasks;
            break;
        }

        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无${status.displayName}的任务',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildTaskCard(task, status);
          },
        );
      },
    );
  }

  Widget _buildTaskCard(Task task, TaskStatus status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          task.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '${DateFormat('yyyy年MM月dd日').format(task.startDate)} - ${DateFormat('yyyy年MM月dd日').format(task.endDate)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (task.note != null && task.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '备注: ${task.note}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: task.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      status == TaskStatus.completed
                          ? Colors.green
                          : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${task.checkedDays}/${task.totalDays}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: status == TaskStatus.completed
            ? PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    await _showDeleteDialog(task);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('删除'),
                      ],
                    ),
                  ),
                ],
              )
            : IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddEditTaskPage(task: task),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showDeleteDialog(Task task) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除任务"${task.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Provider.of<TaskProvider>(context, listen: false)
                  .deleteTask(task.id);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
} 