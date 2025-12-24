import 'package:flutter/material.dart';
import '../../../config/theme.dart';

/// Player controls widget with play/pause and volume
class PlayerControls extends StatefulWidget {
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

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _playButtonController;
  bool _showVolumeSlider = false;

  @override
  void initState() {
    super.initState();
    _playButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    if (widget.isPlaying) {
      _playButtonController.forward();
    }
  }

  @override
  void didUpdateWidget(PlayerControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _playButtonController.forward();
      } else {
        _playButtonController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _playButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Volume button
            _buildVolumeButton(),

            const SizedBox(width: 24),

            // Main play/pause button
            _buildPlayButton(),

            const SizedBox(width: 24),

            // Placeholder for symmetry
            const SizedBox(width: 48),
          ],
        ),

        // Volume slider (expandable)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _showVolumeSlider ? 48 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _showVolumeSlider ? 1 : 0,
            child: _buildVolumeSlider(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTogglePlay,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: AppColors.violetGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _playButtonController,
                  color: Colors.white,
                  size: 40,
                ),
        ),
      ),
    );
  }

  Widget _buildVolumeButton() {
    IconData volumeIcon;
    if (widget.volume == 0) {
      volumeIcon = Icons.volume_off;
    } else if (widget.volume < 0.5) {
      volumeIcon = Icons.volume_down;
    } else {
      volumeIcon = Icons.volume_up;
    }

    return IconButton(
      icon: Icon(volumeIcon),
      iconSize: 28,
      onPressed: () {
        setState(() {
          _showVolumeSlider = !_showVolumeSlider;
        });
      },
      tooltip: 'Volume',
    );
  }

  Widget _buildVolumeSlider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Icon(
            Icons.volume_down,
            size: 20,
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primaryLight,
                inactiveTrackColor: isDark
                    ? AppColors.darkMuted
                    : AppColors.lightMuted,
                thumbColor: AppColors.primaryLight,
                overlayColor: AppColors.primaryLight.withOpacity(0.2),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: widget.volume,
                onChanged: widget.onVolumeChange,
              ),
            ),
          ),
          Icon(
            Icons.volume_up,
            size: 20,
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
        ],
      ),
    );
  }
}
