import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static const String _tasksKey = 'tasks';
  
  // 获取所有任务
  Future<List<Task>> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];
    
    return tasksJson
        .map((json) => Task.fromJson(jsonDecode(json)))
        .toList();
  }
  
  // 保存所有任务
  Future<void> saveAllTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks
        .map((task) => jsonEncode(task.toJson()))
        .toList();
    
    await prefs.setStringList(_tasksKey, tasksJson);
  }
  
  // 添加任务
  Future<void> addTask(Task task) async {
    final tasks = await getAllTasks();
    tasks.add(task);
    await saveAllTasks(tasks);
  }
  
  // 更新任务
  Future<void> updateTask(Task task) async {
    final tasks = await getAllTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await saveAllTasks(tasks);
    }
  }
  
  // 删除任务
  Future<void> deleteTask(String taskId) async {
    final tasks = await getAllTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await saveAllTasks(tasks);
  }
  
  // 删除已完成的任务
  Future<void> deleteCompletedTasks() async {
    final tasks = await getAllTasks();
    final remainingTasks = tasks.where((task) => task.status != TaskStatus.completed).toList();
    await saveAllTasks(remainingTasks);
  }
  
  // 获取进行中的任务
  Future<List<Task>> getInProgressTasks() async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.status == TaskStatus.inProgress).toList();
  }
  
  // 获取已完成的任务
  Future<List<Task>> getCompletedTasks() async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.status == TaskStatus.completed).toList();
  }
  
  // 获取未开始的任务
  Future<List<Task>> getNotStartedTasks() async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.status == TaskStatus.notStarted).toList();
  }
  
  // 获取今日需要打卡的任务
  Future<List<Task>> getTodayTasks() async {
    final tasks = await getAllTasks();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    return tasks.where((task) {
      final startDate = DateTime(task.startDate.year, task.startDate.month, task.startDate.day);
      final endDate = DateTime(task.endDate.year, task.endDate.month, task.endDate.day);
      return todayDate.isAtSameMomentAs(startDate) || 
             (todayDate.isAfter(startDate) && todayDate.isBefore(endDate)) ||
             todayDate.isAtSameMomentAs(endDate);
    }).toList();
  }
  
  // 批量打卡
  Future<void> batchCheckIn(List<String> taskIds) async {
    final tasks = await getAllTasks();
    for (int i = 0; i < tasks.length; i++) {
      if (taskIds.contains(tasks[i].id)) {
        tasks[i] = tasks[i].addTodayCheckIn();
      }
    }
    await saveAllTasks(tasks);
  }
  
  // 一键打卡所有未打卡的任务
  Future<void> checkInAllTodayTasks() async {
    final todayTasks = await getTodayTasks();
    final uncheckedTaskIds = todayTasks
        .where((task) => !task.isTodayChecked)
        .map((task) => task.id)
        .toList();
    
    await batchCheckIn(uncheckedTaskIds);
  }
  
  // 生成唯一ID
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
} 