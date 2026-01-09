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

  const MeshGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.darkBackgroundDeep),
      child: Stack(
        children: [
          // Radial gradient 1 - Top Left
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.0,
                  colors: [
                    AppColors.meshGradient1, // rgba(168, 85, 247, 0.2)
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),
          // Radial gradient 2 - Top Right
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.0,
                  colors: [
                    AppColors.meshGradient2, // rgba(139, 92, 246, 0.25)
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),
          // Radial gradient 3 - Bottom Center
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomCenter,
                  radius: 0.8,
                  colors: [
                    AppColors.meshGradient3, // rgba(76, 29, 149, 0.4)
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),
          // Content
          child,
        ],
      ),
    );
  }
}
