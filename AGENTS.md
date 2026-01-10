# AGENTS.md - Myks Radio Flutter Project

## Project Overview
Myks Radio is a Flutter 3.10+ application implementing a live radio streaming interface with a modern "Liquid Glass" design system. The app features audio streaming, metadata display, visualizers, and a YouTube video gallery.

## Build, Test & Lint Commands

### Installation
```bash
flutter pub get
```

### Run Application
```bash
# Debug mode (default)
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device-id>
```

### Testing
```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Run tests matching a pattern
flutter test --name="<regexp>"

# Run tests with plain name substring
flutter test --plain-name="<substring>"

# Run with verbose output
flutter test -v
```

### Linting & Analysis
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format lib/ test/

# Format and apply changes
dart format --fix lib/ test/
```

### Build
```bash
# Build APK (Android)
flutter build apk

# Build app bundle (Android)
flutter build appbundle

# Build iOS
flutter build ios

# Clean build artifacts
flutter clean
```

## Project Structure

```
lib/
├── app.dart                    # App initialization & providers
├── main.dart                   # Entry point
├── config/
│   ├── constants.dart         # App constants & configuration
│   ├── routes.dart            # Route definitions
│   └── theme.dart             # Theme, colors, glass effects
├── models/                     # Data models (Track, RadioMetadata, etc.)
├── providers/                  # State management (Provider pattern)
│   ├── radio_provider.dart
│   └── videos_provider.dart
├── screens/                    # Screen implementations
│   ├── home/
│   ├── radio/
│   ├── videos/
│   └── about/
├── services/                   # Business logic & API services
│   ├── audio_player_service.dart
│   ├── icecast_service.dart
│   ├── storage_service.dart
│   └── api_service.dart
└── widgets/                    # Reusable UI components
    ├── liquid_glass_container.dart
    ├── liquid_button.dart
    ├── mesh_gradient_background.dart
    └── bottom_navigation.dart
