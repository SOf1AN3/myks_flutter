import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/radio_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/mini_player.dart';
import '../../widgets/mesh_gradient_background.dart';
import '../../widgets/liquid_glass_container.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/common_widgets.dart';

/// About screen with app information and features
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final radioProvider = context.watch<RadioProvider>();
    final showMiniPlayer = radioProvider.isPlaying || radioProvider.isPaused;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshGradientBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: showMiniPlayer ? 100 : 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button
                    ScreenHeader.withBack(
                      context: context,
                      title: 'À PROPOS',
                      subtitle: 'DÉCOUVREZ',
                    ).animate().fadeIn(
                      duration: const Duration(milliseconds: 400),
                    ),

                    const SizedBox(height: 32),

                    // Logo and title
                    _buildHeader()
                        .animate()
                        .fadeIn(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 100),
                        )
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 32),

                    // Mission card
                    _buildMissionCard()
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 200))
                        .slideX(begin: -0.1, end: 0),

                    const SizedBox(height: 24),

                    // Features grid
                    _buildFeaturesGrid().animate().fadeIn(
                      delay: const Duration(milliseconds: 300),
                    ),

                    const SizedBox(height: 32),

                    // Social links
                    _buildSocialLinks().animate().fadeIn(
                      delay: const Duration(milliseconds: 400),
                    ),

                    const SizedBox(height: 32),

                    // Version info
                    _buildVersionInfo().animate().fadeIn(
                      delay: const Duration(milliseconds: 500),
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
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.violetGradient,
            borderRadius: BorderRadius.circular(25),
            boxShadow: GlassEffects.glowShadow,
          ),
          child: const Icon(Icons.radio, color: Colors.white, size: 50),
        ),

        const SizedBox(height: 24),

        // Title with gradient
        const GradientText(
          text: 'MYKS Radio',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Votre destination musicale préférée',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMissionCard() {
    return LiquidGlassContainer(
      padding: const EdgeInsets.all(24),
      showInnerGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.violetGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flag, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Notre Mission',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Myks Radio a été créée avec une passion pour la musique et le désir de '
            'partager des découvertes musicales avec le monde entier. Notre mission '
            'est de vous offrir une expérience d\'écoute unique, avec une programmation '
            'variée et de qualité, accessible 24 heures sur 24.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      _Feature(
        icon: Icons.music_note,
        title: 'Programmation Variée',
        description: 'Une sélection musicale éclectique pour tous les goûts',
        color: AppColors.primaryLight,
      ),
      _Feature(
        icon: Icons.headphones,
        title: 'Qualité Audio',
        description: 'Streaming haute qualité pour une expérience optimale',
        color: AppColors.secondary,
      ),
      _Feature(
        icon: Icons.bolt,
        title: 'Streaming 24/7',
        description: 'Disponible à tout moment, où que vous soyez',
        color: AppColors.tertiary,
      ),
      _Feature(
        icon: Icons.favorite,
        title: 'Communauté',
        description: 'Rejoignez une communauté de passionnés de musique',
        color: AppColors.live,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(feature)
            .animate(delay: Duration(milliseconds: 100 * index))
            .fadeIn()
            .scale(begin: const Offset(0.9, 0.9));
      },
    );
  }

  Widget _buildFeatureCard(_Feature feature) {
    return LiquidGlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.violetGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(feature.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            feature.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              feature.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    return LiquidGlassContainer(
      padding: const EdgeInsets.all(24),
      showInnerGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suivez-nous',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: Icons.facebook,
                label: 'Facebook',
                url: AppConstants.facebookUrl,
                color: const Color(0xFF1877F2),
              ),
              _buildSocialButton(
                icon: Icons.camera_alt,
                label: 'Instagram',
                url: AppConstants.instagramUrl,
                color: const Color(0xFFE4405F),
              ),
              _buildSocialButton(
                icon: Icons.alternate_email,
                label: 'Twitter',
                url: AppConstants.twitterUrl,
                color: const Color(0xFF1DA1F2),
              ),
              _buildSocialButton(
                icon: Icons.play_circle,
                label: 'YouTube',
                url: AppConstants.youtubeUrl,
                color: const Color(0xFFFF0000),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => _launchUrl(url),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return LiquidGlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '${AppConstants.appName} v${AppConstants.appVersion}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2024 Myks Radio. Tous droits réservés.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Développé avec ❤️ en Flutter',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
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

class _Feature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _Feature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
