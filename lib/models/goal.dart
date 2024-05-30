import 'package:flutter/material.dart';

class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
    required this.total,
    this.completed = 0
  });

  final String id;
  final String title;
  final String content;
  final IconData icon;
  final int total;
  final int completed;
}