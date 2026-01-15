import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../widgets/custom_video_controls.dart';

/// Fullscreen video player widget
class FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String title;

  const FullscreenVideoPlayer({
    super.key,
    required this.controller,
    required this.title,
  });

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  @override
  void initState() {
    super.initState();
    _enterFullscreen();
  }

  @override
  void dispose() {
    _exitFullscreen();
    super.dispose();
  }

  void _enterFullscreen() {
    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullscreen() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    // Restore portrait orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _toggleFullscreen() {
    // Exit fullscreen by popping the route
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _exitFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(widget.controller),
                CustomVideoControls(
                  controller: widget.controller,
                  onFullscreenToggle: _toggleFullscreen,
                  isFullscreen: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
