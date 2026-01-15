import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Service pour extraire les streams vidéo YouTube
class YouTubeService {
  static final YouTubeService _instance = YouTubeService._internal();
  factory YouTubeService() => _instance;
  YouTubeService._internal();

  final _yt = YoutubeExplode();
  final _cache = <String, _CachedStreamUrl>{};

  /// Obtenir l'URL du stream vidéo
  ///
  /// Extrait l'URL du stream vidéo depuis YouTube et la met en cache.
  /// La qualité par défaut est medium (720p max) pour optimiser les performances.
  Future<String> getStreamUrl(
    String videoId, {
    StreamQuality quality = StreamQuality.medium,
  }) async {
    try {
      // Vérifier le cache
      if (_cache.containsKey(videoId)) {
        final cached = _cache[videoId]!;
        if (!cached.isExpired) {
          debugPrint('YouTubeService: Using cached URL for $videoId');
          return cached.url;
        } else {
          debugPrint('YouTubeService: Cache expired for $videoId');
          _cache.remove(videoId);
        }
      }

      debugPrint('YouTubeService: Fetching stream URL for $videoId');

      // Extraire le manifest
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Choisir le stream selon la qualité demandée
      MuxedStreamInfo streamInfo;

      // Obtenir tous les streams muxed (vidéo + audio)
      final muxedStreams = manifest.muxed.toList();

      if (muxedStreams.isEmpty) {
        throw Exception('No muxed streams available for video $videoId');
      }

      // Trier par qualité (du plus haut au plus bas)
      muxedStreams.sort((a, b) => b.qualityLabel.compareTo(a.qualityLabel));

      switch (quality) {
        case StreamQuality.high:
          // Chercher 1080p ou 720p
          streamInfo = muxedStreams.firstWhere(
            (s) =>
                s.qualityLabel.contains('1080') ||
                s.qualityLabel.contains('720'),
            orElse: () => muxedStreams.first,
          );
          break;

        case StreamQuality.medium:
          // Chercher 720p ou 480p (optimal pour performance)
          streamInfo = muxedStreams.firstWhere(
            (s) =>
                s.qualityLabel.contains('720') ||
                s.qualityLabel.contains('480'),
            orElse: () => muxedStreams.first,
          );
          break;

        case StreamQuality.low:
          // Chercher 360p ou moins
          streamInfo = muxedStreams.firstWhere(
            (s) =>
                s.qualityLabel.contains('360') ||
                s.qualityLabel.contains('240'),
            orElse: () => muxedStreams.last,
          );
          break;
      }

      final url = streamInfo.url.toString();

      // Mettre en cache (TTL: 6 heures)
      _cache[videoId] = _CachedStreamUrl(
        url: url,
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
      );

      debugPrint(
        'YouTubeService: Stream URL obtained for $videoId (${streamInfo.qualityLabel})',
      );

      return url;
    } catch (e) {
      debugPrint('YouTubeService: Error fetching stream URL: $e');
      rethrow;
    }
  }

  /// Obtenir les informations de la vidéo
  Future<VideoInfo> getVideoInfo(String videoId) async {
    try {
      debugPrint('YouTubeService: Fetching video info for $videoId');

      final video = await _yt.videos.get(videoId);

      return VideoInfo(
        id: video.id.value,
        title: video.title,
        author: video.author,
        duration: video.duration,
        thumbnailUrl: video.thumbnails.highResUrl,
        description: video.description,
      );
    } catch (e) {
      debugPrint('YouTubeService: Error fetching video info: $e');
      rethrow;
    }
  }

  /// Vider le cache
  void clearCache() {
    debugPrint('YouTubeService: Clearing cache');
    _cache.clear();
  }

  /// Fermer le service et libérer les ressources
  void dispose() {
    debugPrint('YouTubeService: Disposing');
    _yt.close();
    _cache.clear();
  }
}

/// Qualité du stream vidéo
enum StreamQuality {
  low, // 360p ou moins
  medium, // 720p ou moins (recommandé)
  high, // 1080p ou moins
}

/// URL de stream en cache
class _CachedStreamUrl {
  final String url;
  final DateTime expiresAt;

  _CachedStreamUrl({required this.url, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Informations de la vidéo YouTube
class VideoInfo {
  final String id;
  final String title;
  final String author;
  final Duration? duration;
  final String thumbnailUrl;
  final String description;

  VideoInfo({
    required this.id,
    required this.title,
    required this.author,
    this.duration,
    required this.thumbnailUrl,
    required this.description,
  });

  String get durationFormatted {
    if (duration == null) return '00:00';
    final minutes = duration!.inMinutes;
    final seconds = duration!.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
