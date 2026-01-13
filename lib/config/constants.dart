/// Configuration constants for Myks Radio
class AppConstants {
  // App Info
  static const String appName = 'Myks Radio';
  static const String appVersion = '1.0.0';

  // Default Stream URL
  static const String defaultStreamUrl =
      'http://global.citrus3.com:8370/stream';

  // API Base URL (change this to your backend URL)
  static const String apiBaseUrl = 'https://myks.vercel.app';

  // Timing
  static const Duration metadataRefreshInterval = Duration(seconds: 15);
  static const Duration reconnectDelay = Duration(seconds: 3);
  static const int maxReconnectAttempts = 5;

  // Pagination
  static const int videosPerPage = 12;

  // Audio
  static const double defaultVolume = 0.8;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Visualizer
  static const int visualizerBars = 21;
  static const double visualizerMinHeight = 0.2;
  static const double visualizerMaxHeight = 1.0;

  // Storage Keys
  static const String keyVolume = 'volume';
  static const String keyStreamUrl = 'stream_url';

  // Social Links
  static const String facebookUrl = 'https://facebook.com/myksradio';
  static const String instagramUrl = 'https://instagram.com/myksradio';
  static const String twitterUrl = 'https://twitter.com/myksradio';
  static const String youtubeUrl = 'https://youtube.com/@myksradio';
}
