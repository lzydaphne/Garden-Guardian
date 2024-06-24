import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/goal.dart';
import 'package:flutter_app/data/dummy_data.dart';
import 'package:flutter_app/views/goal/goal_item.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/services/authentication.dart';

//import 'package:flutter_app/views/goal/goal_item.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  Map<String, Goal> goals = dummyGoals;

  @override
  void initState() {
    super.initState();
    _fetchUserGoals();
  }

//* dynamically fetch user data
  // Future<void> _fetchUserGoals() async {
  //   final authService =
  //       Provider.of<AuthenticationService>(context, listen: false);
  //   final currentUser = authService.currentUser;

  //   if (currentUser != null) {
  //     final userId = currentUser.id;
  //     final userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .get();

  //     if (userDoc.exists) {
  //       final data = userDoc.data()!;
  //       setState(() {
  //         goals['g1']?.progress = data['cnt_signin'] ?? 0;
  //         goals['g2']?.progress = data['cnt_plantNum'] ?? 0;
  //         goals['g3']?.progress = data['cnt_plantType'] ?? 0;
  //         goals['g4']?.progress = data['cnt_watering'] ?? 0;
  //         goals['g5']?.progress = data['cnt_drink'] ?? 0;
  //       });
  //     }
  //   } else {
  //     // Handle the case when there is no current user
  //     debugPrint('No current user found');
  //   }
  // }

  Future<void> _fetchUserGoals() async {
    final userId =
        'cV8dyoEmSUZo7QXUiceE1g4YvLm1'; //! [TODO] Replace with the actual user ID
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        goals['g1']?.progress = data['cnt_signin'] ?? 0;
        goals['g2']?.progress = data['cnt_plantNum'] ?? 0;
        goals['g3']?.progress = data['cnt_plantType'] ?? 0;
        goals['g4']?.progress = data['cnt_watering'] ?? 0;
        goals['g5']?.progress = data['cnt_drink'] ?? 0;
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
            "Achivement",
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
