import '../config/constants.dart';

/// Model representing radio stream configuration
class RadioConfig {
  final String streamUrl;
  final String name;
  final bool isDefault;
  final DateTime? lastUpdated;

  RadioConfig({
    required this.streamUrl,
    this.name = AppConstants.appName,
    this.isDefault = true,
    this.lastUpdated,
  });

  factory RadioConfig.fromJson(Map<String, dynamic> json) {
    return RadioConfig(
      streamUrl:
          json['streamUrl'] ??
          json['stream_url'] ??
          AppConstants.defaultStreamUrl,
      name: json['name'] ?? AppConstants.appName,
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streamUrl': streamUrl,
      'name': name,
      'isDefault': isDefault,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Default configuration
  factory RadioConfig.defaultConfig() {
    return RadioConfig(
      streamUrl: AppConstants.defaultStreamUrl,
      name: AppConstants.appName,
      isDefault: true,
    );
  }

  RadioConfig copyWith({
    String? streamUrl,
    String? name,
    bool? isDefault,
    DateTime? lastUpdated,
  }) {
    return RadioConfig(
      streamUrl: streamUrl ?? this.streamUrl,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() => 'RadioConfig(streamUrl: $streamUrl, name: $name)';
}
