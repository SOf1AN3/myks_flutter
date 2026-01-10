import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/radio_provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';

/// Mini player that appears at the bottom of screens
class MiniPlayer extends StatelessWidget {
  final bool visible;

  const MiniPlayer({super.key, this.visible = true});

  @override
  Widget build(BuildContext context) {
    final radioProvider = context.watch<RadioProvider>();

    // Don't show if not playing or paused
    final shouldShow =
        visible &&
        (radioProvider.isPlaying ||
            radioProvider.isPaused ||
            radioProvider.isLoading);

    return AnimatedSlide(
      offset: shouldShow ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: shouldShow ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: _MiniPlayerContent(radioProvider: radioProvider),
      ),
    );
  }
}

class _MiniPlayerContent extends StatelessWidget {
  final RadioProvider radioProvider;

  const _MiniPlayerContent({required this.radioProvider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (currentRoute != AppRoutes.radio) {
            Navigator.pushNamed(context, AppRoutes.radio);
          }
        },
        child: Container(
          margin: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8, // Reduced from 10 for better performance
                sigmaY: 8,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withOpacity(
                    0.8,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(
                      0.1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated progress bar
                    if (radioProvider.isPlaying) _buildProgressBar(),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        // Album art
                        _buildAlbumArt(),

                        const SizedBox(width: 12),

                        // Track info
                        Expanded(child: _buildTrackInfo(context)),

                        // Controls
                        _buildControls(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return SizedBox(
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(seconds: 2),
          color: AppColors.primaryDark.withOpacity(0.5),
        );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: AppColors.violetGradient,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: radioProvider.currentCover != null
            ? Image.network(
                radioProvider.currentCover!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.violetGradient),
      child: const Icon(Icons.music_note, color: Colors.white, size: 24),
    );
  }

  Widget _buildTrackInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (radioProvider.isPlaying)
              Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.live,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(duration: const Duration(seconds: 1)),

            Expanded(
              child: Text(
                radioProvider.currentTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkForeground
                      : AppColors.lightForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          radioProvider.currentArtist,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Volume button (optional popup)
        IconButton(
          icon: Icon(
            radioProvider.volume == 0 ? Icons.volume_off : Icons.volume_up,
            size: 20,
          ),
          onPressed: () {
            // Toggle mute
            if (radioProvider.volume > 0) {
              radioProvider.setVolume(0);
            } else {
              radioProvider.setVolume(0.8);
            }
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),

        // Play/Pause button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.violetGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: radioProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    radioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
            onPressed: radioProvider.isLoading
                ? null
                : () => radioProvider.togglePlayPause(),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
