import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:flutter_app/views/plant_family/plant_family_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/views/home_page.dart';
import 'package:flutter_app/views/plant_family/plant_family_page.dart';
import 'package:flutter_app/views/chat_page.dart';
import 'package:flutter_app/views/goal/goals_page.dart';
//import 'package:flutter_app/views/plant_family/diary_page.dart';
import 'package:flutter_app/views/profile/profile_page.dart';

enum HomeTab { home, plant, chat, goal, profile }

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
                        : HomeTab.profile);
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
        'page': ProfilePage(),
        'title': 'Profile',
      },
    ];

    return Scaffold(
      /*appBar: AppBar(
        title: Text(tabs[selectedTab.index]['title']),
      ),*/
      body: tabs[selectedTab.index]['page'],
      bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          //backgroundColor: const Color.fromARGB(255, 93, 176, 117),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_florist),
              label: 'My Plants',   //'我的植物',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              label: 'ChatBot',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hotel_class_rounded),
              label: 'Achievements'//'種植挑戰',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile',//'帳號維護',
            ),
          ],
          currentIndex: selectedTab.index,
          selectedItemColor: const Color.fromARGB(255, 93, 176, 117),
          //unselectedItemColor: const Color.fromARGB(255, 93, 176, 117).withOpacity(0.7),
          onTap: (index) => _tapBottomNavigationBarItem(context, index),
        ),
      ),
    )
    );
  }
}
