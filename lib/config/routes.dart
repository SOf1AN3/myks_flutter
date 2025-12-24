import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/radio/radio_screen.dart';
import '../screens/videos/videos_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/admin/admin_screen.dart';

/// App routes configuration
class AppRoutes {
  static const String home = '/';
  static const String radio = '/radio';
  static const String videos = '/videos';
  static const String about = '/about';
  static const String admin = '/admin';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildPageRoute(const HomeScreen(), settings);
      case radio:
        return _buildPageRoute(const RadioScreen(), settings);
      case videos:
        return _buildPageRoute(const VideosScreen(), settings);
      case about:
        return _buildPageRoute(const AboutScreen(), settings);
      case admin:
        return _buildPageRoute(const AdminScreen(), settings);
      default:
        return _buildPageRoute(const HomeScreen(), settings);
    }
  }

  static PageRouteBuilder<dynamic> _buildPageRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.02);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
