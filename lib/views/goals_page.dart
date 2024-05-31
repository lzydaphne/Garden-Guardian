import 'package:flutter/material.dart';
import 'package:flutter_app/models/goal.dart';
import 'package:flutter_app/data/dummy_data.dart';
import 'package:flutter_app/views/goal_grid_item.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({
    super.key
  });

  void _selectGoal(BuildContext context, Goal goal) {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievement'),
      ),
      body: ListView(
        children: [
          for(final goal in dummyGoals.values)
            GoalGridItem(
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