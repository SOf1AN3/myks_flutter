import 'dart:async';
import 'package:dio/dio.dart';
import '../models/radio_metadata.dart';
import '../models/track.dart';
import '../config/constants.dart';

/// Service for fetching Icecast stream metadata
class IcecastService {
  static final IcecastService _instance = IcecastService._internal();
  factory IcecastService() => _instance;

  late final Dio _dio;
  Timer? _refreshTimer;
  bool _isPaused = false;
  CancelToken? _metadataRequestToken;

  final _metadataController = StreamController<RadioMetadata>.broadcast();
  Stream<RadioMetadata> get metadataStream => _metadataController.stream;

  RadioMetadata? _lastMetadata;
  RadioMetadata? get lastMetadata => _lastMetadata;

  final List<Track> _history = [];
  List<Track> get history => List.unmodifiable(_history);

  // Debouncing for disk writes
  Timer? _historyUpdateTimer;
  bool _historyNeedsUpdate = false;

  IcecastService._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
  }

  /// Start polling for metadata
  void startPolling(String streamUrl) {
    stopPolling();
    _isPaused = false;

    // Fetch immediately
    fetchMetadata(streamUrl);

    // Then poll at regular intervals
    _refreshTimer = Timer.periodic(AppConstants.metadataRefreshInterval, (_) {
      if (!_isPaused) {
        fetchMetadata(streamUrl);
      }
    });
  }

  /// Stop polling for metadata
  void stopPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isPaused = false;

    // Cancel any ongoing metadata request
    _metadataRequestToken?.cancel('Polling stopped');
    _metadataRequestToken = null;
  }

  /// Pause polling (timer keeps running but requests are skipped)
  void pausePolling() {
    _isPaused = true;

    // Cancel any ongoing metadata request
    _metadataRequestToken?.cancel('Polling paused');
    _metadataRequestToken = null;
  }

  /// Resume polling
  void resumePolling(String streamUrl) {
    if (_isPaused) {
      _isPaused = false;

      // If timer is not running, start it
      if (_refreshTimer == null || !_refreshTimer!.isActive) {
        startPolling(streamUrl);
      } else {
        // If timer is running, just fetch immediately
        fetchMetadata(streamUrl);
      }
    }
  }

  /// Fetch metadata from Icecast server
  Future<RadioMetadata?> fetchMetadata(String streamUrl) async {
    // Skip if paused
    if (_isPaused) {
      return _lastMetadata;
    }

    // Cancel previous request if still running
    _metadataRequestToken?.cancel('New request started');
    _metadataRequestToken = CancelToken();

    try {
      // Try status-json.xsl first
      final metadata = await _fetchFromStatusJson(streamUrl);
      if (metadata != null) {
        _updateMetadata(metadata);
        _metadataRequestToken = null;
        return metadata;
      }

      // Fallback to ICY headers
      final icyMetadata = await _fetchFromIcyHeaders(streamUrl);
      if (icyMetadata != null) {
        _updateMetadata(icyMetadata);
        _metadataRequestToken = null;
        return icyMetadata;
      }

      _metadataRequestToken = null;
      return null;
    } catch (e) {
      _metadataRequestToken = null;
      // Return last known metadata on error
      return _lastMetadata;
    }
  }

  /// Fetch from Icecast status-json.xsl endpoint
  Future<RadioMetadata?> _fetchFromStatusJson(String streamUrl) async {
    try {
      // Extract base URL from stream URL
      final uri = Uri.parse(streamUrl);
      final statusUrl =
          '${uri.scheme}://${uri.host}:${uri.port}/status-json.xsl';

      final response = await _dio.get(
        statusUrl,
        cancelToken: _metadataRequestToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        return RadioMetadata.fromIcecast(response.data);
      }
    } catch (e) {
      // Status JSON not available, try fallback
    }
    return null;
  }

  /// Fetch from ICY headers (fallback method)
  Future<RadioMetadata?> _fetchFromIcyHeaders(String streamUrl) async {
    try {
      final response = await _dio.head(
        streamUrl,
        options: Options(
          headers: {'Icy-MetaData': '1'},
          validateStatus: (status) => status != null && status < 400,
        ),
        cancelToken: _metadataRequestToken,
      );

      final headers = response.headers;

      String? title;
      String? rawTitle = headers.value('icy-name') ?? headers.value('ice-name');

      // Try to get current song from different headers
      final icyTitle = headers.value('icy-title');
      if (icyTitle != null && icyTitle.isNotEmpty) {
        rawTitle = icyTitle;
      }

      String? artist;
      if (rawTitle != null && rawTitle.contains(' - ')) {
        final parts = rawTitle.split(' - ');
        artist = parts[0].trim();
        title = parts.sublist(1).join(' - ').trim();
      } else {
        title = rawTitle;
      }

      return RadioMetadata(
        title: title,
        artist: artist,
        genre: headers.value('icy-genre') ?? headers.value('ice-genre'),
        bitrate: headers.value('icy-br') ?? headers.value('ice-bitrate'),
        serverName: headers.value('icy-name') ?? headers.value('ice-name'),
        serverDescription:
            headers.value('icy-description') ??
            headers.value('ice-description'),
        contentType: headers.value('content-type'),
        isLive: true,
      );
    } catch (e) {
      return null;
    }
  }

  /// Update metadata and track history
  void _updateMetadata(RadioMetadata metadata) {
    // Check if track changed
    final currentTrack = metadata.currentTrack;
    if (currentTrack != null && _lastMetadata?.currentTrack != currentTrack) {
      // Add previous track to history
      if (_lastMetadata?.currentTrack != null) {
        _addToHistory(_lastMetadata!.currentTrack!);
      }
    }

    _lastMetadata = metadata.copyWith(history: _history);
    _metadataController.add(_lastMetadata!);
  }

  /// Add track to history
  void _addToHistory(Track track) {
    // Avoid duplicates at the top
    if (_history.isNotEmpty && _history.first == track) {
      return;
    }

    _history.insert(0, track);

    // OPTIMIZED: Reduced from 50 to 25 to minimize memory usage
    if (_history.length > 25) {
      _history.removeLast();
    }

    // OPTIMIZED: Mark that history needs update instead of writing immediately
    _markHistoryForUpdate();
  }

  /// Mark history for batched disk write (debounced)
  void _markHistoryForUpdate() {
    _historyNeedsUpdate = true;
    _historyUpdateTimer?.cancel();

    // OPTIMIZED: Debounce disk writes - only write after 5 seconds of no updates
    _historyUpdateTimer = Timer(
      const Duration(seconds: 5),
      _flushHistoryUpdate,
    );
  }

  /// Flush pending history updates to disk
  void _flushHistoryUpdate() {
    if (_historyNeedsUpdate && _historyUpdateCallback != null) {
      _historyUpdateCallback!(_history);
      _historyNeedsUpdate = false;
    }
  }

  // Callback for notifying about history updates (set by RadioProvider)
  void Function(List<Track>)? _historyUpdateCallback;

  /// Set callback for history updates
  void setHistoryUpdateCallback(void Function(List<Track>) callback) {
    _historyUpdateCallback = callback;
  }

  /// Clear history
  void clearHistory() {
    _history.clear();
    if (_lastMetadata != null) {
      _lastMetadata = _lastMetadata!.copyWith(history: []);
      _metadataController.add(_lastMetadata!);
    }
  }

  /// Test if stream URL is valid and reachable
  Future<bool> testStreamUrl(String streamUrl) async {
    try {
      final testToken = CancelToken();
      final response = await _dio.head(
        streamUrl,
        options: Options(
          validateStatus: (status) => status != null && status < 400,
        ),
        cancelToken: testToken,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    stopPolling();
    _historyUpdateTimer?.cancel();

    // Cancel any ongoing requests
    _metadataRequestToken?.cancel('Service disposed');
    _metadataRequestToken = null;

    // Flush any pending updates before disposing
    _flushHistoryUpdate();

    _metadataController.close();
  }
}
