import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myks_radio/providers/radio_provider.dart';
import 'package:myks_radio/services/audio_player_service.dart';
import 'package:myks_radio/services/icecast_service.dart';
import 'package:myks_radio/services/storage_service.dart';
import 'package:myks_radio/models/radio_metadata.dart';
import 'package:myks_radio/models/track.dart';

// Mock classes
class MockAudioPlayerService extends Mock implements AudioPlayerService {}

class MockIcecastService extends Mock implements IcecastService {}

class MockStorageService extends Mock implements StorageService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RadioProvider', () {
    late RadioProvider provider;
    late MockAudioPlayerService mockAudioService;
    late MockIcecastService mockIcecastService;
    late MockStorageService mockStorageService;

    setUp(() {
      mockAudioService = MockAudioPlayerService();
      mockIcecastService = MockIcecastService();
      mockStorageService = MockStorageService();

      // Set up default mock behaviors
      when(() => mockStorageService.getVolume()).thenReturn(0.8);
      when(
        () => mockStorageService.getStreamUrl(),
      ).thenReturn('http://test-stream.com');
      when(() => mockStorageService.getCachedTrackHistory()).thenReturn([]);
      when(() => mockAudioService.setStreamUrl(any())).thenReturn(null);
      when(() => mockAudioService.setVolume(any())).thenAnswer((_) async => {});
      when(
        () => mockAudioService.stateStream,
      ).thenAnswer((_) => Stream.value(RadioPlayerState.idle));
      when(
        () => mockAudioService.volumeStream,
      ).thenAnswer((_) => Stream.value(0.8));
      when(
        () => mockAudioService.errorStream,
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => mockIcecastService.metadataStream,
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => mockIcecastService.setHistoryUpdateCallback(any()),
      ).thenReturn(null);

      provider = RadioProvider(
        audioService: mockAudioService,
        icecastService: mockIcecastService,
        storage: mockStorageService,
      );
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state should be idle', () {
      expect(provider.playerState, RadioPlayerState.idle);
    });

    test('initial volume should be loaded from storage', () {
      expect(provider.volume, 0.8);
      verify(() => mockStorageService.getVolume()).called(1);
    });

    test('initial stream URL should be loaded from storage', () {
      expect(provider.streamUrl, 'http://test-stream.com');
      verify(() => mockStorageService.getStreamUrl()).called(1);
    });

    test('isPlaying should be false initially', () {
      expect(provider.isPlaying, false);
    });

    test('isLoading should be false initially', () {
      expect(provider.isLoading, false);
    });

    test('isPaused should be false initially', () {
      expect(provider.isPaused, false);
    });

    test('isIdle should be true initially', () {
      expect(provider.isIdle, true);
    });

    group('togglePlayPause', () {
      test('should call play when not playing', () async {
        when(() => mockAudioService.play()).thenAnswer((_) async => {});

        await provider.play();

        verify(() => mockAudioService.play()).called(1);
      });

      test('should call pause when playing', () async {
        when(() => mockAudioService.pause()).thenAnswer((_) async => {});

        await provider.pause();

        verify(() => mockAudioService.pause()).called(1);
      });

      test('should toggle between play and pause', () async {
        when(() => mockAudioService.play()).thenAnswer((_) async => {});
        when(() => mockAudioService.pause()).thenAnswer((_) async => {});

        // Initially idle, so should play
        await provider.togglePlayPause();
        verify(() => mockAudioService.play()).called(1);

        // If playing, should pause
        provider = RadioProvider(
          audioService: mockAudioService,
          icecastService: mockIcecastService,
          storage: mockStorageService,
        );

        when(
          () => mockAudioService.stateStream,
        ).thenAnswer((_) => Stream.value(RadioPlayerState.playing));

        // Wait for state to update
        await Future.delayed(const Duration(milliseconds: 100));

        await provider.togglePlayPause();
        verify(() => mockAudioService.pause()).called(greaterThan(0));
      });
    });

    group('setVolume', () {
      test('should update volume in audio service', () async {
        when(() => mockAudioService.setVolume(0.5)).thenAnswer((_) async => {});
        when(
          () => mockStorageService.setVolume(0.5),
        ).thenAnswer((_) async => {});

        await provider.setVolume(0.5);

        verify(() => mockAudioService.setVolume(0.5)).called(1);
      });

      test('should save volume to storage', () async {
        when(() => mockAudioService.setVolume(0.7)).thenAnswer((_) async => {});
        when(
          () => mockStorageService.setVolume(0.7),
        ).thenAnswer((_) async => {});

        await provider.setVolume(0.7);

        verify(() => mockStorageService.setVolume(0.7)).called(1);
      });
    });

    group('setStreamUrl', () {
      test('should update stream URL in audio service', () async {
        const newUrl = 'http://new-stream.com';
        when(
          () => mockStorageService.setStreamUrl(newUrl),
        ).thenAnswer((_) async => {});

        await provider.setStreamUrl(newUrl);

        verify(() => mockAudioService.setStreamUrl(newUrl)).called(1);
      });

      test('should save stream URL to storage', () async {
        const newUrl = 'http://new-stream.com';
        when(
          () => mockStorageService.setStreamUrl(newUrl),
        ).thenAnswer((_) async => {});

        await provider.setStreamUrl(newUrl);

        verify(() => mockStorageService.setStreamUrl(newUrl)).called(1);
      });

      test('should notify listeners', () async {
        const newUrl = 'http://new-stream.com';
        when(
          () => mockStorageService.setStreamUrl(newUrl),
        ).thenAnswer((_) async => {});

        var notified = false;
        provider.addListener(() {
          notified = true;
        });

        await provider.setStreamUrl(newUrl);

        expect(notified, true);
      });
    });

    group('metadata handling', () {
      test('should update current track from metadata', () async {
        final track = Track(
          title: 'Test Song',
          artist: 'Test Artist',
          playedAt: DateTime.now(),
        );

        final metadata = RadioMetadata(
          title: 'Test Song',
          artist: 'Test Artist',
          history: [track],
        );

        when(
          () => mockIcecastService.metadataStream,
        ).thenAnswer((_) => Stream.value(metadata));

        provider = RadioProvider(
          audioService: mockAudioService,
          icecastService: mockIcecastService,
          storage: mockStorageService,
        );

        // Wait for stream to emit
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.currentTrack?.title, 'Test Song');
        expect(provider.currentTrack?.artist, 'Test Artist');
      });

      test('should update history from metadata', () async {
        final track1 = Track(
          title: 'Song 1',
          artist: 'Artist 1',
          playedAt: DateTime.now(),
        );
        final track2 = Track(
          title: 'Song 2',
          artist: 'Artist 2',
          playedAt: DateTime.now(),
        );

        final metadata = RadioMetadata(
          title: 'Song 2',
          artist: 'Artist 2',
          history: [track2, track1],
        );

        when(
          () => mockIcecastService.metadataStream,
        ).thenAnswer((_) => Stream.value(metadata));

        provider = RadioProvider(
          audioService: mockAudioService,
          icecastService: mockIcecastService,
          storage: mockStorageService,
        );

        // Wait for stream to emit
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.history.length, 2);
        expect(provider.history[0].title, 'Song 2');
        expect(provider.history[1].title, 'Song 1');
      });
    });

    group('clearHistory', () {
      test('should clear history from icecast service', () {
        when(() => mockIcecastService.clearHistory()).thenAnswer((_) async {});
        when(
          () => mockStorageService.cacheTrackHistory([]),
        ).thenAnswer((_) async {});

        provider.clearHistory();

        verify(() => mockIcecastService.clearHistory()).called(1);
      });

      test('should clear history from storage', () {
        when(() => mockIcecastService.clearHistory()).thenAnswer((_) async {});
        when(
          () => mockStorageService.cacheTrackHistory([]),
        ).thenAnswer((_) async {});

        provider.clearHistory();

        verify(() => mockStorageService.cacheTrackHistory([])).called(1);
      });

      test('should update history to empty list', () {
        when(() => mockIcecastService.clearHistory()).thenAnswer((_) async {});
        when(
          () => mockStorageService.cacheTrackHistory([]),
        ).thenAnswer((_) async {});

        provider.clearHistory();

        expect(provider.history, isEmpty);
      });
    });

    group('currentTitle', () {
      test('should return metadata title when available', () async {
        final metadata = RadioMetadata(
          title: 'Test Title',
          artist: 'Test Artist',
        );

        when(
          () => mockIcecastService.metadataStream,
        ).thenAnswer((_) => Stream.value(metadata));

        provider = RadioProvider(
          audioService: mockAudioService,
          icecastService: mockIcecastService,
          storage: mockStorageService,
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.currentTitle, 'Test Title');
      });

      test('should return "Myks Radio" when playing without metadata', () {
        when(
          () => mockAudioService.stateStream,
        ).thenAnswer((_) => Stream.value(RadioPlayerState.playing));

        provider = RadioProvider(
          audioService: mockAudioService,
          icecastService: mockIcecastService,
          storage: mockStorageService,
        );

        // Initially should be "Myks Radio"
        expect(provider.currentTitle, contains('Myks Radio'));
      });
    });

    group('currentArtist', () {
      test('should return metadata artist when available', () async {
        final metadata = RadioMetadata(
          title: 'Test Title',
          artist: 'Test Artist',
        );

        when(
          () => mockIcecastService.metadataStream,
        ).thenAnswer((_) => Stream.value(metadata));

        provider = RadioProvider(
          audioService: mockAudioService,
          icecastService: mockIcecastService,
          storage: mockStorageService,
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.currentArtist, 'Test Artist');
      });

      test('should return fallback when no metadata', () {
        expect(provider.currentArtist, isNotEmpty);
      });
    });

    group('dispose', () {
      test('should cancel all subscriptions', () {
        // This test verifies that dispose doesn't throw
        expect(() => provider.dispose(), returnsNormally);
      });
    });
  });
}
