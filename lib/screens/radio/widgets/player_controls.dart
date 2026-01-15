import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../widgets/liquid_button.dart';

/// Player controls widget with prev/play/next buttons and volume slider
/// Redesigned to match the liquid glass aesthetic from design.html
class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final double volume;
  final VoidCallback onTogglePlay;
  final ValueChanged<double> onVolumeChange;

  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.volume,
    required this.onTogglePlay,
    required this.onVolumeChange,
  });

  // Empty callback for disabled buttons (no-op)
  void _onDisabledTap() {
    // Radio doesn't have previous/next track functionality
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Control buttons: prev + play + next
        Semantics(
          container: true,
          label: 'Contrôles de lecture',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              LiquidButton.control(
                icon: Icons.skip_previous,
                onTap: _onDisabledTap,
                semanticLabel: 'Piste précédente (non disponible)',
              ),

              const SizedBox(width: 32),

              // Main play/pause button
              LiquidButton.play(
                isPlaying: isPlaying,
                isLoading: isLoading,
                onTap: onTogglePlay,
              ),

              const SizedBox(width: 32),

              // Next button
              LiquidButton.control(
                icon: Icons.skip_next,
                onTap: _onDisabledTap,
                semanticLabel: 'Piste suivante (non disponible)',
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Volume slider
        _VolumeSlider(volume: volume, onVolumeChange: onVolumeChange),
      ],
    );
  }
}

/// Volume slider with liquid glass style
class _VolumeSlider extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onVolumeChange;

  const _VolumeSlider({required this.volume, required this.onVolumeChange});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Contrôle du volume',
      value: '${(volume * 100).round()} pourcent',
      hint: 'Faites glisser pour ajuster le volume',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Volume mute icon
            Icon(
              Icons.volume_mute,
              size: 20,
              color: Colors.white.withValues(alpha: 0.4),
            ),

            const SizedBox(width: 16),

            // Slider
            Expanded(
              child: RepaintBoundary(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    // PERFORMANCE: Removed BackdropFilter
                    child: Stack(
                      children: [
                        // Background track
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0x26FFFFFF), Color(0x0DFFFFFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: AppColors.glassControlBorder,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // Active track
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: volume,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0x66A855F7), Color(0xFFA855F7)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Invisible slider for interaction
                        Positioned.fill(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 0,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 0,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 0,
                              ),
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                            ),
                            child: Slider(
                              value: volume,
                              onChanged: onVolumeChange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Volume up icon
            Icon(
              Icons.volume_up,
              size: 20,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
