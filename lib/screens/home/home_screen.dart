import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/videos_provider.dart';
import '../../providers/radio_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/mini_player.dart';

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
    final radioProvider = context.watch<RadioProvider>();
    final showMiniPlayer = radioProvider.isPlaying || radioProvider.isPaused;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
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

                  const SizedBox(height: 32),

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

                  // Footer
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
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Radio icon with gradient
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.violetGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.radio, color: Colors.white, size: 40),
        ),

        const SizedBox(height: 24),

        // Welcome text with gradient
        const GradientText(
          text: 'Bienvenue sur MYKS',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          'Votre radio en ligne 24/7',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturedVideo() {
    final videosProvider = context.watch<VideosProvider>();
    final featuredVideo = videosProvider.featuredVideo;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
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
                  : Container(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkMuted
                          : AppColors.lightMuted,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 64,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.darkMutedForeground
                                  : AppColors.lightMutedForeground,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune vidéo disponible',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.darkMutedForeground
                                    : AppColors.lightMutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // Video info
          if (featuredVideo != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    featuredVideo.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCTAButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            text: 'Écouter la Radio',
            icon: Icons.radio,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.radio),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: GradientOutlinedButton(
            text: 'Voir les Vidéos',
            icon: Icons.video_library,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.videos),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        const SizedBox(height: 16),
        Text(
          '© 2024 Myks Radio. Tous droits réservés.',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(Icons.facebook, 'Facebook'),
            _buildSocialIcon(Icons.camera_alt, 'Instagram'),
            _buildSocialIcon(Icons.music_note, 'Twitter'),
            _buildSocialIcon(Icons.play_circle, 'YouTube'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        icon,
        color: isDark
            ? AppColors.darkMutedForeground
            : AppColors.lightMutedForeground,
      ),
      tooltip: label,
      onPressed: () {
        // TODO: Open social links
      },
    );
  }
}
