import 'dart:ui';

import 'package:flutter/material.dart';

enum TaskPriority {
  low,
  medium,
  high,
  urgent
}

enum TaskStatus {
  todo,
  inProgress,
  completed,
  cancelled
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final List<String> tags;
  final String? projectId;
  final bool isRecurring;
  final String? recurringPattern;
  final List<SubTask> subTasks;
  
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.tags,
    this.projectId,
    this.isRecurring = false,
    this.recurringPattern,
    this.subTasks = const [],
  });
  
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    List<String>? tags,
    String? projectId,
    bool? isRecurring,
    String? recurringPattern,
    List<SubTask>? subTasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      projectId: projectId ?? this.projectId,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      subTasks: subTasks ?? this.subTasks,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.toString(),
      'status': status.toString(),
      'tags': tags,
      'projectId': projectId,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'subTasks': subTasks.map((st) => st.toJson()).toList(),
    };
  }
  
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      tags: List<String>.from(json['tags']),
      projectId: json['projectId'],
      isRecurring: json['isRecurring'] ?? false,
      recurringPattern: json['recurringPattern'],
      subTasks: json['subTasks'] != null
          ? List<SubTask>.from(
              json['subTasks'].map((st) => SubTask.fromJson(st)),
            )
          : [],
    );
  }
  
  bool get isCompleted => status == TaskStatus.completed;
  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status != TaskStatus.completed;
  
  double get progress {
    if (subTasks.isEmpty) {
      return status == TaskStatus.completed ? 1.0 : 0.0;
    }
    
    final completedSubTasks = subTasks.where((st) => st.isCompleted).length;
    return completedSubTasks / subTasks.length;
  }
  
  Color getPriorityColor() {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  
  String getPriorityText() {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
      default:
        return 'Medium';
    }
  }
}

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;
  
  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
  
  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }
  
  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final Color color;
  final DateTime createdAt;
  final DateTime? dueDate;
  
  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.createdAt,
    this.dueDate,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }
  
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: Color(json['color']),
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }
}

