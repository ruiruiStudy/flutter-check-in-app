import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  
  List<Task> _allTasks = [];
  List<Task> _todayTasks = [];
  List<Task> _inProgressTasks = [];
  List<Task> _completedTasks = [];
  List<Task> _notStartedTasks = [];
  
  bool _isLoading = false;
  
  // Getters
  List<Task> get allTasks => _allTasks;
  List<Task> get todayTasks => _todayTasks;
  List<Task> get inProgressTasks => _inProgressTasks;
  List<Task> get completedTasks => _completedTasks;
  List<Task> get notStartedTasks => _notStartedTasks;
  bool get isLoading => _isLoading;
  
  // 加载所有任务
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _allTasks = await _taskService.getAllTasks();
      _todayTasks = await _taskService.getTodayTasks();
      _inProgressTasks = await _taskService.getInProgressTasks();
      _completedTasks = await _taskService.getCompletedTasks();
      _notStartedTasks = await _taskService.getNotStartedTasks();
    } catch (e) {
      debugPrint('加载任务失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 添加任务
  Future<void> addTask(Task task) async {
    try {
      await _taskService.addTask(task);
      await loadTasks();
    } catch (e) {
      debugPrint('添加任务失败: $e');
    }
  }
  
  // 更新任务
  Future<void> updateTask(Task task) async {
    try {
      await _taskService.updateTask(task);
      await loadTasks();
    } catch (e) {
      debugPrint('更新任务失败: $e');
    }
  }
  
  // 删除任务
  Future<void> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      await loadTasks();
    } catch (e) {
      debugPrint('删除任务失败: $e');
    }
  }
  
  // 删除已完成的任务
  Future<void> deleteCompletedTasks() async {
    try {
      await _taskService.deleteCompletedTasks();
      await loadTasks();
    } catch (e) {
      debugPrint('删除已完成任务失败: $e');
    }
  }
  
  // 批量打卡
  Future<void> batchCheckIn(List<String> taskIds) async {
    try {
      await _taskService.batchCheckIn(taskIds);
      await loadTasks();
    } catch (e) {
      debugPrint('批量打卡失败: $e');
    }
  }
  
  // 一键打卡所有未打卡的任务
  Future<void> checkInAllTodayTasks() async {
    try {
      await _taskService.checkInAllTodayTasks();
      await loadTasks();
    } catch (e) {
      debugPrint('一键打卡失败: $e');
    }
  }
  
  // 生成任务ID
  String generateTaskId() {
    return _taskService.generateId();
  }
} 