```

## Code Style Guidelines

### Imports Organization
Always organize imports in this order:
1. Dart SDK imports (`dart:*`)
2. Flutter SDK imports (`package:flutter/*`)
3. Third-party packages
4. Local project imports (relative paths)

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
import '../services/audio_player_service.dart';
```

### Formatting
- **Indentation**: 2 spaces (standard Dart/Flutter)
- **Line length**: Soft limit at 80 characters (enforced by `dart format`)
- **Always use trailing commas** for better formatting and diffs
- **Use `const` constructors** wherever possible for performance

```dart
// Good
LiquidGlassContainer(
  padding: const EdgeInsets.all(24),
  borderRadius: GlassEffects.radiusMedium,
  showInnerGlow: true,
  child: Text('Hello'),
);

// Bad - missing trailing commas and const
LiquidGlassContainer(
  padding: EdgeInsets.all(24),
  child: Text('Hello')
);
```

### Naming Conventions
- **Classes**: `PascalCase` (e.g., `RadioProvider`, `AudioPlayerService`)
- **Files**: `snake_case.dart` (e.g., `audio_player_service.dart`)
- **Variables/Methods**: `camelCase` (e.g., `isPlaying`, `togglePlayPause`)
- **Constants**: `camelCase` with `static const` (e.g., `AppConstants.defaultVolume`)
- **Private members**: prefix with `_` (e.g., `_audioService`, `_init()`)

### Types
- **Always specify types** for class properties and function return values
- Use **type inference** for local variables when type is obvious
- Prefer **explicit `Future<void>`** over dynamic for async functions

```dart
// Good
class RadioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  double _volume = 0.8;
  
  Future<void> play() async {
    await _audioService.play();
  }
}

// Bad
class RadioProvider extends ChangeNotifier {
  var _audioService;
  var _volume = 0.8;
  
  play() async {
    await _audioService.play();
  }
}
```

### State Management
- Use **Provider** pattern for app-wide state
- Use **ChangeNotifier** for observable state classes
- Call **`notifyListeners()`** after state changes
- **Dispose** of resources in `dispose()` method

```dart
class RadioProvider extends ChangeNotifier {
  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioService.setVolume(volume);
    notifyListeners(); // Important!
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

### Error Handling
- Use **try-catch** blocks for async operations
- Handle **null safely** with `?`, `??`, and null checks
- Provide **meaningful error messages**
- Update UI state on errors

```dart
Future<void> play() async {
  try {
    _error = null;
    notifyListeners();
    await _audioService.play();
  } catch (e) {
    _error = e.toString();
    _updateState(RadioPlayerState.error);
    notifyListeners();
  }
}
```

### Comments & Documentation
- Use **`///`** for public API documentation
- Use **`//`** for implementation comments
- Document **class purpose** and **public methods**
- Avoid obvious comments; code should be self-explanatory

```dart
/// Provider for radio state management
class RadioProvider extends ChangeNotifier {
  /// Play the radio stream
  Future<void> play() async {
    // Implementation
  }
}
```

## Design System - Liquid Glass

### Colors (AppColors)
```dart
AppColors.darkBackgroundDeep    // #0B0118 - Main background
AppColors.primary               // #A855F7 - Violet accent
AppColors.glassBackground       // rgba(255,255,255,0.08)
AppColors.glassBorder           // rgba(255,255,255,0.12)
```

### Glass Effects (GlassEffects)
```dart
GlassEffects.blurIntensity        // 24.0 - Main blur
GlassEffects.radiusMedium         // 24.0 - Border radius
GlassEffects.glowShadow           // Violet glow effect
```

### Key Widgets
- **LiquidGlassContainer**: Glass morphism container with blur
- **LiquidButton**: Animated buttons with glass effect
- **MeshGradientBackground**: Animated gradient background
- **CurvedGlassViewer**: Curved top glass container

### Layout Guidelines
- Use **SafeArea** for screen boundaries
- Apply **24px horizontal padding** for content
- Use **Stack** for overlaying components (not Column with Expanded + fixed heights)
- Add **bottom padding** to scrollable content to avoid overlap with fixed bottom elements
- **Never use negative margins** (Flutter constraint violation)

## Common Patterns

### Creating a New Screen
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/radio_provider.dart';
import '../../widgets/mesh_gradient_background.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Consumer<RadioProvider>(
              builder: (context, radio, child) {
                return Column(
                  children: [
                    // Your content
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
```

### Async Operations
```dart
Future<void> _handleAction() async {
  final provider = context.read<RadioProvider>();
  await provider.someAsyncMethod();
}
```

### Animations (flutter_animate)
```dart
Widget build(BuildContext context) {
  return Container(...)
    .animate()
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.1, end: 0);
}
```

## Performance Tips
- **Minimize BackdropFilter usage** - expensive operation
- Use **const constructors** wherever possible
- **Dispose AnimationControllers** and StreamSubscriptions
- Avoid **nested BackdropFilters**
- Use **RepaintBoundary** for complex animated widgets

## Dependencies
Key packages used (see pubspec.yaml):
- `provider` - State management
- `just_audio` - Audio playback
- `audio_service` - Background audio
- `dio` - HTTP client
- `flutter_animate` - Animations
- `cached_network_image` - Image caching
- `flex_color_scheme` - Theme system
- `google_fonts` - Typography

## Reference Documentation
- See `COMPONENT_GUIDE.md` for detailed UI component specifications
- See `LIQUID_GLASS_IMPLEMENTATION.md` for design system details
- See `BUGFIXES.md` for common issues and solutions
- See `design.html` for visual design reference

## Development Notes
- App is **fixed to dark mode** (ThemeMode.dark)
- Uses **portrait orientation only**
- Requires **Flutter 3.10.4+** and **Dart SDK**
- Audio streaming via **Icecast** metadata polling
