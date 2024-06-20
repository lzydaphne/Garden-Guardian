import 'package:flutter/material.dart';
import 'package:flutter_app/data/dummy_data.dart';
import 'package:flutter_app/views/goal_detail_item.dart';

class GoalDetailsPage extends StatelessWidget {
  const GoalDetailsPage({
    super.key,
    required this.goalId
  });

  final String goalId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dummyGoals[goalId]!.title)
      ),
      body: ListView(
        children: [
          for(final goaldetail in dummyGoals[goalId]!.goaldetails.values)
            GoalDetailItem(
              goaldetail: goaldetail
            )
        ],
      )
    );
  }
}