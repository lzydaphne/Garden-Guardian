
import 'package:flutter_app/views/chat_page.dart';
import 'package:flutter_app/views/home_page.dart';
import 'package:flutter_app/views/wiki_list_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/views/cover_page.dart';
import 'package:flutter_app/views/auth_page.dart';
import 'package:flutter_app/views/nav_bar.dart';
import 'package:flutter_app/views/goal/goals_page.dart';

final routerConfig = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/cover',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: CoverPage(),
      ),
      routes: <RouteBase>[
        GoRoute(
          path: 'auth',
          builder: (context, state) => const AuthPage(),
        )
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const NavBar(selectedTab: HomeTab.home),
    ),
    GoRoute(
      path: '/plant',
      builder: (context, state) => const NavBar(selectedTab: HomeTab.plant),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const NavBar(selectedTab: HomeTab.chat),
      // routes: <RouteBase>[
      //   GoRoute(
      //     path: 'inform',
      //     builder: (context, state) => const ChatInformPage(),
      //   ),
      // ],
    ),
    GoRoute(
      path: '/goal',
      builder: (context, state) => const NavBar(selectedTab: HomeTab.goal),
    ),
    GoRoute(
      path: '/wiki',
      builder: (context, state) => WikiListPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const NavBar(selectedTab: HomeTab.profile),
    ),
  ],
  initialLocation: '/cover',
);

class NavigationService {
  late final GoRouter _router;

  NavigationService() {
    _router = routerConfig;
  }

  void goAuth() {
    _router.go('/cover/auth');
  }

  void goHome({required HomeTab tab}) {
    _router.go('/${tab.name}');
  }

  // void goInform() {
  //   _router.go('/chat/inform'); // Add navigation to InformPage
  // }
}
