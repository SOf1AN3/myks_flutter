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
  String get currentTitle => _metadata?.title ?? 'Myks Radio';
  String get currentArtist => _metadata?.artist ?? 'En attente...';
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

    // Subscribe to audio service streams
    _stateSubscription = _audioService.stateStream.listen((state) {
      _playerState = state;
      _error = null;

      if (state == RadioPlayerState.playing) {
        _icecastService.startPolling(_streamUrl);
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
      _error = error;
      notifyListeners();
    });

    // Subscribe to metadata updates
    _metadataSubscription = _icecastService.metadataStream.listen((metadata) {
      _metadata = metadata;
      _history = metadata.history;
      _storage.cacheTrackHistory(_history);
      notifyListeners();
    });
  }

  /// Play the radio
  Future<void> play() async {
    _error = null;
    notifyListeners();
    await _audioService.play();
  }

  /// Pause the radio
  Future<void> pause() async {
    await _audioService.pause();
  }

  /// Stop the radio
  Future<void> stop() async {
    await _audioService.stop();
    _icecastService.stopPolling();
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

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _volumeSubscription?.cancel();
    _errorSubscription?.cancel();
    _metadataSubscription?.cancel();
    super.dispose();
  }
}
