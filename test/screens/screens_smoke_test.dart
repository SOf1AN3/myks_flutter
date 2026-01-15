import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myks_radio/screens/home/home_screen.dart';
import 'package:myks_radio/screens/radio/radio_screen.dart';
import 'package:myks_radio/screens/videos/videos_screen.dart';
import 'package:myks_radio/screens/about/about_screen.dart';
import 'package:myks_radio/providers/radio_provider.dart';
import 'package:myks_radio/providers/videos_provider.dart';
import 'package:myks_radio/services/audio_player_service.dart';
import 'package:myks_radio/services/icecast_service.dart';
import 'package:myks_radio/services/storage_service.dart';
import 'package:myks_radio/services/api_service.dart';

// Mock classes
class MockAudioPlayerService extends Mock implements AudioPlayerService {}

class MockIcecastService extends Mock implements IcecastService {}

class MockStorageService extends Mock implements StorageService {}

class MockApiService extends Mock implements ApiService {}

/// Smoke tests verify that screens can be instantiated and rendered
/// without crashing using mocked services to avoid native plugin dependencies.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Screens Smoke Tests', () {
    late RadioProvider radioProvider;
    late VideosProvider videosProvider;
    late MockAudioPlayerService mockAudioService;
    late MockIcecastService mockIcecastService;
    late MockStorageService mockStorageService;
    late MockApiService mockApiService;

    setUp(() {
      // Create mocks
      mockAudioService = MockAudioPlayerService();
      mockIcecastService = MockIcecastService();
      mockStorageService = MockStorageService();
      mockApiService = MockApiService();

      // Set up default mock behaviors
      when(() => mockStorageService.getVolume()).thenReturn(0.8);
      when(
        () => mockStorageService.getStreamUrl(),
      ).thenReturn('http://test-stream.com');
      when(() => mockStorageService.getCachedTrackHistory()).thenReturn([]);
      when(() => mockStorageService.getCachedVideos()).thenReturn([]);
      when(() => mockStorageService.getCachedFeaturedVideo()).thenReturn(null);
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

      // Create providers with mocks
      radioProvider = RadioProvider(
        audioService: mockAudioService,
        icecastService: mockIcecastService,
        storage: mockStorageService,
      );

      videosProvider = VideosProvider(
        api: mockApiService,
        storage: mockStorageService,
      );
    });

    tearDown(() {
      radioProvider.dispose();
      videosProvider.dispose();
    });

    testWidgets('HomeScreen renders without crashing', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RadioProvider>.value(value: radioProvider),
            ChangeNotifierProvider<VideosProvider>.value(value: videosProvider),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      // Wait for animations and async operations
      await tester.pumpAndSettle();

      // Verify screen is rendered
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify key elements are present
      expect(find.text('MYKS Radio'), findsAtLeastNWidgets(1));
      expect(find.text('Votre radio en ligne 24/7'), findsOneWidget);
      expect(find.text('Écouter la Radio'), findsOneWidget);
      expect(find.text('Voir les Vidéos'), findsOneWidget);
    });

    testWidgets('RadioScreen renders without crashing', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RadioProvider>.value(value: radioProvider),
          ],
          child: const MaterialApp(home: RadioScreen()),
        ),
      );

      // Wait for animations
      await tester.pumpAndSettle();

      // Verify screen is rendered
      expect(find.byType(RadioScreen), findsOneWidget);

      // Verify key elements are present
      expect(find.text('MYKS Radio'), findsOneWidget);
      expect(find.text('STREAMING NOW'), findsOneWidget);

      // Verify play button is present (should show Icon or CircularProgressIndicator)
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              (widget.icon == Icons.play_arrow || widget.icon == Icons.pause),
        ),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('VideosScreen renders without crashing', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RadioProvider>.value(value: radioProvider),
            ChangeNotifierProvider<VideosProvider>.value(value: videosProvider),
          ],
          child: const MaterialApp(home: VideosScreen()),
        ),
      );

      // Wait for initial render
      await tester.pump();

      // Verify screen is rendered
      expect(find.byType(VideosScreen), findsOneWidget);

      // Verify key elements are present
      expect(find.text('VIDÉOS'), findsOneWidget);
      expect(find.text('DÉCOUVREZ'), findsOneWidget);

      // Verify search bar is present
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.hintText == 'Rechercher une vidéo...',
        ),
        findsOneWidget,
      );

      // Wait for async operations (loading videos)
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('AboutScreen renders without crashing', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RadioProvider>.value(value: radioProvider),
          ],
          child: const MaterialApp(home: AboutScreen()),
        ),
      );

      // Wait for animations
      await tester.pumpAndSettle();

      // Verify screen is rendered
      expect(find.byType(AboutScreen), findsOneWidget);

      // Verify key elements are present
      expect(find.text('MYKS Radio'), findsOneWidget);
      expect(find.text('Votre destination musicale préférée'), findsOneWidget);
      expect(find.text('Notre Mission'), findsOneWidget);
      expect(find.text('Suivez-nous'), findsOneWidget);

      // Verify social buttons are present
      expect(find.text('Facebook'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('Twitter'), findsOneWidget);
      expect(find.text('YouTube'), findsOneWidget);

      // Verify version info
      expect(find.textContaining('v1.0.0'), findsOneWidget);
      expect(find.text('© 2024 Myks Radio'), findsOneWidget);
    });

    group('Screen Navigation', () {
      testWidgets('All screens have bottom navigation', (tester) async {
        // Test HomeScreen
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<RadioProvider>.value(value: radioProvider),
              ChangeNotifierProvider<VideosProvider>.value(
                value: videosProvider,
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byWidgetPredicate((widget) => widget is BottomNavigationBar),
          findsOneWidget,
        );

        // Test RadioScreen
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<RadioProvider>.value(value: radioProvider),
            ],
            child: const MaterialApp(home: RadioScreen()),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byWidgetPredicate((widget) => widget is BottomNavigationBar),
          findsOneWidget,
        );

        // Test VideosScreen
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<RadioProvider>.value(value: radioProvider),
              ChangeNotifierProvider<VideosProvider>.value(
                value: videosProvider,
              ),
            ],
            child: const MaterialApp(home: VideosScreen()),
          ),
        );
        await tester.pump();
        expect(
          find.byWidgetPredicate((widget) => widget is BottomNavigationBar),
          findsOneWidget,
        );

        // Test AboutScreen
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<RadioProvider>.value(value: radioProvider),
            ],
            child: const MaterialApp(home: AboutScreen()),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byWidgetPredicate((widget) => widget is BottomNavigationBar),
          findsOneWidget,
        );
      });
    });

    group('Responsive Layout', () {
      testWidgets('Screens adapt to different screen sizes', (tester) async {
        // Test small screen (phone)
        tester.view.physicalSize = const Size(375, 667);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<RadioProvider>.value(value: radioProvider),
              ChangeNotifierProvider<VideosProvider>.value(
                value: videosProvider,
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);

        // Test large screen (tablet)
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 2.0;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<RadioProvider>.value(value: radioProvider),
              ChangeNotifierProvider<VideosProvider>.value(
                value: videosProvider,
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);

        // Reset to default size
        addTearDown(tester.view.reset);
      });
    });
  });
}
