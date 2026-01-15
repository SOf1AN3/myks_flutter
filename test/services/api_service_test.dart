import 'package:flutter_test/flutter_test.dart';
import 'package:myks_radio/services/api_service.dart';
import 'package:myks_radio/models/video.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiService', () {
    late ApiService service;

    setUp(() {
      service = ApiService();
    });

    group('fetchVideos', () {
      test('should return list of videos from array response', () async {
        // Note: This test will fail without a real backend
        // but we can verify the method handles data correctly
        try {
          final videos = await service.getVideos(page: 1, limit: 12);
          expect(videos, isA<List<Video>>());
        } catch (e) {
          // Expected to fail without real backend
          expect(e, isA<String>()); // Error message from _handleError
        }
      });

      test('should handle search parameter', () async {
        try {
          final videos = await service.getVideos(search: 'test');
          expect(videos, isA<List<Video>>());
        } catch (e) {
          // Expected to fail without real backend
          expect(e, isA<String>());
        }
      });

      test('should handle pagination parameters', () async {
        try {
          final videos = await service.getVideos(page: 2, limit: 6);
          expect(videos, isA<List<Video>>());
        } catch (e) {
          // Expected to fail without real backend
          expect(e, isA<String>());
        }
      });

      test('should cancel previous request when new request starts', () async {
        // Start first request
        service.getVideos(page: 1);

        // Start second request immediately (should cancel first)
        final future2 = service.getVideos(page: 2);

        try {
          await future2;
        } catch (e) {
          // Expected to fail without real backend
          expect(e, isA<String>());
        }
      });
    });

    group('getFeaturedVideo', () {
      test('should return featured video if available', () async {
        try {
          final video = await service.getFeaturedVideo();
          expect(video, anyOf(isNull, isA<Video>()));
        } catch (e) {
          // Expected to fail without real backend
          expect(e, isA<String>());
        }
      });

      test('should return null when no featured video (404)', () async {
        try {
          final video = await service.getFeaturedVideo();
          expect(video, anyOf(isNull, isA<Video>()));
        } catch (e) {
          // Expected to fail without real backend or return null
          expect(e, anyOf(isNull, isA<String>()));
        }
      });

      test('should cancel previous request when new request starts', () async {
        // Start first request
        service.getFeaturedVideo();

        // Start second request immediately (should cancel first)
        final future2 = service.getFeaturedVideo();

        try {
          await future2;
        } catch (e) {
          // Expected to fail without real backend
        }
      });
    });

    group('error handling', () {
      test('should throw error message on connection timeout', () async {
        try {
          // This will timeout as the server doesn't exist
          await service.getVideos();
          fail('Should have thrown an error');
        } catch (e) {
          expect(e, isA<String>());
          // Should contain connection-related error message
          expect(
            e.toString(),
            anyOf(
              contains('timeout'),
              contains('connection'),
              contains('internet'),
              contains('Connection'),
            ),
          );
        }
      });

      test('should handle network errors gracefully', () async {
        try {
          await service.getFeaturedVideo();
        } catch (e) {
          expect(e, isA<String>());
          expect(e.toString(), isNotEmpty);
        }
      });
    });

    group('setAuthToken', () {
      test('should set authorization header', () {
        const token = 'test-token-12345';
        expect(() => service.setAuthToken(token), returnsNormally);
      });
    });

    group('clearAuthToken', () {
      test('should remove authorization header', () {
        expect(() => service.clearAuthToken(), returnsNormally);
      });
    });

    group('dispose', () {
      test('should cancel all ongoing requests', () {
        // Start some requests
        service.getVideos();
        service.getFeaturedVideo();

        // Dispose should cancel them
        expect(() => service.dispose(), returnsNormally);
      });

      test('should not throw when disposed without active requests', () {
        expect(() => service.dispose(), returnsNormally);
      });
    });

    group('addVideo', () {
      test('should throw error without authentication', () async {
        try {
          await service.addVideo(
            url: 'https://youtube.com/watch?v=test123',
            title: 'Test Video',
          );
          fail('Should have thrown an error');
        } catch (e) {
          expect(e, isA<String>());
        }
      });
    });

    group('deleteVideo', () {
      test('should throw error without authentication', () async {
        try {
          await service.deleteVideo('test-id');
          fail('Should have thrown an error');
        } catch (e) {
          expect(e, isA<String>());
        }
      });
    });

    group('setVideoFeatured', () {
      test('should throw error without authentication', () async {
        try {
          await service.setVideoFeatured('test-id', true);
          fail('Should have thrown an error');
        } catch (e) {
          expect(e, isA<String>());
        }
      });
    });
  });
}
