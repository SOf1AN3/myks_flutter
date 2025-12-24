import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';
import '../models/video.dart';
import '../models/track.dart';

/// Service for local storage
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  late SharedPreferences _prefs;
  late Box<String> _cacheBox;
  bool _initialized = false;

  StorageService._internal();

  /// Initialize storage
  Future<void> init() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();

    await Hive.initFlutter();
    _cacheBox = await Hive.openBox<String>('cache');

    _initialized = true;
  }

  // ==================== Preferences ====================

  /// Get saved volume
  double getVolume() {
    return _prefs.getDouble(AppConstants.keyVolume) ??
        AppConstants.defaultVolume;
  }

  /// Save volume
  Future<void> setVolume(double volume) async {
    await _prefs.setDouble(AppConstants.keyVolume, volume);
  }

  /// Get saved theme mode (light, dark, system)
  String getThemeMode() {
    return _prefs.getString(AppConstants.keyThemeMode) ?? 'system';
  }

  /// Save theme mode
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(AppConstants.keyThemeMode, mode);
  }

  /// Get saved stream URL
  String getStreamUrl() {
    return _prefs.getString(AppConstants.keyStreamUrl) ??
        AppConstants.defaultStreamUrl;
  }

  /// Save stream URL
  Future<void> setStreamUrl(String url) async {
    await _prefs.setString(AppConstants.keyStreamUrl, url);
  }

  // ==================== Cache ====================

  /// Cache videos list
  Future<void> cacheVideos(List<Video> videos) async {
    final json = jsonEncode(videos.map((v) => v.toJson()).toList());
    await _cacheBox.put('videos', json);
    await _cacheBox.put('videos_timestamp', DateTime.now().toIso8601String());
  }

  /// Get cached videos
  List<Video>? getCachedVideos({Duration maxAge = const Duration(minutes: 2)}) {
    final json = _cacheBox.get('videos');
    final timestampStr = _cacheBox.get('videos_timestamp');

    if (json == null || timestampStr == null) return null;

    final timestamp = DateTime.tryParse(timestampStr);
    if (timestamp == null) return null;

    // Check if cache is expired
    if (DateTime.now().difference(timestamp) > maxAge) {
      return null;
    }

    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((item) => Video.fromJson(item)).toList();
    } catch (e) {
      return null;
    }
  }

  /// Cache featured video
  Future<void> cacheFeaturedVideo(Video? video) async {
    if (video == null) {
      await _cacheBox.delete('featured_video');
    } else {
      await _cacheBox.put('featured_video', jsonEncode(video.toJson()));
    }
    await _cacheBox.put(
      'featured_video_timestamp',
      DateTime.now().toIso8601String(),
    );
  }

  /// Get cached featured video
  Video? getCachedFeaturedVideo({
    Duration maxAge = const Duration(minutes: 2),
  }) {
    final json = _cacheBox.get('featured_video');
    final timestampStr = _cacheBox.get('featured_video_timestamp');

    if (json == null || timestampStr == null) return null;

    final timestamp = DateTime.tryParse(timestampStr);
    if (timestamp == null) return null;

    if (DateTime.now().difference(timestamp) > maxAge) {
      return null;
    }

    try {
      return Video.fromJson(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }

  /// Cache track history
  Future<void> cacheTrackHistory(List<Track> history) async {
    final json = jsonEncode(history.map((t) => t.toJson()).toList());
    await _cacheBox.put('track_history', json);
  }

  /// Get cached track history
  List<Track> getCachedTrackHistory() {
    final json = _cacheBox.get('track_history');
    if (json == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.map((item) => Track.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  /// Clear all data (preferences + cache)
  Future<void> clearAll() async {
    await _prefs.clear();
    await _cacheBox.clear();
  }
}
