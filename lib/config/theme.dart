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

  // Dark Theme
  static const darkBackground = Color(0xFF0A0A0A);
  static const darkForeground = Color(0xFFFAFAFA);
  static const darkCard = Color(0xFF0A0A0A);
  static const darkMuted = Color(0xFF262626);
  static const darkMutedForeground = Color(0xFFA3A3A3);
  static const darkBorder = Color(0xFF262626);

  // Primary (Violet)
  static const primaryLight = Color(0xFF8B5CF6);
  static const primaryDark = Color(0xFFA78BFA);

  // Secondary
  static const secondary = Color(0xFFA855F7);
  static const tertiary = Color(0xFFD946EF);

  // Status Colors
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const live = Color(0xFFEF4444);

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

  static const darkGradient = LinearGradient(
    colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
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
      scaffoldBackgroundColor: AppColors.darkBackground,
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
