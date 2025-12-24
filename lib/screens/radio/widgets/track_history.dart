import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/theme.dart';
import '../../../models/track.dart';

/// Track history list showing recently played tracks
class TrackHistory extends StatelessWidget {
  final List<Track> tracks;
  final bool showViewAll;
  final int maxItems;
  final VoidCallback? onViewAll;

  const TrackHistory({
    super.key,
    required this.tracks,
    this.showViewAll = true,
    this.maxItems = 5,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayTracks = tracks.take(maxItems).toList();

    if (tracks.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  size: 20,
                  color: isDark
                      ? AppColors.darkMutedForeground
                      : AppColors.lightMutedForeground,
                ),
                const SizedBox(width: 8),
                Text(
                  'Historique des pistes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
              ],
            ),
            if (showViewAll && tracks.length > maxItems)
              TextButton(onPressed: onViewAll, child: const Text('Voir tout')),
          ],
        ),

        const SizedBox(height: 12),

        // Track list
        ...displayTracks.asMap().entries.map((entry) {
          final index = entry.key;
          final track = entry.value;

          return _TrackItem(track: track, isDark: isDark)
              .animate(delay: Duration(milliseconds: index * 100))
              .fadeIn()
              .slideX(begin: -0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune piste dans l\'historique',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lancez la radio pour voir les pistes jouées',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TrackItem extends StatelessWidget {
  final Track track;
  final bool isDark;

  const _TrackItem({required this.track, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
      ),
      child: Row(
        children: [
          // Music icon placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: AppColors.violetGradient.scale(0.5),
            ),
            child: const Icon(Icons.music_note, color: Colors.white, size: 20),
          ),

          const SizedBox(width: 12),

          // Track info
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
                const SizedBox(height: 2),
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

          // Time played
          if (track.playedAt != null)
            Text(
              _formatTime(track.playedAt!),
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkMutedForeground
                    : AppColors.lightMutedForeground,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'À l\'instant';
    } else if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Extension to scale gradient
extension GradientExtension on LinearGradient {
  LinearGradient scale(double factor) {
    return LinearGradient(
      colors: colors
          .map((c) => Color.lerp(c, Colors.grey, 1 - factor)!)
          .toList(),
      begin: begin,
      end: end,
    );
  }
}
