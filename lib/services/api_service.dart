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
    return _retryRequest(() async {
      final response = await _dio.get('/api/config');
      return RadioConfig.fromJson(response.data);
    });
  }

  /// Update radio configuration
  Future<bool> updateConfig(RadioConfig config) async {
    return _retryRequest(() async {
      final response = await _dio.put('/api/config', data: config.toJson());
      return response.data['success'] == true;
    });
  }

  // ==================== Metadata Endpoints ====================

  /// Get radio metadata from stream URL
  Future<RadioMetadata> getMetadata(String streamUrl) async {
    return _retryRequest(() async {
      final response = await _dio.get(
        '/api/metadata',
        queryParameters: {'url': streamUrl},
      );
      return RadioMetadata.fromJson(response.data);
    });
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
      return await _retryRequest(() async {
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

        return data.map((json) => Video.fromJson(json)).toList();
      });
    } finally {
      _cancelTokens.remove('getVideos');
    }
  }

  /// Get featured video
  Future<Video?> getFeaturedVideo() async {
    // Cancel previous request if still running
    _cancelTokens['getFeaturedVideo']?.cancel('New request started');

    final cancelToken = CancelToken();
    _cancelTokens['getFeaturedVideo'] = cancelToken;

    try {
      return await _retryRequest(() async {
        final response = await _dio.get(
          '/api/videos/featured',
          cancelToken: cancelToken,
        );

        if (response.data == null || response.data.isEmpty) {
          return null;
        }

        return Video.fromJson(response.data);
      }, shouldRetry404: false);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    } finally {
      _cancelTokens.remove('getFeaturedVideo');
    }
  }

  /// Add a new video
  Future<Video> addVideo({
    required String url,
    required String title,
    String description = '',
    bool isFeatured = false,
  }) async {
    return _retryRequest(() async {
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
    });
  }

  /// Delete a video
  Future<bool> deleteVideo(String id) async {
    return _retryRequest(() async {
      await _dio.delete('/api/videos/$id');
      return true;
    });
  }

  /// Update video featured status
  Future<bool> setVideoFeatured(String id, bool isFeatured) async {
    return _retryRequest(() async {
      await _dio.patch('/api/videos/$id', data: {'isFeatured': isFeatured});
      return true;
    });
  }

  // ==================== Error Handling ====================

  /// Retry mechanism for API requests (3 attempts with exponential backoff)
  Future<T> _retryRequest<T>(
    Future<T> Function() request, {
    int maxRetries = 3,
    bool shouldRetry404 = true,
  }) async {
    int retryCount = 0;
    DioException? lastException;

    while (retryCount < maxRetries) {
      try {
        return await request();
      } on DioException catch (e) {
        lastException = e;

        // Don't retry for certain error types
        if (!_shouldRetryError(e, shouldRetry404)) {
          throw _handleError(e);
        }

        retryCount++;
        if (retryCount >= maxRetries) {
          throw _handleError(e);
        }

        // Exponential backoff: 500ms, 1000ms, 2000ms
        final delayMs = 500 * (1 << (retryCount - 1));
        await Future.delayed(Duration(milliseconds: delayMs));

        if (kDebugMode) {
          print('Tentative $retryCount/$maxRetries après ${delayMs}ms');
        }
      }
    }

    // Should never reach here, but just in case
    throw _handleError(lastException!);
  }

  /// Determine if an error should trigger a retry
  bool _shouldRetryError(DioException e, bool shouldRetry404) {
    switch (e.type) {
      // Retry on timeout and connection errors
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      // Don't retry on cancellation
      case DioExceptionType.cancel:
        return false;

      // Retry on server errors (5xx) and some client errors
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == null) return false;

        // Retry on server errors
        if (statusCode >= 500) return true;

        // Optionally retry on 404
        if (statusCode == 404) return shouldRetry404;

        // Don't retry on other client errors (4xx)
        return false;

      default:
        return false;
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data?['message'] ?? e.response?.data?['error'];
        if (statusCode == 401) {
          return 'Non autorisé. Veuillez vous reconnecter.';
        } else if (statusCode == 403) {
          return 'Accès refusé.';
        } else if (statusCode == 404) {
          return 'Ressource non trouvée.';
        } else if (statusCode == 500) {
          return 'Erreur serveur. Veuillez réessayer plus tard.';
        } else if (statusCode == 503) {
          return 'Service temporairement indisponible.';
        }
        return message ?? 'Une erreur s\'est produite (Erreur $statusCode)';
      case DioExceptionType.cancel:
        return 'Requête annulée.';
      case DioExceptionType.connectionError:
        return 'Aucune connexion internet. Vérifiez votre réseau.';
      default:
        return 'Une erreur inattendue s\'est produite. Veuillez réessayer.';
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
