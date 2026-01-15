import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../widgets/liquid_glass_container.dart';

/// Simple and elegant audio visualizer with clean pulsing circles
/// Designed to be lightweight and visually appealing
class SimpleAudioVisualizer extends StatefulWidget {
  final bool isPlaying;

  const SimpleAudioVisualizer({super.key, required this.isPlaying});

  @override
  State<SimpleAudioVisualizer> createState() => _SimpleAudioVisualizerState();
}

class _SimpleAudioVisualizerState extends State<SimpleAudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SimpleAudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: LiquidGlassContainer(
          height: 200,
          borderRadius: GlassEffects.radiusLarge,
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing circle
                    _buildPulsingCircle(size: 140, opacity: 0.15, delay: 0.0),
                    // Middle pulsing circle
                    _buildPulsingCircle(size: 100, opacity: 0.25, delay: 0.33),
                    // Inner pulsing circle
                    _buildPulsingCircle(size: 60, opacity: 0.4, delay: 0.66),
                    // Center solid circle with gradient
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPulsingCircle({
    required double size,
    required double opacity,
    required double delay,
  }) {
    // Calculate pulsing scale
    final progress = (_controller.value + delay) % 1.0;
    final scale = 0.7 + (math.sin(progress * 2 * math.pi) * 0.15);
    final pulseOpacity = opacity * (1.0 - (progress * 0.5));

    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: pulseOpacity),
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Compact audio visualizer for smaller spaces (kept for compatibility)
class CompactAudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final int barCount;
  final double height;
  final Color color;

  const CompactAudioVisualizer({
    super.key,
    required this.isPlaying,
    this.barCount = 5,
    this.height = 20,
    this.color = AppColors.primaryLight,
  });

  @override
  State<CompactAudioVisualizer> createState() => _CompactAudioVisualizerState();
}

class _CompactAudioVisualizerState extends State<CompactAudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _phases;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    // Generate random phases for variety
    _phases = List.generate(
      widget.barCount,
      (_) => _random.nextDouble() * 2 * math.pi,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(CompactAudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.animateTo(0.3, duration: const Duration(milliseconds: 200));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox(
          height: widget.height,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(widget.barCount, (index) {
                  // Calculate height using sine wave with unique phase
                  final phase = _phases[index];
                  final value = math.sin(
                    _controller.value * 2 * math.pi + phase,
                  );
                  final heightFactor =
                      0.3 + ((value + 1) / 2) * 0.7; // Range: 0.3 to 1.0

                  return Container(
                    width: 3,
                    height: widget.height * heightFactor,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.5),
                      color: widget.color,
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
