import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Mesh gradient background matching the design.html aesthetic
///
/// Creates a deep violet background with three radial gradients:
/// - Top left: rgba(168, 85, 247, 0.2)
/// - Top right: rgba(139, 92, 246, 0.25)
/// - Bottom center: rgba(76, 29, 149, 0.4)
class MeshGradientBackground extends StatelessWidget {
  final Widget child;

  // Static const gradient decorations to avoid recreation on every build
  static const _gradient1 = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.topLeft,
      radius: 1.0,
      colors: [
        AppColors.meshGradient1, // rgba(168, 85, 247, 0.2)
        Colors.transparent,
      ],
      stops: [0.0, 0.5],
    ),
  );

  static const _gradient2 = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.topRight,
      radius: 1.0,
      colors: [
        AppColors.meshGradient2, // rgba(139, 92, 246, 0.25)
        Colors.transparent,
      ],
      stops: [0.0, 0.5],
    ),
  );

  static const _gradient3 = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.bottomCenter,
      radius: 0.8,
      colors: [
        AppColors.meshGradient3, // rgba(76, 29, 149, 0.4)
        Colors.transparent,
      ],
      stops: [0.0, 0.5],
    ),
  );

  const MeshGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE: Use MediaQuery.sizeOf instead of LayoutBuilder
    // to avoid unnecessary rebuilds on constraint changes
    final size = MediaQuery.sizeOf(context);

    return ExcludeSemantics(
      child: Container(
        decoration: const BoxDecoration(color: AppColors.darkBackgroundDeep),
        child: Stack(
          children: [
            // PERFORMANCE: Wrapped in RepaintBoundary to isolate repaints
            RepaintBoundary(
              child: Stack(
                children: [
                  // Radial gradient 1 - Top Left
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: size.width * 0.6,
                      height: size.height * 0.4,
                      decoration: _gradient1,
                    ),
                  ),
                  // Radial gradient 2 - Top Right
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: size.width * 0.6,
                      height: size.height * 0.4,
                      decoration: _gradient2,
                    ),
                  ),
                  // Radial gradient 3 - Bottom Center
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: size.width,
                      height: size.height * 0.5,
                      decoration: _gradient3,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            child,
          ],
        ),
      ),
    );
  }
}
