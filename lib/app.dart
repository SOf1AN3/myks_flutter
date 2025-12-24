import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/theme_provider.dart';
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Myks Radio',
          debugShowCheckedModeBanner: false,

          // Theme configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          // Routes
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRoutes.generateRoute,

          // Builder for system UI overlay style
          builder: (context, child) {
            // Update system UI based on theme
            final isDark = Theme.of(context).brightness == Brightness.dark;
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDark
                    ? Brightness.light
                    : Brightness.dark,
                systemNavigationBarColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                systemNavigationBarIconBrightness: isDark
                    ? Brightness.light
                    : Brightness.dark,
              ),
            );

            return child ?? const SizedBox.shrink();
          },
        );
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
        // Theme Provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storage: storageService),
        ),

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
