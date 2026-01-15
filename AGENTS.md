# AGENTS.md - Myks Radio Flutter Project

## Project Overview
Myks Radio is a Flutter 3.10+ radio streaming app with a "Liquid Glass" design system. Features: audio streaming, metadata display, visualizers, and YouTube gallery.

**Tech Stack**: Flutter 3.10.4+, Provider (state management), just_audio, audio_service, dio, flutter_animate

## Build, Test & Lint Commands

### Installation & Run
```bash
flutter pub get                    # Install dependencies
flutter run                        # Debug mode
flutter run --release              # Release mode
flutter run -d <device-id>         # Specific device
```

### Testing
```bash
flutter test                                    # All tests
flutter test test/widget_test.dart              # Single test file
flutter test --name="pattern"                   # Test name pattern (regexp)
flutter test --plain-name="substring"           # Plain name substring match
flutter test -v                                 # Verbose output
```

### Linting & Analysis
```bash
flutter analyze                    # Analyze code for issues
dart format lib/ test/             # Format code (check only)
dart format --fix lib/ test/       # Format and apply fixes
```

### Build
```bash
flutter build apk                  # Android APK
flutter build appbundle            # Android app bundle
flutter build ios                  # iOS build
flutter clean                      # Clean build artifacts
```

## Project Structure
```
lib/
├── app.dart, main.dart           # Entry point & app initialization
├── config/                        # Constants, routes, theme (AppColors, GlassEffects)
├── models/                        # Data models (Track, RadioMetadata)
├── providers/                     # State management (radio_provider, videos_provider)
├── screens/                       # Screen implementations (home, radio, videos, about)
├── services/                      # Business logic (audio_player, icecast, storage, api)
└── widgets/                       # Reusable UI (liquid_glass_container, liquid_button, mesh_gradient_background)
```

## Code Style Guidelines

### Imports Organization
Order: 1) Dart SDK (`dart:*`) → 2) Flutter SDK (`package:flutter/*`) → 3) Third-party packages → 4) Local imports (relative)

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
```

### Naming Conventions
- **Classes**: `PascalCase` (e.g., `RadioProvider`, `AudioPlayerService`)
- **Files**: `snake_case.dart` (e.g., `audio_player_service.dart`)
- **Variables/Methods**: `camelCase` (e.g., `isPlaying`, `togglePlayPause`)
- **Constants**: `camelCase` with `static const` (e.g., `AppConstants.defaultVolume`)
- **Private members**: `_prefix` (e.g., `_audioService`, `_init()`)

### Formatting Rules
- **Indentation**: 2 spaces (standard Dart)
- **Line length**: 80 characters (soft limit)
- **Always use trailing commas** for better formatting
- **Use `const` constructors** wherever possible

```dart
// ✓ Good
LiquidGlassContainer(
  padding: const EdgeInsets.all(24),
  borderRadius: GlassEffects.radiusMedium,
  child: Text('Hello'),
);

// ✗ Bad
LiquidGlassContainer(padding: EdgeInsets.all(24), child: Text('Hello'));
```

### Type Annotations
- **Always specify types** for class properties and function return values
- Use **type inference** for local variables when obvious
- Prefer **explicit `Future<void>`** over dynamic

```dart
// ✓ Good
class RadioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  double _volume = 0.8;
  Future<void> play() async { ... }
}

// ✗ Bad
class RadioProvider extends ChangeNotifier {
  var _audioService;
  play() async { ... }
}
```

### State Management Pattern
- Use **Provider** for app-wide state
- Extend **ChangeNotifier** for observable state
- Call **`notifyListeners()`** after state changes
- **Dispose** resources in `dispose()` method

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
- Use **try-catch** for async operations
- Handle **null safely** with `?`, `??`, null checks
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

### Documentation
- Use **`///`** for public API docs
- Use **`//`** for implementation comments
- Document **class purpose** and **public methods**
- Avoid obvious comments

```dart
/// Provider for radio state management
class RadioProvider extends ChangeNotifier {
  /// Play the radio stream
  Future<void> play() async { ... }
}
```

## Design System - Liquid Glass

### Key Colors & Effects
```dart
// Colors (AppColors)
AppColors.darkBackgroundDeep    // #0B0118 - Main background
AppColors.primary               // #A855F7 - Violet accent
AppColors.glassBackground       // rgba(255,255,255,0.08)

// Glass Effects (GlassEffects)
GlassEffects.blurIntensity      // 24.0 - Main blur
GlassEffects.radiusMedium       // 24.0 - Border radius
```

### Key Widgets
- **LiquidGlassContainer**: Glass morphism container with blur
- **LiquidButton**: Animated glass buttons
- **MeshGradientBackground**: Animated gradient background
- **CurvedGlassViewer**: Curved top glass container

### Layout Guidelines
- Use **SafeArea** for screen boundaries
- Apply **24px horizontal padding** for content
- Use **Stack** for overlaying components (not Column with Expanded + fixed heights)
- Add **bottom padding** to scrollable content for fixed bottom elements
- **Never use negative margins** (Flutter constraint violation)

## Performance Best Practices
- **Minimize BackdropFilter usage** - expensive operation
- Use **const constructors** wherever possible
- **Dispose** AnimationControllers and StreamSubscriptions
- Avoid **nested BackdropFilters**
- Use **RepaintBoundary** for complex animated widgets

## Reference Documentation
- `COMPONENT_GUIDE.md` - UI component specifications
- `LIQUID_GLASS_IMPLEMENTATION.md` - Design system details
- `BUGFIXES.md` - Common issues and solutions
- `design.html` - Visual design reference

## Development Notes
- App is **fixed to dark mode** (ThemeMode.dark)
- Uses **portrait orientation only**
- Dart SDK: ^3.10.4
- Audio streaming via **Icecast** metadata polling
- Linting: Uses `package:flutter_lints/flutter.yaml`
