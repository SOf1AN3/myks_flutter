import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  // PERFORMANCE: Reduced animation durations and simplified
  static const _headerFadeDuration = Duration(milliseconds: 400);
  static const _videoFadeDuration = Duration(milliseconds: 400);
  static const _videoFadeDelay = Duration(milliseconds: 100);
  static const _ctaFadeDuration = Duration(milliseconds: 400);
  static const _ctaFadeDelay = Duration(milliseconds: 200);
  static const _footerFadeDuration = Duration(milliseconds: 400);
  static const _footerFadeDelay = Duration(milliseconds: 300);

  YoutubePlayerController? _youtubeController;
  bool _controllerInitialized = false;
  bool _shouldLoadVideo = false; // PERFORMANCE: Flag for lazy loading
  bool _isLoadingVideo = false; // Loading state indicator

  @override
  void initState() {
    super.initState();
    _loadFeaturedVideo();
  }

  Future<void> _loadFeaturedVideo() async {
    final videosProvider = context.read<VideosProvider>();
    await videosProvider.fetchFeaturedVideo();
    // PERFORMANCE: Controller does NOT initialize automatically
    // Only loads when user taps the video thumbnail
  }

  /// PERFORMANCE: Lazy initialization - only when user taps to load
  void _onVideoTapToLoad() {
    if (_controllerInitialized || _isLoadingVideo) return;

    final featuredVideo = context.read<VideosProvider>().featuredVideo;
    if (featuredVideo == null) return;

    setState(() {
      _isLoadingVideo = true;
    });

    // Initialize controller in post-frame callback to avoid build-during-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _youtubeController = YoutubePlayerController(
        initialVideoId: featuredVideo.youtubeId,
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
      _controllerInitialized = true;

      if (mounted) {
        setState(() {
          _shouldLoadVideo = true;
          _isLoadingVideo = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // OPTIMIZED: Proper cleanup of YouTube controller
    _youtubeController?.dispose();
    _youtubeController = null;
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
                    // Logo/Title - PERFORMANCE: Simplified animation (fadeIn only)
                    _buildHeader().animate().fadeIn(
                      duration: _headerFadeDuration,
                    ),

                    const SizedBox(height: 40),

                    // Featured Video - PERFORMANCE: Simplified animation
                    _buildFeaturedVideo().animate().fadeIn(
                      duration: _videoFadeDuration,
                      delay: _videoFadeDelay,
                    ),

                    const SizedBox(height: 40),

                    // CTA Buttons - PERFORMANCE: Simplified animation
                    _buildCTAButtons().animate().fadeIn(
                      duration: _ctaFadeDuration,
                      delay: _ctaFadeDelay,
                    ),

                    const SizedBox(height: 60),

                    // Footer - PERFORMANCE: Simplified animation
                    _buildFooter().animate().fadeIn(
                      duration: _footerFadeDuration,
                      delay: _footerFadeDelay,
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
              // PERFORMANCE: Removed BackdropFilter, using static gradient
              gradient: AppColors.playButtonGradient,
              borderRadius: BorderRadius.circular(48),
              border: Border.all(
                color: const Color(0x4DFFFFFF), // rgba(255,255,255,0.3)
                width: 1.5,
              ),
              boxShadow: GlassEffects.glowShadow,
            ),
            child: const Icon(Icons.radio, color: Colors.white, size: 48),
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
    // PERFORMANCE: Use selector to rebuild only when featured video changes
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
            // Video Player or Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _shouldLoadVideo && _youtubeController != null
                  ? YoutubePlayer(
                      controller: _youtubeController!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: AppColors.primaryLight,
                      progressColors: const ProgressBarColors(
                        playedColor: AppColors.primaryLight,
                        handleColor: AppColors.primaryDark,
                      ),
                    )
                  : _buildVideoThumbnail(featuredVideo),
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

  /// PERFORMANCE: Shows YouTube thumbnail instead of embedded player
  /// Player only loads when user taps
  Widget _buildVideoThumbnail(Video? video) {
    if (video == null) {
      return _buildVideoPlaceholder();
    }

    // PERFORMANCE: Use YouTube thumbnail URL (no player initialization)
    final thumbnailUrl =
        'https://img.youtube.com/vi/${video.youtubeId}/hqdefault.jpg';

    return RepaintBoundary(
      child: GestureDetector(
        onTap: _onVideoTapToLoad,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // YouTube thumbnail image
            CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.darkBackgroundDeep,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => _buildVideoPlaceholder(),
            ),

            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),

            // Play button and text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoadingVideo)
                    // Show loading indicator
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  else
                    // Show play button
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.playButtonGradient,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: GlassEffects.glowShadow,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  if (!_isLoadingVideo) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Appuyez pour charger la vidéo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
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
            // PERFORMANCE: Removed BackdropFilter, using static gradient
            gradient: AppColors.playButtonGradient,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0x4DFFFFFF), width: 1.5),
            boxShadow: GlassEffects.glowShadow,
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
            // PERFORMANCE: Removed BackdropFilter, using static glass color
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.glassBorder, width: 1),
            boxShadow: GlassEffects.glassShadow,
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
