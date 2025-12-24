/// Model representing a YouTube video
class Video {
  final String id;
  final String youtubeId;
  final String title;
  final String description;
  final bool isFeatured;
  final DateTime? createdAt;

  Video({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.description,
    this.isFeatured = false,
    this.createdAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id']?.toString() ?? '',
      youtubeId:
          json['youtubeId'] ??
          json['youtube_id'] ??
          _extractYoutubeId(json['url'] ?? ''),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isFeatured: json['isFeatured'] ?? json['is_featured'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : (json['created_at'] != null
                ? DateTime.tryParse(json['created_at'])
                : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'youtubeId': youtubeId,
      'title': title,
      'description': description,
      'isFeatured': isFeatured,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Get YouTube thumbnail URL
  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';

  /// Get high quality thumbnail
  String get thumbnailUrlHQ =>
      'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg';

  /// Get standard quality thumbnail
  String get thumbnailUrlSQ =>
      'https://img.youtube.com/vi/$youtubeId/sddefault.jpg';

  /// Get YouTube embed URL
  String get embedUrl =>
      'https://www.youtube.com/embed/$youtubeId?autoplay=1&rel=0';

  /// Get YouTube watch URL
  String get watchUrl => 'https://www.youtube.com/watch?v=$youtubeId';

  /// Extract YouTube ID from various URL formats
  static String _extractYoutubeId(String url) {
    if (url.isEmpty) return '';

    // Already just an ID
    if (!url.contains('/') && !url.contains('.')) {
      return url;
    }

    // youtube.com/watch?v=ID
    final watchRegex = RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})');
    final watchMatch = watchRegex.firstMatch(url);
    if (watchMatch != null) {
      return watchMatch.group(1) ?? '';
    }

    // youtu.be/ID
    final shortRegex = RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})');
    final shortMatch = shortRegex.firstMatch(url);
    if (shortMatch != null) {
      return shortMatch.group(1) ?? '';
    }

    // youtube.com/embed/ID
    final embedRegex = RegExp(r'youtube\.com/embed/([a-zA-Z0-9_-]{11})');
    final embedMatch = embedRegex.firstMatch(url);
    if (embedMatch != null) {
      return embedMatch.group(1) ?? '';
    }

    return '';
  }

  /// Create from YouTube URL
  factory Video.fromUrl({
    required String url,
    required String title,
    String description = '',
    bool isFeatured = false,
  }) {
    return Video(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      youtubeId: _extractYoutubeId(url),
      title: title,
      description: description,
      isFeatured: isFeatured,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() => 'Video(id: $id, title: $title, youtubeId: $youtubeId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Video && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
