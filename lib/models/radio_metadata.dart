import 'track.dart';

/// Model representing radio stream metadata
class RadioMetadata {
  final String? title;
  final String? artist;
  final String? album;
  final String? coverUrl;
  final String? bitrate;
  final int? listeners;
  final String? genre;
  final bool isLive;
  final String? djName;
  final String? serverName;
  final String? serverDescription;
  final String? contentType;
  final List<Track> history;

  RadioMetadata({
    this.title,
    this.artist,
    this.album,
    this.coverUrl,
    this.bitrate,
    this.listeners,
    this.genre,
    this.isLive = false,
    this.djName,
    this.serverName,
    this.serverDescription,
    this.contentType,
    this.history = const [],
  });

  factory RadioMetadata.fromJson(Map<String, dynamic> json) {
    List<Track> historyList = [];
    if (json['history'] != null && json['history'] is List) {
      historyList = (json['history'] as List)
          .map((item) => Track.fromJson(item))
          .toList();
    }

    return RadioMetadata(
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      coverUrl: json['coverUrl'] ?? json['cover_url'],
      bitrate: json['bitrate']?.toString(),
      listeners: json['listeners'] is int
          ? json['listeners']
          : int.tryParse(json['listeners']?.toString() ?? ''),
      genre: json['genre'],
      isLive: json['isLive'] ?? json['is_live'] ?? true,
      djName: json['djName'] ?? json['dj_name'],
      serverName: json['serverName'] ?? json['server_name'],
      serverDescription:
          json['serverDescription'] ?? json['server_description'],
      contentType: json['contentType'] ?? json['content_type'],
      history: historyList,
    );
  }

  /// Parse from Icecast status-json.xsl response
  factory RadioMetadata.fromIcecast(Map<String, dynamic> json) {
    final source = json['icestats']?['source'];
    if (source == null) {
      return RadioMetadata();
    }

    // Handle single source or array of sources
    final sourceData = source is List ? source.first : source;

    String? rawTitle = sourceData['title'];
    String? artist;
    String? title = rawTitle;

    // Parse artist from title if format is "Artist - Title"
    if (rawTitle != null && rawTitle.contains(' - ')) {
      final parts = rawTitle.split(' - ');
      artist = parts[0].trim();
      title = parts.sublist(1).join(' - ').trim();
    }

    return RadioMetadata(
      title: title,
      artist: artist,
      genre: sourceData['genre'],
      bitrate: sourceData['bitrate']?.toString(),
      listeners: sourceData['listeners'] is int
          ? sourceData['listeners']
          : int.tryParse(sourceData['listeners']?.toString() ?? ''),
      serverName: sourceData['server_name'],
      serverDescription: sourceData['server_description'],
      contentType: sourceData['server_type'],
      isLive: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'coverUrl': coverUrl,
      'bitrate': bitrate,
      'listeners': listeners,
      'genre': genre,
      'isLive': isLive,
      'djName': djName,
      'serverName': serverName,
      'serverDescription': serverDescription,
      'contentType': contentType,
      'history': history.map((t) => t.toJson()).toList(),
    };
  }

  /// Get current track from metadata
  Track? get currentTrack {
    if (title == null && artist == null) return null;
    return Track(
      title: title ?? 'Unknown',
      artist: artist,
      album: album,
      coverUrl: coverUrl,
      playedAt: DateTime.now(),
    );
  }

  /// Get display string for bitrate
  String get bitrateDisplay => bitrate != null ? '$bitrate kbps' : 'N/A';

  /// Get display string for listeners
  String get listenersDisplay => listeners?.toString() ?? '0';

  /// Get audio format from content type
  String get audioFormat {
    if (contentType == null) return 'Unknown';
    if (contentType!.contains('mpeg')) return 'MP3';
    if (contentType!.contains('ogg')) return 'OGG';
    if (contentType!.contains('aac')) return 'AAC';
    if (contentType!.contains('flac')) return 'FLAC';
    return contentType!.split('/').last.toUpperCase();
  }

  RadioMetadata copyWith({
    String? title,
    String? artist,
    String? album,
    String? coverUrl,
    String? bitrate,
    int? listeners,
    String? genre,
    bool? isLive,
    String? djName,
    String? serverName,
    String? serverDescription,
    String? contentType,
    List<Track>? history,
  }) {
    return RadioMetadata(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      coverUrl: coverUrl ?? this.coverUrl,
      bitrate: bitrate ?? this.bitrate,
      listeners: listeners ?? this.listeners,
      genre: genre ?? this.genre,
      isLive: isLive ?? this.isLive,
      djName: djName ?? this.djName,
      serverName: serverName ?? this.serverName,
      serverDescription: serverDescription ?? this.serverDescription,
      contentType: contentType ?? this.contentType,
      history: history ?? this.history,
    );
  }

  @override
  String toString() =>
      'RadioMetadata(title: $title, artist: $artist, listeners: $listeners)';
}
