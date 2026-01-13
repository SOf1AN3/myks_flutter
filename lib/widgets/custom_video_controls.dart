import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../config/theme.dart';
import 'liquid_glass_container.dart';

/// Widget de contrôles vidéo custom avec style Liquid Glass
class CustomVideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback? onFullscreenToggle;
  final bool showFullscreenButton;

  const CustomVideoControls({
    super.key,
    required this.controller,
    this.onFullscreenToggle,
    this.showFullscreenButton = true,
  });

  @override
  State<CustomVideoControls> createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<CustomVideoControls> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_videoListener);
    _startHideTimer();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    _hideTimer?.cancel();
    super.dispose();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
      _startHideTimer();
    }
  }

  void _toggleMute() {
    widget.controller.setVolume(widget.controller.value.volume > 0 ? 0.0 : 1.0);
    setState(() {});
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Centre: Play/Pause button
          if (_showControls)
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 200),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      widget.controller.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 40,
                    ),
                    color: Colors.white,
                    onPressed: _togglePlayPause,
                  ),
                ),
              ),
            ),

          // Bottom: Progress bar et contrôles
          if (_showControls)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 200),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: LiquidGlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  borderRadius: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress bar
                      VideoProgressIndicator(
                        widget.controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: AppColors.primary,
                          bufferedColor: Colors.white.withOpacity(0.3),
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      const SizedBox(height: 8),
                      // Timestamps et contrôles
                      Row(
                        children: [
                          // Timestamp actuel
                          Text(
                            _formatDuration(widget.controller.value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            ' / ',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          // Timestamp total
                          Text(
                            _formatDuration(widget.controller.value.duration),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          // Mute button
                          IconButton(
                            icon: Icon(
                              widget.controller.value.volume > 0
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: _toggleMute,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            tooltip: widget.controller.value.volume > 0
                                ? 'Couper le son'
                                : 'Activer le son',
                          ),
                          const SizedBox(width: 8),
                          // Fullscreen button
                          if (widget.showFullscreenButton)
                            IconButton(
                              icon: const Icon(
                                Icons.fullscreen_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              onPressed: widget.onFullscreenToggle,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              tooltip: 'Plein écran',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (widget.controller.value.isBuffering)
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
