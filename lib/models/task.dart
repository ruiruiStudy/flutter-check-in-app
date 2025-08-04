import 'dart:convert';

class Task {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String? note;
  final bool enableNotification;
  final List<DateTime> checkInDates;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.note,
    required this.enableNotification,
    List<DateTime>? checkInDates,
    DateTime? createdAt,
  })  : checkInDates = checkInDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  // 获取任务状态
  TaskStatus get status {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (today.isBefore(startDate)) {
      return TaskStatus.notStarted;
    } else if (today.isAfter(endDate)) {
      return TaskStatus.completed;
    } else {
      return TaskStatus.inProgress;
    }
  }

  // 获取总天数
  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  // 获取已打卡天数
  int get checkedDays {
    return checkInDates.length;
  }

  // 获取进度百分比
  double get progress {
    if (totalDays == 0) return 0.0;
    return checkedDays / totalDays;
  }

  // 检查今天是否已打卡
  bool get isTodayChecked {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return checkInDates.any((date) {
      final checkDate = DateTime(date.year, date.month, date.day);
      return checkDate.isAtSameMomentAs(todayDate);
    });
  }

  // 添加今日打卡
  Task addTodayCheckIn() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    if (!isTodayChecked) {
      final newCheckInDates = List<DateTime>.from(checkInDates)..add(todayDate);
      return copyWith(checkInDates: newCheckInDates);
    }
    return this;
  }

  // 移除今日打卡
  Task removeTodayCheckIn() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    final newCheckInDates = checkInDates.where((date) {
      final checkDate = DateTime(date.year, date.month, date.day);
      return !checkDate.isAtSameMomentAs(todayDate);
    }).toList();
    
    return copyWith(checkInDates: newCheckInDates);
  }

  // 复制并修改
  Task copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? note,
    bool? enableNotification,
    List<DateTime>? checkInDates,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      note: note ?? this.note,
      enableNotification: enableNotification ?? this.enableNotification,
      checkInDates: checkInDates ?? this.checkInDates,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'note': note,
      'enableNotification': enableNotification,
      'checkInDates': checkInDates.map((date) => date.toIso8601String()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // 从JSON创建
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      note: json['note'],
      enableNotification: json['enableNotification'],
      checkInDates: (json['checkInDates'] as List<dynamic>)
          .map((date) => DateTime.parse(date))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, name: $name, status: $status, progress: $checkedDays/$totalDays)';
  }
}

enum TaskStatus {
  notStarted,
  inProgress,
  completed,
}

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.notStarted:
        return '未开始';
      case TaskStatus.inProgress:
        return '进行中';
      case TaskStatus.completed:
        return '已完成';
    }
  }
} 