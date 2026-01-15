import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/radio_metadata.dart';

/// Radio stats grid showing listeners, quality, format, status
class RadioStats extends StatelessWidget {
  final RadioMetadata? metadata;
  final bool isPlaying;

  const RadioStats({super.key, this.metadata, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use 2 columns on mobile, 4 on larger screens
        final crossAxisCount = constraints.maxWidth > 400 ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: constraints.maxWidth > 400 ? 1.5 : 1.2,
          children: [
            _StatCard(
              icon: Icons.people_outline,
              label: 'Auditeurs',
              value: metadata?.listenersDisplay ?? '0',
              color: AppColors.primaryLight,
            ),
            _StatCard(
              icon: Icons.headphones,
              label: 'Qualité',
              value: metadata?.bitrateDisplay ?? 'N/A',
              color: AppColors.secondary,
            ),
            _StatCard(
              icon: Icons.radio,
              label: 'Format',
              value: metadata?.audioFormat ?? 'MP3',
              color: AppColors.tertiary,
            ),
            _StatCard(
              icon: Icons.signal_cellular_alt,
              label: 'Statut',
              value: isPlaying ? 'En ligne' : 'Hors ligne',
              color: isPlaying ? AppColors.success : AppColors.error,
              isStatus: true,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isStatus;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isStatus
                  ? color
                  : (isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
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
}
