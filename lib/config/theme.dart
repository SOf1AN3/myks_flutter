import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color palette
class AppColors {
  // Light Theme
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightForeground = Color(0xFF0A0A0A);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightMuted = Color(0xFFF5F5F5);
  static const lightMutedForeground = Color(0xFF737373);
  static const lightBorder = Color(0xFFE5E5E5);

  // Dark Theme - Liquid Glass Design
  static const darkBackgroundDeep = Color(
    0xFF0B0118,
  ); // New deep violet background
  static const darkBackground = Color(0xFF0A0A0A);
  static const darkForeground = Color(0xFFFAFAFA);
  static const darkCard = Color(0xFF0A0A0A);
  static const darkMuted = Color(0xFF262626);
  static const darkMutedForeground = Color(0xFFA3A3A3);
  static const darkBorder = Color(0xFF262626);

  // Primary (Violet) - Liquid Glass Design
  static const primaryLight = Color(0xFF8B5CF6);
  static const primaryDark = Color(0xFFA78BFA);
  static const primary = Color(0xFFA855F7); // Main violet #A855F7

  // Secondary
  static const secondary = Color(0xFFA855F7);
  static const tertiary = Color(0xFFD946EF);
  static const purpleLight = Color(0xFFD8B4FE); // For gradient middle

  // Status Colors
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const live = Color(0xFFEF4444);

  // Liquid Glass Effect Colors
  static const glassBackground = Color(0x14FFFFFF); // rgba(255, 255, 255, 0.08)
  static const glassBorder = Color(0x1FFFFFFF); // rgba(255, 255, 255, 0.12)
  static const glassInnerGlow = Color(0x0DFFFFFF); // rgba(255, 255, 255, 0.05)
  static const glassControlBg = Color(0x26FFFFFF); // rgba(255, 255, 255, 0.15)
  static const glassControlBorder = Color(
    0x33FFFFFF,
  ); // rgba(255, 255, 255, 0.2)

  // Mesh Gradient Colors
  static const meshGradient1 = Color(0x33A855F7); // rgba(168, 85, 247, 0.2)
  static const meshGradient2 = Color(0x408B5CF6); // rgba(139, 92, 246, 0.25)
  static const meshGradient3 = Color(0x664C1D95); // rgba(76, 29, 149, 0.4)

  // Gradients
  static const violetGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7), Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const violetGradientVertical = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA855F7), Color(0xFFD946EF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Audio Visualizer Gradient
  static const waveBarGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFFD8B4FE), Color(0xFFFFFFFF)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  // Play Button Liquid Gradient
  static const playButtonGradient = LinearGradient(
    colors: [Color(0x80A855F7), Color(0x33A855F7)], // Semi-transparent violet
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Liquid Glass effect constants
class GlassEffects {
  // Blur intensity
  static const double blurIntensity = 24.0;
  static const double blurIntensityControl = 12.0;

  // Border radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 24.0;
  static const double radiusLarge = 40.0;
  static const double radiusXLarge = 48.0;

  // Shadows
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.4),
      blurRadius: 40,
      offset: const Offset(0, 0),
    ),
    const BoxShadow(
      color: Color(0x33FFFFFF), // rgba(255, 255, 255, 0.2)
      blurRadius: 20,
      offset: Offset(0, 0),
      spreadRadius: -10,
      blurStyle: BlurStyle.inner,
    ),
  ];

  static List<BoxShadow> get glassShadow => [
    const BoxShadow(
      color: Color(0x33000000), // rgba(0, 0, 0, 0.2)
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get innerGlowShadow => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 0),
      spreadRadius: -5,
      blurStyle: BlurStyle.inner,
    ),
  ];
}

/// App Theme configuration
class AppTheme {
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.deepPurple,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        fabUseShape: true,
        interactionEffects: true,
        bottomNavigationBarElevation: 0,
        bottomNavigationBarOpacity: 0.95,
        navigationBarOpacity: 0.95,
        navigationBarMutedUnselectedIcon: true,
        navigationBarMutedUnselectedLabel: true,
        navigationRailOpacity: 0.95,
        navigationRailMutedUnselectedIcon: true,
        navigationRailMutedUnselectedLabel: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12.0,
        cardRadius: 16.0,
        dialogRadius: 20.0,
        bottomSheetRadius: 20.0,
        elevatedButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        filledButtonRadius: 12.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
    ).copyWith(
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightCard,
    );
  }

  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.deepPurple,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        fabUseShape: true,
        interactionEffects: true,
        bottomNavigationBarElevation: 0,
        bottomNavigationBarOpacity: 0.95,
        navigationBarOpacity: 0.95,
        navigationBarMutedUnselectedIcon: true,
        navigationBarMutedUnselectedLabel: true,
        navigationRailOpacity: 0.95,
        navigationRailMutedUnselectedIcon: true,
        navigationRailMutedUnselectedLabel: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12.0,
        cardRadius: 16.0,
        dialogRadius: 20.0,
        bottomSheetRadius: 20.0,
        elevatedButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        filledButtonRadius: 12.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
    ).copyWith(
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: AppColors.darkBackgroundDeep,
      cardColor: AppColors.darkCard,
    );
  }
}

/// Extension for gradient text
extension GradientTextExtension on Text {
  Widget withGradient(Gradient gradient) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: this,
    );
  }
}
