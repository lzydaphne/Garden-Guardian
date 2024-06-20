import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:flutter_app/views/plant_family/plant_family_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/views/home_page.dart';
import 'package:flutter_app/views/plant_family/plant_family_page.dart';
import 'package:flutter_app/views/chat_page.dart';
import 'package:flutter_app/views/goal/goals_page.dart';
import 'package:flutter_app/views/plant_family/diary_page.dart';

enum HomeTab { home, plant, chat, goal, diary }

class NavBar extends StatelessWidget {
  final HomeTab selectedTab;

  const NavBar({super.key, required this.selectedTab});

  void _tapBottomNavigationBarItem(BuildContext context, index) {
    final nav = Provider.of<NavigationService>(context, listen: false);
    nav.goHome(
        tab: index == 0
            ? HomeTab.home
            : index == 1
                ? HomeTab.plant
                : index == 2
                    ? HomeTab.chat
                    : index == 3
                        ? HomeTab.goal
                        : HomeTab.diary);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tabs = [
      {
        'page': HomePage(),
        'title': 'Home',
      },
      {
        'page': const PlantFamilyPage(),
        'title': 'Plant Family',
      },
      {
        'page': const ChatPage(),
        'title': 'Chat',
      },
      {
        'page': const GoalsPage(),
        'title': 'Achievement',
      },
      {
        'page': const DiaryPage(),
        'title': 'Diary',
      },
    ];

    return Scaffold(
      /*appBar: AppBar(
        title: Text(tabs[selectedTab.index]['title']),
      ),*/
      body: tabs[selectedTab.index]['page'],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        fixedColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: (index) => _tapBottomNavigationBarItem(context, index),
        currentIndex: selectedTab.index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nature),
            label: 'Plant Family',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Achievement',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diary',
          ),
        ],
      ),
    );
  }
}
