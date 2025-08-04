import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task.dart';
import 'task_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;
  
  // 初始化通知
  static Future<void> initialize() async {
    if (_initialized) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
    _initialized = true;
  }
  
  // 请求通知权限
  static Future<bool> requestPermission() async {
    await initialize();
    
    // 对于Android 13及以上版本，需要请求通知权限
    if (await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled() == false) {
      return await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission() ?? false;
    }
    
    return true;
  }
  
  // 设置每日提醒
  static Future<void> scheduleDailyReminder() async {
    await initialize();
    
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      '每日打卡提醒',
      channelDescription: '每日晚上9点提醒打卡',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // 设置每天晚上9点提醒
    await _notifications.periodicallyShow(
      0, // 通知ID
      '打卡提醒',
      '今天还有未完成的打卡任务，记得及时完成哦！',
      RepeatInterval.daily,
      details,
    );
  }
  
  // 取消每日提醒
  static Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0);
  }
  
  // 发送即时通知
  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 1,
  }) async {
    await initialize();
    
    const androidDetails = AndroidNotificationDetails(
      'check_in_reminder',
      '打卡提醒',
      channelDescription: '打卡相关通知',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(id, title, body, details);
  }
  
  // 检查是否需要发送通知
  static Future<void> checkAndSendNotification() async {
    final taskService = TaskService();
    final todayTasks = await taskService.getTodayTasks();
    
    // 检查是否有未完成的打卡任务
    final hasUnfinishedTasks = todayTasks.any((task) => !task.isTodayChecked);
    
    if (hasUnfinishedTasks) {
      await showNotification(
        title: '打卡提醒',
        body: '今天还有未完成的打卡任务，记得及时完成哦！',
      );
    }
  }
} 