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
    this.done = false
  });

  final String id;
  final String title;
  final String content;
  final IconData icon;
  final int total;
  final int progress;
  final int completed;
  final bool done;
}