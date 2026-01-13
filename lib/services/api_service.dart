import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../models/video.dart';
import '../models/radio_config.dart';
import '../models/radio_metadata.dart';

/// API Service for communicating with the backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final Map<String, CancelToken> _cancelTokens = {};

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging in debug mode only
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: false, // Reduced logging for performance
          responseBody: false,
          error: true,
        ),
      );
    }
  }

  /// Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // ==================== Config Endpoints ====================

  /// Get radio configuration
  Future<RadioConfig> getConfig() async {
    try {
      final response = await _dio.get('/api/config');
      return RadioConfig.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update radio configuration
  Future<bool> updateConfig(RadioConfig config) async {
    try {
      final response = await _dio.put('/api/config', data: config.toJson());
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Metadata Endpoints ====================

  /// Get radio metadata from stream URL
  Future<RadioMetadata> getMetadata(String streamUrl) async {
    try {
      final response = await _dio.get(
        '/api/metadata',
        queryParameters: {'url': streamUrl},
      );
      return RadioMetadata.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Video Endpoints ====================

  /// Get all videos
  Future<List<Video>> getVideos({
    int page = 1,
    int limit = 12,
    String? search,
  }) async {
    // Cancel previous request if still running
    _cancelTokens['getVideos']?.cancel('New request started');

    final cancelToken = CancelToken();
    _cancelTokens['getVideos'] = cancelToken;

    try {
      final response = await _dio.get(
        '/api/videos',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
        },
        cancelToken: cancelToken,
      );

      final List<dynamic> data = response.data is List
          ? response.data
          : response.data['videos'] ?? [];

      _cancelTokens.remove('getVideos');
      return data.map((json) => Video.fromJson(json)).toList();
    } on DioException catch (e) {
      _cancelTokens.remove('getVideos');
      throw _handleError(e);
    }
  }

  /// Get featured video
  Future<Video?> getFeaturedVideo() async {
    // Cancel previous request if still running
    _cancelTokens['getFeaturedVideo']?.cancel('New request started');

    final cancelToken = CancelToken();
    _cancelTokens['getFeaturedVideo'] = cancelToken;

    try {
      final response = await _dio.get(
        '/api/videos/featured',
        cancelToken: cancelToken,
      );

      if (response.data == null || response.data.isEmpty) {
        _cancelTokens.remove('getFeaturedVideo');
        return null;
      }

      _cancelTokens.remove('getFeaturedVideo');
      return Video.fromJson(response.data);
    } on DioException catch (e) {
      _cancelTokens.remove('getFeaturedVideo');
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e);
    }
  }

  /// Add a new video
  Future<Video> addVideo({
    required String url,
    required String title,
    String description = '',
    bool isFeatured = false,
  }) async {
    try {
      final response = await _dio.post(
        '/api/videos',
        data: {
          'url': url,
          'title': title,
          'description': description,
          'isFeatured': isFeatured,
        },
      );
      return Video.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a video
  Future<bool> deleteVideo(String id) async {
    try {
      await _dio.delete('/api/videos/$id');
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update video featured status
  Future<bool> setVideoFeatured(String id, bool isFeatured) async {
    try {
      await _dio.patch('/api/videos/$id', data: {'isFeatured': isFeatured});
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Error Handling ====================

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data?['message'] ?? e.response?.data?['error'];
        if (statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (statusCode == 403) {
          return 'Access denied.';
        } else if (statusCode == 404) {
          return 'Resource not found.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return message ?? 'An error occurred (Error $statusCode)';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  /// Dispose and cancel all ongoing requests
  void dispose() {
    // Cancel all ongoing requests
    for (var token in _cancelTokens.values) {
      token.cancel('Service disposed');
    }
    _cancelTokens.clear();
  }
}
