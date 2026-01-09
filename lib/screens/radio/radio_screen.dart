import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../providers/radio_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/mesh_gradient_background.dart';
import '../../widgets/liquid_glass_container.dart';
import 'widgets/audio_visualizer.dart';
import 'widgets/player_controls.dart';
import 'widgets/live_community_panel.dart';

/// Main radio screen with liquid glass design
/// Redesigned to match design.html aesthetic
class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final radioProvider = context.watch<RadioProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshGradientBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Main scrollable content
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                  bottom: 450,
                ), // Space for panel + nav
                child: Column(
                  children: [
                    // Header with back and menu buttons
                    _buildHeader(context).animate().fadeIn(
                      duration: const Duration(milliseconds: 400),
                    ),

                    const SizedBox(height: 20),

                    // Audio Visualizer in curved glass viewer
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child:
                          AudioVisualizer(
                                isPlaying: radioProvider.isPlaying,
                                height: 200,
                              )
                              .animate()
                              .fadeIn(
                                duration: const Duration(milliseconds: 500),
                                delay: const Duration(milliseconds: 100),
                              )
                              .slideY(begin: 0.1, end: 0),
                    ),

                    const SizedBox(height: 40),

                    // Track title and info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildTrackInfo(context, radioProvider)
                          .animate()
                          .fadeIn(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 200),
                          ),
                    ),

                    const SizedBox(height: 40),

                    // Player controls (prev + play + next + volume)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child:
                          PlayerControls(
                            isPlaying: radioProvider.isPlaying,
                            isLoading: radioProvider.isLoading,
                            volume: radioProvider.volume,
                            onTogglePlay: () => radioProvider.togglePlayPause(),
                            onVolumeChange: (volume) =>
                                radioProvider.setVolume(volume),
                          ).animate().fadeIn(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 300),
                          ),
                    ),

                    const SizedBox(height: 20),

                    // Error message if any
                    if (radioProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildErrorBanner(
                          radioProvider.error!,
                        ).animate().fadeIn().shake(),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Live Community Panel at bottom (fixed)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: const LiveCommunityPanel()
                          .animate()
                          .fadeIn(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 400),
                          )
                          .slideY(begin: 0.2, end: 0),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          LiquidControlContainer(
            size: 40,
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.keyboard_arrow_down,
              size: 24,
              color: Colors.white,
            ),
          ),

          // Title
          Column(
            children: [
              Text(
                'STREAMING NOW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'MYKS Radio',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),

          // Menu button
          LiquidControlContainer(
            size: 40,
            onTap: () => _showMenu(context),
            child: const Icon(Icons.more_horiz, size: 24, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackInfo(BuildContext context, RadioProvider radioProvider) {
    final track = radioProvider.currentTrack;

    return Column(
      children: [
        Text(
          track?.displayTitle ?? 'Vibe Urbaine Vol. 3',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          track?.displayArtist ?? 'Original Mix • 102.4 FM',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.primary.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LiquidGlassContainer(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        borderRadius: GlassEffects.radiusLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _MenuOption(
              icon: Icons.share,
              title: 'Partager',
              onTap: () => Navigator.pop(context),
            ),
            _MenuOption(
              icon: Icons.info_outline,
              title: 'À propos',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
            _MenuOption(
              icon: Icons.settings,
              title: 'Paramètres',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white.withOpacity(0.9)),
      title: Text(
        title,
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
