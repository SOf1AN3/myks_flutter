import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../providers/radio_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/common_widgets.dart';
import 'widgets/audio_visualizer.dart';
import 'widgets/player_controls.dart';
import 'widgets/now_playing_card.dart';
import 'widgets/radio_stats.dart';
import 'widgets/track_history.dart';

/// Main radio screen with player and controls
class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final radioProvider = context.watch<RadioProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Radio'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => radioProvider.refreshMetadata(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                _buildHeader(
                  context,
                ).animate().fadeIn(duration: const Duration(milliseconds: 400)),

                const SizedBox(height: 24),

                // Main player card
                _buildPlayerCard(context, radioProvider, isDark)
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 100),
                    )
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // Now Playing Card
                NowPlayingCard(
                  metadata: radioProvider.metadata,
                  isPlaying: radioProvider.isPlaying,
                  isLoading: radioProvider.isLoading,
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                ),

                const SizedBox(height: 24),

                // Radio Stats
                RadioStats(
                  metadata: radioProvider.metadata,
                  isPlaying: radioProvider.isPlaying,
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                ),

                const SizedBox(height: 32),

                // Track History
                TrackHistory(
                  tracks: radioProvider.history,
                  onViewAll: () => _showFullHistory(context, radioProvider),
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 400),
                ),

                const SizedBox(height: 32),

                // Error message
                if (radioProvider.error != null)
                  _buildErrorBanner(
                    radioProvider.error!,
                    isDark,
                  ).animate().fadeIn().shake(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const GradientText(
          text: 'Myks Radio',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Votre radio en ligne 24/7',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(
    BuildContext context,
    RadioProvider radioProvider,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Audio Visualizer
          AudioVisualizer(isPlaying: radioProvider.isPlaying, height: 80),

          const SizedBox(height: 32),

          // Player Controls
          PlayerControls(
            isPlaying: radioProvider.isPlaying,
            isLoading: radioProvider.isLoading,
            volume: radioProvider.volume,
            onTogglePlay: () => radioProvider.togglePlayPause(),
            onVolumeChange: (volume) => radioProvider.setVolume(volume),
          ),

          const SizedBox(height: 16),

          // Current track info (small)
          if (radioProvider.currentTrack != null)
            Text(
              radioProvider.currentTrack!.fullDisplay,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.error.withOpacity(0.1),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: AppColors.error, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullHistory(BuildContext context, RadioProvider radioProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Historique complet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkForeground
                              : AppColors.lightForeground,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          radioProvider.clearHistory();
                          Navigator.pop(context);
                        },
                        child: const Text('Effacer'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Track list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: radioProvider.history.length,
                    itemBuilder: (context, index) {
                      final track = radioProvider.history[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.03),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: AppColors.violetGradient,
                              ),
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.displayTitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkForeground
                                          : AppColors.lightForeground,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    track.displayArtist,
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
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
