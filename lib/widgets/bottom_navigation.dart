import 'package:flutter/material.dart';
import '../config/routes.dart';

/// Bottom navigation bar for the app
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: Icon(Icons.radio_outlined),
          selectedIcon: Icon(Icons.radio),
          label: 'Radio',
        ),
        NavigationDestination(
          icon: Icon(Icons.video_library_outlined),
          selectedIcon: Icon(Icons.video_library),
          label: 'Vidéos',
        ),
        NavigationDestination(
          icon: Icon(Icons.info_outline),
          selectedIcon: Icon(Icons.info),
          label: 'À propos',
        ),
      ],
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    String route;
    switch (index) {
      case 0:
        route = AppRoutes.home;
        break;
      case 1:
        route = AppRoutes.radio;
        break;
      case 2:
        route = AppRoutes.videos;
        break;
      case 3:
        route = AppRoutes.about;
        break;
      default:
        route = AppRoutes.home;
    }

    Navigator.pushReplacementNamed(context, route);
  }

  /// Get navigation index from route name
  static int getIndexFromRoute(String? routeName) {
    switch (routeName) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.radio:
        return 1;
      case AppRoutes.videos:
        return 2;
      case AppRoutes.about:
        return 3;
      default:
        return 0;
    }
  }
}
