import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// A container with liquid glass effect (glassmorphism)
///
/// Features:
/// - Backdrop filter blur for glass effect (can be disabled for performance)
/// - Semi-transparent background
/// - Subtle border and inner glow
/// - Configurable border radius and padding
///
/// Performance Optimization:
/// - [enableBlur] is false by default for better performance
/// - BackdropFilter is EXPENSIVE! Only enable blur when truly necessary
/// - Static glass effect (blur disabled) looks nearly identical but performs much better
/// - Already wrapped with RepaintBoundary for optimal rendering
class LiquidGlassContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blurIntensity;
  final bool showInnerGlow;
  final AlignmentGeometry? alignment;
  final List<BoxShadow>? boxShadow;
  final bool enableBlur;

  const LiquidGlassContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = GlassEffects.radiusMedium,
    this.backgroundColor,
    this.borderColor,
    this.blurIntensity = GlassEffects.blurIntensity,
    this.showInnerGlow = false,
    this.alignment,
    this.boxShadow,
    this.enableBlur = false, // PERFORMANCE: Changed default to false
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        alignment: alignment,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow ?? GlassEffects.glassShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: enableBlur
              ? BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurIntensity,
                    sigmaY: blurIntensity,
                  ),
                  child: _buildGlassContent(),
                )
              : _buildGlassContent(),
        ),
      ),
    );
  }

  Widget _buildGlassContent() {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.glassBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: showInnerGlow ? GlassEffects.innerGlowShadow : null,
      ),
      child: child,
    );
  }
}

/// A compact liquid glass control button container
class LiquidControlContainer extends StatelessWidget {
  final Widget child;
  final double size;
  final VoidCallback? onTap;

  const LiquidControlContainer({
    super.key,
    required this.child,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: GlassEffects.blurIntensityControl,
                sigmaY: GlassEffects.blurIntensityControl,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x26FFFFFF), // rgba(255, 255, 255, 0.15)
                      Color(0x0DFFFFFF), // rgba(255, 255, 255, 0.05)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppColors.glassControlBorder,
                    width: 1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Curved glass viewer container for audio visualizer
class CurvedGlassViewer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double height;

  const CurvedGlassViewer({
    super.key,
    required this.child,
    this.width,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GlassEffects.radiusLarge),
          border: Border.all(
            color: const Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1)
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(GlassEffects.radiusLarge),
          child: Stack(
            children: [
              // Background
              Container(
                decoration: const BoxDecoration(
                  color: Color(0x08FFFFFF), // rgba(255, 255, 255, 0.03)
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                child: Center(child: child),
              ),
              // Overlay gradient for curved glass effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      GlassEffects.radiusLarge,
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1)
                        Colors.transparent,
                        Colors.transparent,
                        Color(0x0DFFFFFF), // rgba(255, 255, 255, 0.05)
                      ],
                      stops: [0.0, 0.2, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
