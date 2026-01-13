import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/video.dart';
import '../../providers/videos_provider.dart';
import '../../providers/radio_provider.dart';
import '../../services/youtube_service.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/mini_player.dart';
import '../../widgets/mesh_gradient_background.dart';
import '../../widgets/custom_video_controls.dart';

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

  VideoPlayerController? _videoController;
  String? _streamUrl;
  bool _controllerInitialized = false;
  bool _shouldLoadVideo = false; // PERFORMANCE: Flag for lazy loading
  bool _isLoadingVideo = false; // Loading state indicator
  final _youtubeService = YouTubeService();

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
  Future<void> _onVideoTapToLoad() async {
    if (_controllerInitialized || _isLoadingVideo) return;

    final featuredVideo = context.read<VideosProvider>().featuredVideo;
    if (featuredVideo == null) return;

    setState(() {
      _isLoadingVideo = true;
    });

    try {
      // Initialize controller in post-frame callback to avoid build-during-build
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        // 1. Extract stream URL
        _streamUrl = await _youtubeService.getStreamUrl(
          featuredVideo.youtubeId,
          quality: StreamQuality.medium,
        );

        // 2. Create video player controller
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(_streamUrl!),
        );

        // 3. Initialize controller
        await _videoController!.initialize();
        _controllerInitialized = true;

        if (mounted) {
          setState(() {
            _shouldLoadVideo = true;
            _isLoadingVideo = false;
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _isLoadingVideo = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // OPTIMIZED: Proper cleanup of video controller
    _videoController?.dispose();
    _videoController = null;
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
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _shouldLoadVideo && _videoController != null
              ? Stack(
                  children: [
                    VideoPlayer(_videoController!),
                    CustomVideoControls(controller: _videoController!),
                  ],
                )
              : _buildVideoThumbnail(featuredVideo),
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
          height: 72,
          width: double.infinity,
          decoration: BoxDecoration(
            // PERFORMANCE: Removed BackdropFilter, using static glass color
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: AppColors.glassBorder, width: 1.5),
            boxShadow: GlassEffects.glassShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library,
                color: Colors.white.withOpacity(0.9),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Voir les Vidéos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
