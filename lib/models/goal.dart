import 'package:flutter/material.dart';

class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
    required this.total,
    this.progress = 0,
    this.completed = 0,
    this.done = false,
  });

  final String id;
  final String title;
  final String content;
  final IconData icon;
  final int total;
  final int progress;
  final int completed;
  final bool done;

  Goal copyWith({
    String? id,
    String? title,
    String? content,
    IconData? icon,
    int? total,
    int? progress,
    int? completed,
    bool? done,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      total: total ?? this.total,
      progress: progress ?? this.progress,
      completed: completed ?? this.completed,
      done: done ?? this.done,
    );
  }
}
