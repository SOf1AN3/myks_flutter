import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../providers/videos_provider.dart';
import '../../providers/radio_provider.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/mini_player.dart';
import 'widgets/video_card.dart';
import 'widgets/video_player_modal.dart';

/// Videos screen with grid of YouTube videos
class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final videosProvider = context.read<VideosProvider>();
    await videosProvider.fetchVideos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videosProvider = context.watch<VideosProvider>();
    final radioProvider = context.watch<RadioProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showMiniPlayer = radioProvider.isPlaying || radioProvider.isPaused;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Vidéos'),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => videosProvider.refresh(),
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader(isDark)),

                // Search bar
                SliverToBoxAdapter(
                  child: _buildSearchBar(videosProvider, isDark),
                ),

                // Results count
                SliverToBoxAdapter(
                  child: _buildResultsCount(videosProvider, isDark),
                ),

                // Video grid or loading/error state
                if (videosProvider.isLoading)
                  _buildLoadingGrid()
                else if (videosProvider.error != null)
                  SliverToBoxAdapter(
                    child: _buildError(videosProvider.error!, isDark),
                  )
                else if (videosProvider.filteredVideos.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState(isDark))
                else
                  _buildVideoGrid(videosProvider),

                // Pagination
                if (videosProvider.totalPages > 1)
                  SliverToBoxAdapter(
                    child: _buildPagination(videosProvider, isDark),
                  ),

                // Bottom padding for mini player
                SliverToBoxAdapter(
                  child: SizedBox(height: showMiniPlayer ? 100 : 20),
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
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.play_circle_filled,
              color: Colors.red,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vidéos YouTube',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkForeground
                        : AppColors.lightForeground,
                  ),
                ),
                Text(
                  'Découvrez notre contenu vidéo',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkMutedForeground
                        : AppColors.lightMutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildSearchBar(VideosProvider videosProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher une vidéo...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    videosProvider.clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryLight),
          ),
          filled: true,
          fillColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
        onChanged: (value) => videosProvider.search(value),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 100));
  }

  Widget _buildResultsCount(VideosProvider videosProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        '${videosProvider.totalVideos} vidéo${videosProvider.totalVideos > 1 ? 's' : ''} trouvée${videosProvider.totalVideos > 1 ? 's' : ''}',
        style: TextStyle(
          fontSize: 14,
          color: isDark
              ? AppColors.darkMutedForeground
              : AppColors.lightMutedForeground,
        ),
      ),
    );
  }

  Widget _buildVideoGrid(VideosProvider videosProvider) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final video = videosProvider.currentPageVideos[index];

          return VideoCard(
                video: video,
                onTap: () => VideoPlayerBottomSheet.show(context, video),
              )
              .animate(delay: Duration(milliseconds: index * 50))
              .fadeIn()
              .scale(begin: const Offset(0.95, 0.95));
        }, childCount: videosProvider.currentPageVideos.length),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const VideoCardShimmer(),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildError(String error, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkForeground
                  : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            onPressed: _loadVideos,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: isDark
                ? AppColors.darkMutedForeground
                : AppColors.lightMutedForeground,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune vidéo trouvée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkForeground
                  : AppColors.lightForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier votre recherche',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkMutedForeground
                  : AppColors.lightMutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(VideosProvider videosProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: videosProvider.currentPage > 1
                ? () => videosProvider.previousPage()
                : null,
          ),
          const SizedBox(width: 16),
          ...List.generate(
            videosProvider.totalPages,
            (index) => _buildPageButton(index + 1, videosProvider, isDark),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: videosProvider.currentPage < videosProvider.totalPages
                ? () => videosProvider.nextPage()
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(
    int page,
    VideosProvider videosProvider,
    bool isDark,
  ) {
    final isActive = page == videosProvider.currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => videosProvider.goToPage(page),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryLight
                : (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$page',
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (isDark
                          ? AppColors.darkForeground
                          : AppColors.lightForeground),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
