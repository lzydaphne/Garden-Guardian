import 'package:flutter/material.dart';
import 'package:flutter_app/data/dummy_data.dart';
import 'package:flutter_app/models/goal_detail.dart';

class GoalDetailItem extends StatelessWidget {
  const GoalDetailItem({
    super.key,
    required this.goaldetail,
  });

  final GoalDetail goaldetail;

  @override
  Widget build(BuildContext context) {
    return
      InkWell(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(dummyGoals[goaldetail.goal]?.icon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goaldetail.title,
                    style: const TextStyle(
                      fontSize: 20
                    )
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    child: LinearProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      value: dummyGoals[goaldetail.goal]!.completed/goaldetail.total,
                    ),
                  ),
                ]
              ),
            ),
            const SizedBox(width: 10),
            Text('${dummyGoals[goaldetail.goal]?.completed}/${goaldetail.total}')
          ]
        )
      )
    );
  }
}