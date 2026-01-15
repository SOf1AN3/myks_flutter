import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/radio_provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';

/// Mini player that appears at the bottom of screens
class MiniPlayer extends StatelessWidget {
  final bool visible;

  const MiniPlayer({super.key, this.visible = true});

  @override
  Widget build(BuildContext context) {
    // OPTIMIZED: Use Selector to rebuild only when specific properties change
    return Selector<RadioProvider, _MiniPlayerState>(
      selector: (context, provider) => _MiniPlayerState(
        isPlaying: provider.isPlaying,
        isPaused: provider.isPaused,
        isLoading: provider.isLoading,
        currentTitle: provider.currentTitle,
        currentArtist: provider.currentArtist,
        currentCover: provider.currentCover,
        volume: provider.volume,
      ),
      builder: (context, state, child) {
        // Don't show if not playing or paused
        final shouldShow =
            visible && (state.isPlaying || state.isPaused || state.isLoading);

        return AnimatedSlide(
          offset: shouldShow ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: shouldShow ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _MiniPlayerContent(state: state),
          ),
        );
      },
    );
  }
}

/// State class for MiniPlayer to optimize rebuilds
class _MiniPlayerState {
  final bool isPlaying;
  final bool isPaused;
  final bool isLoading;
  final String currentTitle;
  final String currentArtist;
  final String? currentCover;
  final double volume;

  const _MiniPlayerState({
    required this.isPlaying,
    required this.isPaused,
    required this.isLoading,
    required this.currentTitle,
    required this.currentArtist,
    required this.currentCover,
    required this.volume,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MiniPlayerState &&
          runtimeType == other.runtimeType &&
          isPlaying == other.isPlaying &&
          isPaused == other.isPaused &&
          isLoading == other.isLoading &&
          currentTitle == other.currentTitle &&
          currentArtist == other.currentArtist &&
          currentCover == other.currentCover &&
          volume == other.volume;

  @override
  int get hashCode =>
      isPlaying.hashCode ^
      isPaused.hashCode ^
      isLoading.hashCode ^
      currentTitle.hashCode ^
      currentArtist.hashCode ^
      currentCover.hashCode ^
      volume.hashCode;
}

class _MiniPlayerContent extends StatelessWidget {
  final _MiniPlayerState state;

  const _MiniPlayerContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      container: true,
      label: 'Mini lecteur - ${state.currentTitle} par ${state.currentArtist}',
      hint: 'Appuyez pour ouvrir le lecteur complet',
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: () {
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute != AppRoutes.radio) {
              Navigator.pushNamed(context, AppRoutes.radio);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(12),
            // PERFORMANCE: Removed BackdropFilter, using static glass effect
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated progress bar
                if (state.isPlaying) _buildProgressBar(),

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
    );
  }

  Widget _buildProgressBar() {
    return RepaintBoundary(
      child:
          SizedBox(
                height: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryLight,
                    ),
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: const Duration(seconds: 2),
                color: AppColors.primaryDark.withValues(alpha: 0.5),
              ),
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
        child: state.currentCover != null
            // OPTIMIZED: Use CachedNetworkImage instead of Image.network with size constraints
            ? CachedNetworkImage(
                imageUrl: state.currentCover!,
                fit: BoxFit.cover,
                maxWidthDiskCache: 96,
                maxHeightDiskCache: 96,
                memCacheWidth: 96,
                memCacheHeight: 96,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
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
            if (state.isPlaying)
              RepaintBoundary(
                child:
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
              ),

            Expanded(
              child: Text(
                state.currentTitle,
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
          state.currentArtist,
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
    return Semantics(
      container: true,
      label: 'Contrôles de lecture',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Volume button (optional popup)
          Semantics(
            button: true,
            label: state.volume == 0 ? 'Réactiver le son' : 'Couper le son',
            hint: 'Volume actuel : ${(state.volume * 100).round()}%',
            child: IconButton(
              icon: Icon(
                state.volume == 0 ? Icons.volume_off : Icons.volume_up,
                size: 20,
              ),
              onPressed: () {
                final radioProvider = context.read<RadioProvider>();
                // Toggle mute
                if (state.volume > 0) {
                  radioProvider.setVolume(0);
                } else {
                  radioProvider.setVolume(0.8);
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),

          // Play/Pause button
          Semantics(
            button: true,
            label: state.isLoading
                ? 'Chargement'
                : (state.isPlaying ? 'Mettre en pause' : 'Lire'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.violetGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                onPressed: state.isLoading
                    ? null
                    : () {
                        final radioProvider = context.read<RadioProvider>();
                        radioProvider.togglePlayPause();
                      },
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
