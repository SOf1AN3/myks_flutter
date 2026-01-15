import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/radio_metadata.dart';
import '../models/track.dart';
import '../models/radio_config.dart';
import '../services/audio_player_service.dart';
import '../services/icecast_service.dart';
import '../services/storage_service.dart';
import '../config/constants.dart';

/// Provider for radio state management
class RadioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  final IcecastService _icecastService;
  final StorageService _storage;

  // Subscriptions
  StreamSubscription? _stateSubscription;
  StreamSubscription? _volumeSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _metadataSubscription;

  // State
  RadioPlayerState _playerState = RadioPlayerState.idle;
  RadioPlayerState get playerState => _playerState;

  double _volume = AppConstants.defaultVolume;
  double get volume => _volume;

  RadioMetadata? _metadata;
  RadioMetadata? get metadata => _metadata;

  String? _error;
  String? get error => _error;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  String _streamUrl = AppConstants.defaultStreamUrl;
  String get streamUrl => _streamUrl;

  List<Track> _history = [];
  List<Track> get history => _history;

  // Computed properties
  bool get isPlaying => _playerState == RadioPlayerState.playing;
  bool get isLoading =>
      _playerState == RadioPlayerState.loading ||
      _playerState == RadioPlayerState.buffering;
  bool get isPaused => _playerState == RadioPlayerState.paused;
  bool get isIdle => _playerState == RadioPlayerState.idle;
  bool get hasError => _playerState == RadioPlayerState.error;
  bool get isLive => isPlaying && _metadata?.isLive == true;

  Track? get currentTrack => _metadata?.currentTrack;

  /// Get current title with fallback based on player state
  String get currentTitle {
    // If we have metadata title, use it
    if (_metadata?.title != null && _metadata!.title!.isNotEmpty) {
      return _metadata!.title!;
    }

    // Otherwise, provide context-aware fallback
    if (isPlaying) {
      return 'Myks Radio';
    } else if (isLoading) {
      return 'Connexion en cours...';
    } else {
      return 'Myks Radio';
    }
  }

  /// Get current artist with fallback based on player state
  String get currentArtist {
    // If we have metadata artist, use it
    if (_metadata?.artist != null && _metadata!.artist!.isNotEmpty) {
      return _metadata!.artist!;
    }

    // Otherwise, provide context-aware fallback
    if (isPlaying) {
      return 'En direct'; // Playing but no metadata yet
    } else if (isLoading) {
      return 'Chargement...';
    } else {
      return 'En attente...';
    }
  }

  String? get currentCover => _metadata?.coverUrl;

  RadioProvider({
    required AudioPlayerService audioService,
    required IcecastService icecastService,
    required StorageService storage,
  }) : _audioService = audioService,
       _icecastService = icecastService,
       _storage = storage {
    _init();
  }

  void _init() {
    // Load saved settings
    _volume = _storage.getVolume();
    _streamUrl = _storage.getStreamUrl();
    _history = _storage.getCachedTrackHistory();

    // Set initial values
    _audioService.setStreamUrl(_streamUrl);
    _audioService.setVolume(_volume);

    // OPTIMIZED: Set up debounced history update callback
    _icecastService.setHistoryUpdateCallback((history) {
      _storage.cacheTrackHistory(history);
    });

    // Subscribe to audio service streams
    _stateSubscription = _audioService.stateStream.listen((state) {
      _playerState = state;
      _error = null;

      // OPTIMIZED: Lifecycle-aware polling - only poll when playing
      if (state == RadioPlayerState.playing) {
        _icecastService.resumePolling(_streamUrl);
      } else if (state == RadioPlayerState.paused) {
        _icecastService.pausePolling();
      } else if (state == RadioPlayerState.idle ||
          state == RadioPlayerState.error) {
        _icecastService.stopPolling();
      }

      notifyListeners();
    });

    _volumeSubscription = _audioService.volumeStream.listen((volume) {
      _volume = volume;
      notifyListeners();
    });

    _errorSubscription = _audioService.errorStream.listen((error) {
      _error = _getUserFriendlyErrorMessage(error);
      _checkOfflineStatus(error);
      notifyListeners();
    });

    // Subscribe to metadata updates
    _metadataSubscription = _icecastService.metadataStream.listen((metadata) {
      // Only notify if metadata actually changed
      final oldTitle = _metadata?.title;
      final oldArtist = _metadata?.artist;
      final newTitle = metadata.title;
      final newArtist = metadata.artist;

      _metadata = metadata;
      _history = metadata.history;

      // OPTIMIZED: Only notify if title or artist changed (disk writes are now debounced in IcecastService)
      if (oldTitle != newTitle || oldArtist != newArtist) {
        notifyListeners();
      }
    });
  }

  /// Play the radio
  Future<void> play() async {
    _error = null;
    _isOffline = false;
    notifyListeners();

    try {
      await _audioService.play();
    } catch (e) {
      _error = _getUserFriendlyErrorMessage(e.toString());
      _checkOfflineStatus(e.toString());
      notifyListeners();
    }
  }

  /// Pause the radio
  Future<void> pause() async {
    try {
      await _audioService.pause();
    } catch (e) {
      _error = _getUserFriendlyErrorMessage(e.toString());
      notifyListeners();
    }
  }

  /// Stop the radio
  Future<void> stop() async {
    try {
      await _audioService.stop();
      _icecastService.stopPolling();
    } catch (e) {
      _error = _getUserFriendlyErrorMessage(e.toString());
      notifyListeners();
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
    await _storage.setVolume(volume);
  }

  /// Set stream URL
  Future<void> setStreamUrl(String url) async {
    _streamUrl = url;
    _audioService.setStreamUrl(url);
    await _storage.setStreamUrl(url);
    notifyListeners();
  }

  /// Test stream URL connectivity
  Future<bool> testStreamUrl(String url) async {
    return await _icecastService.testStreamUrl(url);
  }

  /// Clear playback history
  void clearHistory() {
    _icecastService.clearHistory();
    _history = [];
    _storage.cacheTrackHistory([]);
    notifyListeners();
  }

  /// Refresh metadata manually
  Future<void> refreshMetadata() async {
    await _icecastService.fetchMetadata(_streamUrl);
  }

  /// Get radio configuration
  RadioConfig get config =>
      RadioConfig(streamUrl: _streamUrl, name: AppConstants.appName);

  /// Convert technical error messages to user-friendly French messages
  String _getUserFriendlyErrorMessage(String error) {
    final lowerError = error.toLowerCase();

    // Network-related errors
    if (lowerError.contains('connection') ||
        lowerError.contains('network') ||
        lowerError.contains('connexion') ||
        lowerError.contains('réseau')) {
      return 'Impossible de se connecter. Vérifiez votre connexion internet.';
    }

    // Timeout errors
    if (lowerError.contains('timeout') || lowerError.contains('délai')) {
      return 'La connexion a pris trop de temps. Vérifiez votre connexion.';
    }

    // Stream/audio errors
    if (lowerError.contains('stream') ||
        lowerError.contains('audio') ||
        lowerError.contains('source')) {
      return 'Impossible de lire le flux audio. Le serveur est peut-être indisponible.';
    }

    // Format errors
    if (lowerError.contains('format') || lowerError.contains('decode')) {
      return 'Format audio non pris en charge.';
    }

    // Server errors
    if (lowerError.contains('server') ||
        lowerError.contains('serveur') ||
        lowerError.contains('503') ||
        lowerError.contains('500')) {
      return 'Le serveur radio est temporairement indisponible.';
    }

    // Default message
    return 'Une erreur s\'est produite lors de la lecture. Veuillez réessayer.';
  }

  /// Check if error indicates offline status
  void _checkOfflineStatus(String error) {
    final lowerError = error.toLowerCase();
    _isOffline =
        lowerError.contains('connection') ||
        lowerError.contains('network') ||
        lowerError.contains('connexion') ||
        lowerError.contains('réseau') ||
        lowerError.contains('offline') ||
        lowerError.contains('hors ligne');
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _volumeSubscription?.cancel();
    _errorSubscription?.cancel();
    _metadataSubscription?.cancel();
    super.dispose();
  }
}
