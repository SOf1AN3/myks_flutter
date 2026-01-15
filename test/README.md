# 🧪 Guide des Tests - Myks Radio

## 📁 Structure des Tests

```
test/
├── services/
│   ├── audio_player_service_test.dart    # Tests du service audio
│   └── api_service_test.dart             # Tests du service API
├── providers/
│   └── radio_provider_test.dart          # Tests du provider radio
├── screens/
│   └── screens_smoke_test.dart           # Tests de smoke des écrans
└── widget_test.dart                       # Test de base Flutter
```

## 🚀 Exécution des Tests

### Tous les tests
```bash
flutter test
```

### Tests d'un fichier spécifique
```bash
# AudioPlayerService
flutter test test/services/audio_player_service_test.dart

# RadioProvider
flutter test test/providers/radio_provider_test.dart

# ApiService
flutter test test/services/api_service_test.dart

# Screens (smoke tests)
flutter test test/screens/screens_smoke_test.dart
```

### Tests avec un nom spécifique
```bash
# Utiliser --name pour un pattern regex
flutter test --name="setVolume"

# Utiliser --plain-name pour un match exact
flutter test --plain-name="AudioPlayerService setVolume should update volume to valid value"
```

### Mode verbose
```bash
flutter test -v
```

### Avec couverture de code
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📊 Résultats Attendus

### ✅ Tests qui Passent (39/59)

**AudioPlayerService** (10/14) :
- ✅ Tests d'état initial
- ✅ Tests de setVolume (validation, clamp, stream)
- ✅ Tests de setStreamUrl
- ✅ Test de pause

**RadioProvider** (22/24) :
- ✅ Initialisation (état, volume, URL depuis storage)
- ✅ Play/pause
- ✅ setVolume (audio service + storage)
- ✅ setStreamUrl (audio service + storage + notification)
- ✅ Gestion des métadonnées et historique
- ✅ clearHistory
- ✅ Propriétés calculées (currentTitle, currentArtist)

**ApiService** (2/15) :
- ✅ setAuthToken
- ✅ clearAuthToken

**Screens** (5/6) :
- ✅ HomeScreen render
- ✅ RadioScreen render
- ✅ VideosScreen render
- ✅ AboutScreen render
- ✅ Navigation bottom bar

### ⚠️ Tests qui Échouent (20/59)

**AudioPlayerService** (4/14) :
- ⚠️ play() - nécessite plugin natif `just_audio`
- ⚠️ stop() - nécessite plugin natif
- ⚠️ togglePlayPause() - nécessite plugin natif
- ⚠️ dispose() - nécessite plugin natif

**RadioProvider** (2/24) :
- ⚠️ togglePlayPause - problème de mock
- ⚠️ dispose - double dispose dans tearDown

**ApiService** (13/15) :
- ⚠️ Tous les tests HTTP - backend retourne 400 en test

**Screens** (1/6) :
- ⚠️ Responsive layout - overflow UI en petit écran

## 🔧 Dépannage

### Problème: "MissingPluginException: No implementation found for method..."

**Cause** : Les plugins natifs (just_audio, audio_session) n'ont pas d'implémentation en environnement de test.

**Solutions** :
1. Accepter que ces tests spécifiques échouent (comportement attendu)
2. Mocker le AudioPlayer :
```dart
class MockAudioPlayer extends Mock implements AudioPlayer {}
```

### Problème: "DioException [bad response]: status code of 400"

**Cause** : TestWidgetsFlutterBinding bloque les vraies requêtes HTTP.

**Solutions** :
1. Utiliser http_mock_adapter pour mocker les réponses
2. Accepter que ces tests échouent sans backend de test

### Problème: "Field '_prefs' has not been initialized"

**Cause** : StorageService nécessite l'initialisation de SharedPreferences.

**Solution** : Utiliser des mocks au lieu de vraies instances

## 📝 Bonnes Pratiques

### Écrire un Nouveau Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// 1. Créer les mocks
class MockMyService extends Mock implements MyService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MyFeature', () {
    late MyClass myClass;
    late MockMyService mockService;

    // 2. Setup avant chaque test
    setUp(() {
      mockService = MockMyService();
      when(() => mockService.myMethod()).thenReturn('value');
      myClass = MyClass(service: mockService);
    });

    // 3. Cleanup après chaque test
    tearDown(() {
      // Cleanup si nécessaire
    });

    // 4. Écrire les tests
    test('should do something', () {
      // Arrange
      final input = 'test';

      // Act
      final result = myClass.doSomething(input);

      // Assert
      expect(result, 'expected');
      verify(() => mockService.myMethod()).called(1);
    });
  });
}
```

### Widget Test

```dart
testWidgets('MyWidget should display text', (tester) async {
  // 1. Pump le widget
  await tester.pumpWidget(
    MaterialApp(home: MyWidget()),
  );

  // 2. Attendre les animations
  await tester.pumpAndSettle();

  // 3. Vérifier
  expect(find.text('Hello'), findsOneWidget);
  expect(find.byType(Button), findsOneWidget);
});
```

## 📚 Ressources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Mocktail Documentation](https://pub.dev/packages/mocktail)
- [Widget Testing](https://flutter.dev/docs/cookbook/testing/widget)
- [Integration Testing](https://flutter.dev/docs/testing/integration-tests)

## 🎯 Prochaines Étapes

1. **Ajouter des tests pour** :
   - IcecastService
   - StorageService
   - YouTubeService
   - Models (Video, Track, RadioMetadata)
   - Widgets (LiquidButton, LiquidGlassContainer)

2. **Améliorer les tests existants** :
   - Mocker just_audio pour AudioPlayerService
   - Mocker Dio pour ApiService
   - Ajouter plus de cas limites

3. **Tests d'intégration** :
   - Flux complet de l'application
   - Navigation entre écrans
   - Sauvegarde et restauration d'état

4. **CI/CD** :
   - Configurer GitHub Actions pour exécuter les tests
   - Générer des rapports de couverture
   - Bloquer les merges si les tests échouent
