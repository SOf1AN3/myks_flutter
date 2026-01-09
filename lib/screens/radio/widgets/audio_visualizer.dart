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
    with TickerProviderStateMixin {
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

  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(_barCount, (index) {
      final duration = Duration(milliseconds: 400 + _random.nextInt(400));
      return AnimationController(vsync: this, duration: duration);
    });

    _animations = List.generate(_barCount, (index) {
      final baseHeight = _barHeights[index];
      final minHeight = baseHeight * 0.7;
      final maxHeight = baseHeight * 1.0;

      return Tween<double>(begin: minHeight, end: maxHeight).animate(
        CurvedAnimation(parent: _controllers[index], curve: Curves.easeInOut),
      );
    });

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted && widget.isPlaying) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].stop();
      _controllers[i].animateTo(
        0.7,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CurvedGlassViewer(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_barCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                width: _barWidth,
                height: _animations[index].value,
                margin: const EdgeInsets.symmetric(horizontal: _barSpacing / 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_barWidth / 2),
                  gradient: AppColors.waveBarGradient,
                ),
              );
            },
          );
        }),
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
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(widget.barCount, (index) {
      final duration = Duration(milliseconds: 200 + _random.nextInt(300));
      return AnimationController(vsync: this, duration: duration);
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 30), () {
        if (mounted && widget.isPlaying) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (var controller in _controllers) {
      controller.stop();
      controller.animateTo(0.3, duration: const Duration(milliseconds: 200));
    }
  }

  @override
  void didUpdateWidget(CompactAudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                width: 3,
                height: widget.height * _animations[index].value,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.5),
                  color: widget.color,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
