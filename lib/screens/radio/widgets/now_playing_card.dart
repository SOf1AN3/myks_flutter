import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme.dart';
import '../../../models/radio_metadata.dart';

/// Now Playing card showing current track info
class NowPlayingCard extends StatelessWidget {
  final RadioMetadata? metadata;
  final bool isPlaying;
  final bool isLoading;

  const NowPlayingCard({
    super.key,
    this.metadata,
    required this.isPlaying,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String statusText = isLoading
        ? 'Connexion en cours'
        : isPlaying
        ? 'En direct'
        : 'En pause';

    final String trackInfo = metadata != null
        ? '${metadata!.title} par ${metadata!.artist}'
        : 'Myks Radio';

    return MergeSemantics(
      child: Semantics(
        container: true,
        label: 'Lecture en cours',
        value: '$statusText. $trackInfo',
        hint: 'Informations sur la piste en cours de lecture',
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.05,
            ),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withValues(
                alpha: 0.1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  ExcludeSemantics(child: _buildStatusBadge(isDark)),
                  const Spacer(),
                  if (isPlaying) ExcludeSemantics(child: _buildLiveIndicator()),
                ],
              ),

              const SizedBox(height: 16),

              // Track info
              Row(
                children: [
                  // Album art
                  ExcludeSemantics(child: _buildAlbumArt(isDark)),

                  const SizedBox(width: 16),

                  // Track details
                  Expanded(
                    child: ExcludeSemantics(child: _buildTrackInfo(isDark)),
                  ),
                ],
              ),

              if (metadata != null &&
                  (metadata!.genre != null || metadata!.listeners != null)) ...[
                const SizedBox(height: 16),
                Divider(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                const SizedBox(height: 12),
                ExcludeSemantics(child: _buildMetadataRow(isDark)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark) {
    final Color bgColor;
    final Color textColor;
    final String text;
    final IconData icon;

    if (isLoading) {
      bgColor = AppColors.warning.withValues(alpha: 0.2);
      textColor = AppColors.warning;
      text = 'CONNEXION...';
      icon = Icons.sync;
    } else if (isPlaying) {
      bgColor = AppColors.live.withValues(alpha: 0.2);
      textColor = AppColors.live;
      text = 'EN DIRECT';
      icon = Icons.circle;
    } else {
      bgColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
      textColor = isDark
          ? AppColors.darkMutedForeground
          : AppColors.lightMutedForeground;
      text = 'EN PAUSE';
      icon = Icons.pause_circle;
    }

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 10, color: textColor),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => isPlaying ? controller.repeat() : null)
        .fade(
          duration: const Duration(seconds: 1),
          begin: isPlaying ? 0.7 : 1.0,
          end: 1.0,
        );
  }

  Widget _buildLiveIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated disc icon
        const Icon(Icons.album, size: 24, color: AppColors.primaryLight)
            .animate(onPlay: (c) => c.repeat())
            .rotate(duration: const Duration(seconds: 3)),

        const SizedBox(width: 8),

        // Signal waves
        Icon(
              Icons.wifi_tethering,
              size: 18,
              color: AppColors.success.withValues(alpha: 0.8),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fade(duration: const Duration(milliseconds: 800)),
      ],
    );
  }

  Widget _buildAlbumArt(bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: metadata?.coverUrl != null
            ? CachedNetworkImage(
                imageUrl: metadata!.coverUrl!,
                fit: BoxFit.cover,
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
      child: const Center(
        child: Icon(Icons.music_note, color: Colors.white, size: 36),
      ),
    );
  }

  Widget _buildTrackInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          metadata?.title ?? 'Myks Radio',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.darkForeground
                : AppColors.lightForeground,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          metadata?.artist ?? 'En attente...',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (metadata?.album != null) ...[
          const SizedBox(height: 4),
          Text(
            metadata!.album!,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataRow(bool isDark) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        if (metadata?.genre != null)
          _buildMetadataChip(Icons.music_note, metadata!.genre!, isDark),
        if (metadata?.listeners != null)
          _buildMetadataChip(
            Icons.people,
            '${metadata!.listeners} auditeurs',
            isDark,
          ),
        if (metadata?.bitrate != null)
          _buildMetadataChip(
            Icons.headphones,
            metadata!.bitrateDisplay,
            isDark,
          ),
      ],
    );
  }

  Widget _buildMetadataChip(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark
              ? AppColors.darkMutedForeground
              : AppColors.lightMutedForeground,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
        ),
      ],
    );
  }
}
