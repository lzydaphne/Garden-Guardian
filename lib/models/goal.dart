import 'package:flutter/material.dart';
import 'package:flutter_app/models/goal_detail.dart';

class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.content,
    required this.icon,
    required this.total,
    required this.goaldetails,
    this.progress = 0,
    this.completed = 6,
    this.done = false
  });

  final String id;
  final String title;
  final String content;
  final IconData icon;
  final int total;
  final Map<String, GoalDetail> goaldetails;
  final int progress;
  final int completed;
  final bool done;
}