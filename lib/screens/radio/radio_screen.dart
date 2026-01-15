import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/radio_metadata.dart';
import '../../providers/radio_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/mesh_gradient_background.dart';
import '../../widgets/liquid_glass_container.dart';
import '../../widgets/liquid_button.dart';
import 'widgets/audio_visualizer.dart';

/// Main radio screen with liquid glass design
/// Redesigned with simplified UI and enhanced metadata display
class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  // Static const animation durations and parameters to avoid recreation
  static const _fadeInDuration500 = Duration(milliseconds: 500);
  static const _delay100 = Duration(milliseconds: 100);
  static const _delay200 = Duration(milliseconds: 200);
  static const _delay300 = Duration(milliseconds: 300);
  static const _slideYBegin = 0.1;
  static const _slideYEnd = 0.0;

  @override
  Widget build(BuildContext context) {
    // OPTIMIZED: Use select for specific properties only
    final isPlaying = context.select<RadioProvider, bool>(
      (provider) => provider.isPlaying,
    );
    final isLoading = context.select<RadioProvider, bool>(
      (provider) => provider.isLoading,
    );
    final error = context.select<RadioProvider, String?>(
      (provider) => provider.error,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshGradientBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Space for nav
            child: Column(
              children: [
                const SizedBox(height: 40),

                // App title
                Text(
                      'MYKS Radio',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: _fadeInDuration500)
                    .slideY(begin: _slideYBegin, end: _slideYEnd),

                const SizedBox(height: 8),

                // Streaming status
                Text(
                      'STREAMING NOW',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: _fadeInDuration500, delay: _delay100)
                    .slideY(begin: _slideYBegin, end: _slideYEnd),

                const SizedBox(height: 40),

                // Enhanced metadata display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildEnhancedMetadata(context).animate().fadeIn(
                    duration: _fadeInDuration500,
                    delay: _delay100,
                  ),
                ),

                const SizedBox(height: 48),

                // Audio Visualizer (new simple version)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SimpleAudioVisualizer(isPlaying: isPlaying)
                      .animate()
                      .fadeIn(duration: _fadeInDuration500, delay: _delay200)
                      .slideY(begin: _slideYBegin, end: _slideYEnd),
                ),

                const SizedBox(height: 48),

                // Play button only (centered)
                LiquidButton.play(
                      isPlaying: isPlaying,
                      isLoading: isLoading,
                      onTap: () {
                        final radioProvider = context.read<RadioProvider>();
                        radioProvider.togglePlayPause();
                      },
                    )
                    .animate()
                    .fadeIn(duration: _fadeInDuration500, delay: _delay300)
                    .scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 20),

                // Error message if any
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: RepaintBoundary(
                      child: _buildErrorBanner(
                        error,
                      ).animate().fadeIn().shake(),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }

  /// Enhanced metadata display with better visual hierarchy
  Widget _buildEnhancedMetadata(BuildContext context) {
    // Select metadata properties
    final currentTitle = context.select<RadioProvider, String>(
      (provider) => provider.currentTitle,
    );
    final currentArtist = context.select<RadioProvider, String>(
      (provider) => provider.currentArtist,
    );
    final metadata = context.select<RadioProvider, RadioMetadata?>(
      (provider) => provider.metadata,
    );

    return LiquidGlassContainer(
      padding: const EdgeInsets.all(28),
      borderRadius: GlassEffects.radiusLarge,
      child: Column(
        children: [
          // Title
          Text(
            currentTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          if (currentArtist != 'En attente...') ...[
            const SizedBox(height: 12),

            // Artist
            Text(
              currentArtist,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Additional metadata
          if (metadata != null) ...[
            const SizedBox(height: 20),

            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.glassControlBorder,
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (metadata.listeners != null) ...[
                  _MetadataItem(
                    icon: Icons.people,
                    label: '${metadata.listeners} auditeurs',
                  ),
                  const SizedBox(width: 24),
                ],
                if (metadata.bitrate != null)
                  _MetadataItem(
                    icon: Icons.graphic_eq,
                    label: metadata.bitrateDisplay,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.error.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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
}

/// Metadata item widget for displaying stats
class _MetadataItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetadataItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
