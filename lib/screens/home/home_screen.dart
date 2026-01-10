import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../models/video.dart';
import '../../providers/videos_provider.dart';
import '../../providers/radio_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/mini_player.dart';
import '../../widgets/mesh_gradient_background.dart';
import '../../widgets/liquid_glass_container.dart';

/// Home screen with featured video and navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _loadFeaturedVideo();
  }

  Future<void> _loadFeaturedVideo() async {
    final videosProvider = context.read<VideosProvider>();
    await videosProvider.fetchFeaturedVideo();

    final video = videosProvider.featuredVideo;
    if (video != null && mounted) {
      setState(() {
        _youtubeController = YoutubePlayerController(
          initialVideoId: video.youtubeId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            enableCaption: true,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // OPTIMIZED: Use selector instead of watch to rebuild only when needed
    final showMiniPlayer = context.select<RadioProvider, bool>(
      (provider) => provider.isPlaying || provider.isPaused,
    );

    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 40,
                  bottom: showMiniPlayer ? 100 : 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo/Title
                    _buildHeader()
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 600))
                        .slideY(begin: -0.2, end: 0),

                    const SizedBox(height: 40),

                    // Featured Video
                    _buildFeaturedVideo()
                        .animate()
                        .fadeIn(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 200),
                        )
                        .scale(begin: const Offset(0.95, 0.95)),

                    const SizedBox(height: 40),

                    // CTA Buttons
                    _buildCTAButtons()
                        .animate()
                        .fadeIn(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 400),
                        )
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 60),

                    // Footer - Now in scroll view
                    _buildFooter().animate().fadeIn(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 600),
                    ),
                  ],
                ),
              ),

              // Mini Player
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MiniPlayer(visible: showMiniPlayer),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Radio icon with liquid glass effect
        RepaintBoundary(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48),
              boxShadow: GlassEffects.glowShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 6, // Reduced from 8 for better performance
                  sigmaY: 6,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.playButtonGradient,
                    border: Border.all(
                      color: const Color(0x4DFFFFFF), // rgba(255,255,255,0.3)
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(48),
                  ),
                  child: const Icon(Icons.radio, color: Colors.white, size: 48),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Title text with gradient
        const GradientText(
          text: 'MYKS Radio',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          'Votre radio en ligne 24/7',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturedVideo() {
    // OPTIMIZED: Use selector to rebuild only when featured video changes
    final featuredVideo = context.select<VideosProvider, Video?>(
      (provider) => provider.featuredVideo,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(GlassEffects.radiusLarge),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1)
            width: 1,
          ),
          borderRadius: BorderRadius.circular(GlassEffects.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video Player
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _youtubeController != null && featuredVideo != null
                  ? YoutubePlayer(
                      controller: _youtubeController!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: AppColors.primaryLight,
                      progressColors: const ProgressBarColors(
                        playedColor: AppColors.primaryLight,
                        handleColor: AppColors.primaryDark,
                      ),
                    )
                  : _buildVideoPlaceholder(),
            ),

            // Video info inside same container
            if (featuredVideo != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0x08FFFFFF), // rgba(255, 255, 255, 0.03)
                ),
                child: Text(
                  featuredVideo.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBackgroundDeep,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.play_circle_outline,
                size: 48,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune vidéo disponible',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButtons() {
    return Column(
      children: [
        // Primary: Listen to Radio (Play style)
        _buildPrimaryCTA(),

        const SizedBox(height: 20),

        // Secondary: Watch Videos (Control style)
        _buildSecondaryCTA(),
      ],
    );
  }

  Widget _buildPrimaryCTA() {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.radio),
        child: Container(
          height: 72,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: GlassEffects.glowShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8, // Reduced from 10 for performance
                sigmaY: 8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.playButtonGradient,
                  border: Border.all(
                    color: const Color(0x4DFFFFFF),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.radio, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Écouter la Radio',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
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

  Widget _buildSecondaryCTA() {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.videos),
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: GlassEffects.glassShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX:
                    8, // Reduced from GlassEffects.blurIntensityControl (16) for performance
                sigmaY: 8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.glassBackground,
                  border: Border.all(color: AppColors.glassBorder, width: 1),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_library,
                      color: Colors.white.withOpacity(0.9),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Voir les Vidéos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
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

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LiquidGlassContainer(
        padding: const EdgeInsets.all(24),
        showInnerGlow: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '© 2024 Myks Radio. Tous droits réservés.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildSocialButton(
                  Icons.facebook,
                  'Facebook',
                  AppConstants.facebookUrl,
                ),
                _buildSocialButton(
                  Icons.camera_alt,
                  'Instagram',
                  AppConstants.instagramUrl,
                ),
                _buildSocialButton(
                  Icons.music_note,
                  'Twitter',
                  AppConstants.twitterUrl,
                ),
                _buildSocialButton(
                  Icons.play_circle,
                  'YouTube',
                  AppConstants.youtubeUrl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          borderRadius: BorderRadius.circular(24),
          boxShadow: GlassEffects.glassShadow,
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 24),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
