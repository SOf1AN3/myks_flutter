/// Model representing a track played on the radio
class Track {
  final String? id;
  final String title;
  final String? artist;
  final String? album;
  final String? coverUrl;
  final DateTime? playedAt;

  Track({
    this.id,
    required this.title,
    this.artist,
    this.album,
    this.coverUrl,
    this.playedAt,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id']?.toString(),
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'],
      album: json['album'],
      coverUrl: json['coverUrl'] ?? json['cover_url'],
      playedAt: json['playedAt'] != null
          ? DateTime.tryParse(json['playedAt'])
          : (json['played_at'] != null
                ? DateTime.tryParse(json['played_at'])
                : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'coverUrl': coverUrl,
      'playedAt': playedAt?.toIso8601String(),
    };
  }

  /// Parse title to extract artist and track name
  /// Common formats: "Artist - Track", "Artist: Track", etc.
  static Track parseFromString(String rawTitle, {DateTime? playedAt}) {
    String? artist;
    String title = rawTitle.trim();

    // Try to split by " - "
    if (rawTitle.contains(' - ')) {
      final parts = rawTitle.split(' - ');
      if (parts.length >= 2) {
        artist = parts[0].trim();
        title = parts.sublist(1).join(' - ').trim();
      }
    }

    return Track(
      title: title,
      artist: artist,
      playedAt: playedAt ?? DateTime.now(),
    );
  }

  String get displayTitle => title.isNotEmpty ? title : 'Unknown Title';

  String get displayArtist =>
      artist?.isNotEmpty == true ? artist! : 'Unknown Artist';

  String get fullDisplay => artist != null ? '$artist - $title' : title;

  @override
  String toString() => 'Track(title: $title, artist: $artist)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Track && other.title == title && other.artist == artist;
  }

  @override
  int get hashCode => title.hashCode ^ artist.hashCode;
}
