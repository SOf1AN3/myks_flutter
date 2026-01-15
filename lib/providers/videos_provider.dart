import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/video.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/constants.dart';

/// Provider for videos state management
class VideosProvider extends ChangeNotifier {
  final ApiService _api;
  final StorageService _storage;

  // Debouncing for search
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 500);

  // State
  List<Video> _videos = [];
  List<Video> get videos => _videos;

  List<Video> _filteredVideos = [];
  List<Video> get filteredVideos => _filteredVideos;

  Video? _featuredVideo;
  Video? get featuredVideo => _featuredVideo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isUsingCache = false;
  bool get isUsingCache => _isUsingCache;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // Cached computed values to avoid recalculation on every access
  List<Video>? _cachedPageVideos;
  int? _cachedPage;
  int? _cachedFilteredLength;

  int get totalVideos => _filteredVideos.length;
  int get totalPages => (totalVideos / AppConstants.videosPerPage).ceil();

  List<Video> get currentPageVideos {
    // Return cached result if page and filtered videos haven't changed
    if (_cachedPage == _currentPage &&
        _cachedFilteredLength == _filteredVideos.length &&
        _cachedPageVideos != null) {
      return _cachedPageVideos!;
    }

    // Compute and cache
    final startIndex = (_currentPage - 1) * AppConstants.videosPerPage;
    final endIndex = startIndex + AppConstants.videosPerPage;

    if (startIndex >= _filteredVideos.length) {
      _cachedPageVideos = const [];
    } else {
      _cachedPageVideos = _filteredVideos.sublist(
        startIndex,
        endIndex > _filteredVideos.length ? _filteredVideos.length : endIndex,
      );
    }

    _cachedPage = _currentPage;
    _cachedFilteredLength = _filteredVideos.length;
    return _cachedPageVideos!;
  }

  /// Invalidate the page cache when filtered videos or page changes
  void _invalidatePageCache() {
    _cachedPageVideos = null;
    _cachedPage = null;
    _cachedFilteredLength = null;
  }

  VideosProvider({required ApiService api, required StorageService storage})
    : _api = api,
      _storage = storage {
    _loadCachedData();
  }

  /// Load cached data on init
  void _loadCachedData() {
    final cachedVideos = _storage.getCachedVideos();
    if (cachedVideos != null) {
      _videos = cachedVideos;
      _filteredVideos = cachedVideos;
    }

    final cachedFeatured = _storage.getCachedFeaturedVideo();
    if (cachedFeatured != null) {
      _featuredVideo = cachedFeatured;
    }

    notifyListeners();
  }

  /// Fetch all videos from API
  Future<void> fetchVideos({bool forceRefresh = false}) async {
    if (_isLoading) return;

    // Use cache if available and not forcing refresh
    if (!forceRefresh && _videos.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _error = null;
    _isUsingCache = false;
    notifyListeners();

    try {
      final videos = await _api.getVideos();
      _videos = videos;
      _applySearch();
      await _storage.cacheVideos(videos);

      // Batch state updates with single notification
      _isLoading = false;
      _isUsingCache = false;
      notifyListeners();
    } catch (e) {
      _error = _getUserFriendlyErrorMessage(e.toString());

      // Fall back to cached data
      final cached = _storage.getCachedVideos(
        maxAge: const Duration(hours: 24),
      );
      if (cached != null && cached.isNotEmpty) {
        _videos = cached;
        _applySearch();
        _isUsingCache = true;
        // Update error message to indicate using cache
        _error = 'Mode hors ligne : affichage des vidéos en cache';
      } else {
        // No cache available
        _error =
            'Impossible de charger les vidéos. ${_getUserFriendlyErrorMessage(e.toString())}';
      }

      // Batch state updates with single notification
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch featured video from API
  Future<void> fetchFeaturedVideo({bool forceRefresh = false}) async {
    if (!forceRefresh && _featuredVideo != null) {
      return;
    }

    try {
      final video = await _api.getFeaturedVideo();
      _featuredVideo = video;
      await _storage.cacheFeaturedVideo(video);
      notifyListeners();
    } catch (e) {
      // Fall back to cached data
      final cached = _storage.getCachedFeaturedVideo(
        maxAge: const Duration(hours: 24),
      );
      if (cached != null) {
        _featuredVideo = cached;
        _isUsingCache = true;
        notifyListeners();
      }
      // Don't show error for featured video, it's optional
    }
  }

  /// Search videos by query with debouncing
  void search(String query) {
    final trimmedQuery = query.toLowerCase().trim();

    // Cancel previous timer if it exists
    _debounceTimer?.cancel();

    // Only debounce if query is not empty (immediate response when clearing)
    if (trimmedQuery.isEmpty) {
      _searchQuery = trimmedQuery;
      _currentPage = 1;
      _applySearch();
      notifyListeners();
      return;
    }

    // Debounce for non-empty queries to avoid notifications on every keystroke
    _debounceTimer = Timer(_debounceDuration, () {
      _searchQuery = trimmedQuery;
      _currentPage = 1;
      _applySearch();
      notifyListeners();
    });
  }

  /// Apply current search filter
  void _applySearch() {
    if (_searchQuery.isEmpty) {
      // OPTIMIZED: Reference same list instead of copying
      _filteredVideos = _videos;
    } else {
      // OPTIMIZED: Direct filtering without intermediate copies
      _filteredVideos = _videos.where((video) {
        return video.title.toLowerCase().contains(_searchQuery) ||
            video.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    _hasMore = _filteredVideos.length > AppConstants.videosPerPage;
    _invalidatePageCache();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _currentPage = 1;
    // OPTIMIZED: Reference same list instead of copying
    _filteredVideos = _videos;
    _invalidatePageCache();
    notifyListeners();
  }

  /// Go to page
  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    _invalidatePageCache();
    notifyListeners();
  }

  /// Next page
  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      _invalidatePageCache();
      notifyListeners();
    }
  }

  /// Previous page
  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      _invalidatePageCache();
      notifyListeners();
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      fetchVideos(forceRefresh: true),
      fetchFeaturedVideo(forceRefresh: true),
    ]);
  }

  /// Get video by ID
  Video? getVideoById(String id) {
    try {
      return _videos.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get video by YouTube ID
  Video? getVideoByYoutubeId(String youtubeId) {
    try {
      return _videos.firstWhere((v) => v.youtubeId == youtubeId);
    } catch (e) {
      return null;
    }
  }

  /// Convert technical error messages to user-friendly French messages
  String _getUserFriendlyErrorMessage(String error) {
    final lowerError = error.toLowerCase();

    // Network-related errors
    if (lowerError.contains('connexion internet') ||
        lowerError.contains('aucune connexion') ||
        lowerError.contains('no internet') ||
        lowerError.contains('connection error')) {
      return 'Aucune connexion internet disponible.';
    }

    // Timeout errors
    if (lowerError.contains('délai') || lowerError.contains('timeout')) {
      return 'Le serveur met trop de temps à répondre.';
    }

    // Server errors
    if (lowerError.contains('serveur') ||
        lowerError.contains('server') ||
        lowerError.contains('503') ||
        lowerError.contains('500')) {
      return 'Le serveur est temporairement indisponible.';
    }

    // Not found errors
    if (lowerError.contains('non trouvée') ||
        lowerError.contains('not found') ||
        lowerError.contains('404')) {
      return 'Ressource non disponible.';
    }

    // Default message for API errors
    return 'Impossible de se connecter au serveur.';
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
