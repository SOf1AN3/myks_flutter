import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../config/constants.dart';

/// Audio player states
enum RadioPlayerState { idle, loading, playing, paused, error, buffering }

/// Service for audio playback
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  late final AudioPlayer _player;
  String _streamUrl = AppConstants.defaultStreamUrl;

  // Reconnection logic
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _shouldAutoReconnect = true;

  // State controllers
  final _stateController = StreamController<RadioPlayerState>.broadcast();
  final _volumeController = StreamController<double>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Streams
  Stream<RadioPlayerState> get stateStream => _stateController.stream;
  Stream<double> get volumeStream => _volumeController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Current state
  RadioPlayerState _currentState = RadioPlayerState.idle;
  RadioPlayerState get currentState => _currentState;

  double _volume = AppConstants.defaultVolume;
  double get volume => _volume;

  bool get isPlaying => _currentState == RadioPlayerState.playing;
  bool get isLoading =>
      _currentState == RadioPlayerState.loading ||
      _currentState == RadioPlayerState.buffering;

  AudioPlayerService._internal() {
    _player = AudioPlayer();
    _initAudioSession();
    _setupPlayerListeners();
  }

  /// Initialize audio session for background playback
  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ),
    );

    // Listen for audio session interruptions
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // Lower volume temporarily
            _player.setVolume(_volume * 0.5);
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            pause();
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            // Restore volume
            _player.setVolume(_volume);
            break;
          case AudioInterruptionType.pause:
            // Could auto-resume here if desired
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });

    // Handle audio becoming noisy (headphones unplugged)
    session.becomingNoisyEventStream.listen((_) {
      pause();
    });
  }

  /// Setup player event listeners
  void _setupPlayerListeners() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.loading) {
        _updateState(RadioPlayerState.loading);
      } else if (state.processingState == ProcessingState.buffering) {
        _updateState(RadioPlayerState.buffering);
      } else if (state.processingState == ProcessingState.ready) {
        if (state.playing) {
          _updateState(RadioPlayerState.playing);
          _reconnectAttempts = 0;
        } else {
          _updateState(RadioPlayerState.paused);
        }
      } else if (state.processingState == ProcessingState.completed) {
        // Stream ended, try to reconnect
        _attemptReconnect();
      } else if (state.processingState == ProcessingState.idle) {
        _updateState(RadioPlayerState.idle);
      }
    });

    _player.playbackEventStream.listen(
      (_) {},
      onError: (error, stackTrace) {
        _handleError(error.toString());
      },
    );
  }

  /// Update state and notify listeners
  void _updateState(RadioPlayerState state) {
    _currentState = state;
    _stateController.add(state);
  }

  /// Set stream URL
  void setStreamUrl(String url) {
    _streamUrl = url;
  }

  /// Play the radio stream
  Future<void> play() async {
    try {
      _shouldAutoReconnect = true;
      _updateState(RadioPlayerState.loading);

      await _player.setUrl(_streamUrl);
      await _player.play();
    } catch (e) {
      _handleError(e.toString());
      _attemptReconnect();
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _player.pause();
      _updateState(RadioPlayerState.paused);
    } catch (e) {
      _handleError(e.toString());
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      _shouldAutoReconnect = false;
      _reconnectTimer?.cancel();
      await _player.stop();
      _updateState(RadioPlayerState.idle);
    } catch (e) {
      _handleError(e.toString());
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
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    _volumeController.add(_volume);
  }

  /// Handle playback error
  void _handleError(String error) {
    _updateState(RadioPlayerState.error);
    _errorController.add(error);
  }

  /// Attempt to reconnect after error or disconnect
  void _attemptReconnect() {
    if (!_shouldAutoReconnect) return;
    if (_reconnectAttempts >= AppConstants.maxReconnectAttempts) {
      _errorController.add('Unable to connect after multiple attempts');
      return;
    }

    _reconnectAttempts++;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(AppConstants.reconnectDelay, () {
      play();
    });
  }

  /// Dispose resources
  void dispose() {
    _reconnectTimer?.cancel();
    _player.dispose();
    _stateController.close();
    _volumeController.close();
    _errorController.close();
  }
}
