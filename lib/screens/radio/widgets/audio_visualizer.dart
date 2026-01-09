import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../widgets/liquid_glass_container.dart';

/// Audio visualizer with animated bars in a curved glass viewer
/// Matches the design.html with 10 bars and specific heights
class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final double height;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    this.height = 200,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  // 10 bars with predefined heights matching design.html
  // Heights: h-12, h-24, h-16, h-32, h-20, h-36, h-24, h-16, h-28, h-14
  // In pixels (1rem = 4px): 48, 96, 64, 128, 80, 144, 96, 64, 112, 56
  static const List<double> _barHeights = [
    48,
    96,
    64,
    128,
    80,
    144,
    96,
    64,
    112,
    56,
  ];
  static const int _barCount = 10;
  static const double _barWidth = 5;
  static const double _barSpacing = 6;

  // OPTIMIZED: Single animation controller instead of 10
  late AnimationController _controller;
  late List<double> _phases; // Random phases for each bar
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    // Generate random phases for variety
    _phases = List.generate(
      _barCount,
      (_) => _random.nextDouble() * 2 * math.pi,
    );

    // Single controller for all bars
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.animateTo(0.7, duration: const Duration(milliseconds: 300));
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
    return RepaintBoundary(
      child: CurvedGlassViewer(
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_barCount, (index) {
                // Calculate height using sine wave with unique phase
                final phase = _phases[index];
                final value = math.sin(_controller.value * 2 * math.pi + phase);
                final baseHeight = _barHeights[index];
                final animatedHeight =
                    baseHeight *
                    (0.7 + (value * 0.15)); // Oscillate between 70% and 85%

                return Container(
                  width: _barWidth,
                  height: animatedHeight,
                  margin: const EdgeInsets.symmetric(
                    horizontal: _barSpacing / 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_barWidth / 2),
                    gradient: AppColors.waveBarGradient,
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

/// Compact audio visualizer for smaller spaces
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
  // OPTIMIZED: Single animation controller
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
    return RepaintBoundary(
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
                final value = math.sin(_controller.value * 2 * math.pi + phase);
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
    );
  }
}
