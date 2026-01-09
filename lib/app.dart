import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/radio_provider.dart';
import 'providers/videos_provider.dart';
import 'services/storage_service.dart';
import 'services/audio_player_service.dart';
import 'services/icecast_service.dart';
import 'services/api_service.dart';

/// Main application widget
class MyksRadioApp extends StatelessWidget {
  const MyksRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myks Radio',
      debugShowCheckedModeBanner: false,

      // Theme configuration - Fixed to dark mode
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Routes
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,

      // Builder for system UI overlay style
      builder: (context, child) {
        // Always use dark theme system UI
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: AppColors.darkBackground,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        );

        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// App initialization and provider setup
class AppInitializer extends StatelessWidget {
  final Widget child;

  const AppInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Services (singletons)
    final storageService = StorageService();
    final audioService = AudioPlayerService();
    final icecastService = IcecastService();
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        // Radio Provider
        ChangeNotifierProvider(
          create: (_) => RadioProvider(
            audioService: audioService,
            icecastService: icecastService,
            storage: storageService,
          ),
        ),

        // Videos Provider
        ChangeNotifierProvider(
          create: (_) =>
              VideosProvider(api: apiService, storage: storageService),
        ),
      ],
      child: child,
    );
  }
}
