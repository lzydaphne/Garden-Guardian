import 'package:flutter/material.dart';
import 'package:flutter_app/models/goal.dart';
import 'package:flutter_app/models/goal_detail.dart';

const dummyGoals = {
  'g1': Goal(
    id: 'g1',
    title: 'daily sign-in',
    content: 'content1',
    icon: Icons.check_box,
    total: 1
  ),
  'g2': Goal(
    id: 'g2',
    title: 'plant amount',
    content: 'content2',
    icon: Icons.nature,
    total: 2
  ),
  'g3': Goal(
    id: 'g3',
    title: 'plant category',
    content: 'content3',
    icon: Icons.face_3,
    total: 3
  ),
  'g4': Goal(
    id: 'g4',
    title: 'watering',
    content: 'content4',
    icon: Icons.water_drop,
    total: 4
  ),
  'g5': Goal(
    id: 'g5',
    title: 'drink water',
    content: 'content5',
    icon: Icons.local_drink,
    total: 5
  ),
  'g6': Goal(
    id: 'g6',
    title: 'all achievements',
    content: 'achieve all the goals',
    icon: Icons.stars_rounded,
    total: 1
  )
};

const dummyGoalDetails = {
  'gd1': GoalDetail(
    id: 'gd1',
    goal: 'g1',
    title: 'You have to sign-in 1 day!',
    total: 1,
  ),
  'gd2': GoalDetail(
    id: 'gd2',
    goal: 'g1',
    title: 'You have to sign-in 3 days!',
    total: 3,
  )
};