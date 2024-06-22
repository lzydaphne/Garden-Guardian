import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/goal.dart';
import 'package:flutter_app/data/dummy_data.dart';
import 'package:flutter_app/views/goal/goal_item.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/views/goal/goal_item.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  Map<String, Goal> goals = dummyGoals;
  // Map<String, Goal> goals = {
  //   'g1': Goal(
  //     id: 'g1',
  //     title: 'daily sign-in',
  //     content: 'content1',
  //     icon: Icons.check_box,
  //     total: 1,
  //     goaldetails: 
  //   ),
  //   'g2': Goal(
  //     id: 'g2',
  //     title: 'plant amount',
  //     content: 'content2',
  //     icon: Icons.nature,
  //     total: 2,
  //   ),
  //   'g3': Goal(
  //     id: 'g3',
  //     title: 'plant category',
  //     content: 'content3',
  //     icon: Icons.face_3,
  //     total: 3,
  //   ),
  //   'g4': Goal(
  //     id: 'g4',
  //     title: 'watering',
  //     content: 'content4',
  //     icon: Icons.water_drop,
  //     total: 4,
  //   ),
  //   'g5': Goal(
  //     id: 'g5',
  //     title: 'drink water',
  //     content: 'content5',
  //     icon: Icons.local_drink,
  //     total: 5,
  //   ),
  //   'g6': Goal(
  //     id: 'g6',
  //     title: 'all achievements',
  //     content: 'achieve all the goals',
  //     icon: Icons.stars_rounded,
  //     total: 1,
  //   ),
  // };

  @override
  void initState() {
    super.initState();
    _fetchUserGoals();
  }

  Future<void> _fetchUserGoals() async {
    final userId =
        'cV8dyoEmSUZo7QXUiceE1g4YvLm1'; // Replace with the actual user ID
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        goals['g1'] = goals['g1']!.copyWith(progress: data['cnt_signin']);
        goals['g2'] = goals['g2']!.copyWith(progress: data['cnt_plantNum']);
        goals['g3'] = goals['g3']!.copyWith(progress: data['cnt_plantType']);
        goals['g4'] = goals['g4']!.copyWith(progress: data['cnt_watering']);
        goals['g5'] = goals['g5']!.copyWith(progress: data['cnt_drink']);
      });
    }
  }

  void _selectGoal(BuildContext context, Goal goal) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    nav.goGoalDetailsOnCategory(goalId: goal.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "種植挑戰",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            for (final goal in goals.values)
              GoalItem(
                goal: goal,
                onSelectGoal: () {
                  _selectGoal(context, goal);
                },
              )
          ],
        ));
  }
}