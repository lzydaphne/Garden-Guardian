import 'package:flutter/material.dart';
import 'package:flutter_app/models/goal.dart';
import 'package:flutter_app/data/dummy_data.dart';
import 'package:flutter_app/views/goal_item.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/services/navigation.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({
    super.key
  });

  void _selectGoal(BuildContext context, Goal goal) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    nav.goGoalDetailsOnGoal(goalId: goal.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          for(final goal in dummyGoals.values)
            GoalItem(
              goal: goal,
              onSelectGoal: () {
                _selectGoal(context, goal);
              },
            )
        ],
      )
    );
  }
}