import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/routes.dart';
import '../config/theme.dart';

/// Bottom navigation bar with liquid glass effect
/// Redesigned to match design.html aesthetic
///
/// Performance Optimization:
/// - [enableBlur] is false by default for better performance
/// - BackdropFilter is expensive! Only enable when truly necessary
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final bool enableBlur;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    this.enableBlur = false, // PERFORMANCE: Default to false
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: enableBlur
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: _buildContent(context),
              )
            : _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home,
                label: 'Accueil',
                isActive: currentIndex == 0,
                onTap: () => _onItemTapped(context, 0),
              ),
              _NavItem(
                icon: Icons.radio,
                label: 'Radio',
                isActive: currentIndex == 1,
                onTap: () => _onItemTapped(context, 1),
              ),
              _NavItem(
                icon: Icons.video_library,
                label: 'Vidéos',
                isActive: currentIndex == 2,
                onTap: () => _onItemTapped(context, 2),
              ),
              _NavItem(
                icon: Icons.info_outline,
                label: 'À propos',
                isActive: currentIndex == 3,
                onTap: () => _onItemTapped(context, 3),
              ),
            ],
          ),
        ),
      ),
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

/// Navigation item with icon and active indicator
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      selected: isActive,
      hint: isActive ? 'Sélectionné' : 'Appuyez pour naviguer vers $label',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isActive
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 2),
            // Active indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
