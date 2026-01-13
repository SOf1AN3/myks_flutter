# Recommandations de Monitoring - Myks Radio Performance

**Date:** 13 Janvier 2026  
**Objectif:** Surveillance continue de la performance en production

---

## 🎯 Métriques Critiques à Surveiller

### 1. Performance Écran d'Accueil

#### FPS (Frames Per Second)
- **Cible:** ≥ 55 FPS
- **Seuil d'alerte:** < 50 FPS
- **Seuil critique:** < 45 FPS

**Mesure:**
```dart
import 'package:flutter/scheduler.dart';

class FPSMonitor {
  static final List<double> _fpsHistory = [];
  
  static void startMonitoring() {
    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final timing in timings) {
        final fps = 1000000 / timing.totalSpan.inMicroseconds;
        _fpsHistory.add(fps);
        
        if (_fpsHistory.length > 60) {
          final avgFPS = _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
          
          if (avgFPS < 50) {
            // Envoyer alerte
            FirebasePerformance.instance.sendCustomMetric(
              'low_fps_detected',
              {'screen': 'home', 'avg_fps': avgFPS},
            );
          }
          
          _fpsHistory.clear();
        }
      }
    });
  }
}
```

#### Temps de Chargement Écran
- **Cible:** < 500ms
- **Seuil d'alerte:** > 1000ms
- **Seuil critique:** > 2000ms

**Mesure:**
```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _loadTrace = FirebasePerformance.instance.newTrace('home_screen_load');
  
  @override
  void initState() {
    super.initState();
    _loadTrace.start();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadTrace.stop();
    });
  }
}
```

---

### 2. Utilisation Mémoire

#### Consommation RAM
- **Cible (sans vidéo):** < 150 MB
- **Cible (avec vidéo):** < 200 MB
- **Seuil d'alerte:** > 250 MB
- **Seuil critique:** > 300 MB

**Mesure:**
```dart
import 'dart:developer' as developer;

class MemoryMonitor {
  static Future<void> logMemoryUsage(String label) async {
    final info = await developer.Service.getVM();
    final heapSize = info.heaps?.first.capacity ?? 0;
    final heapUsed = info.heaps?.first.used ?? 0;
    
    debugPrint('[$label] Memory: ${heapUsed ~/ 1024 ~/ 1024} MB / ${heapSize ~/ 1024 ~/ 1024} MB');
    
    if (heapUsed > 250 * 1024 * 1024) {
      FirebasePerformance.instance.sendCustomMetric(
        'high_memory_usage',
        {'location': label, 'mb': heapUsed ~/ 1024 ~/ 1024},
      );
    }
  }
}

// Utilisation:
// await MemoryMonitor.logMemoryUsage('before_video_load');
// _initializeYouTubeController(video);
// await MemoryMonitor.logMemoryUsage('after_video_load');
```

#### Fuites Mémoire
- **Cible:** Pas de croissance > 10 MB après 5 navigations
- **Mesure:** DevTools Memory → Snapshot avant/après sessions

---

### 3. Performance YouTube Player

#### Taux d'Initialisation du Lecteur
- **Métrique:** % d'utilisateurs qui tapent le thumbnail
- **Objectif:** Mesurer l'engagement

**Mesure:**
```dart
void _onVideoTapToLoad() {
  // Analytics
  FirebaseAnalytics.instance.logEvent(
    name: 'video_player_loaded',
    parameters: {
      'video_id': featuredVideo!.youtubeId,
      'from_screen': 'home',
    },
  );
  
  // Performance trace
  final trace = FirebasePerformance.instance.newTrace('youtube_init');
  trace.start();
  
  setState(() => _isLoadingVideo = true);
  SchedulerBinding.instance.addPostFrameCallback((_) {
    setState(() {
      _shouldLoadVideo = true;
      _isLoadingVideo = false;
    });
    _initializeYouTubeController(featuredVideo!);
    trace.stop();
  });
}
```

#### Temps d'Initialisation YouTube
- **Cible:** < 2000ms
- **Seuil d'alerte:** > 3000ms

---

## 📊 Dashboard de Métriques Recommandé

### Firebase Console - Custom Traces

1. **home_screen_load** (Trace)
   - Métrique: Duration (ms)
   - Segmentation: Device model, OS version

2. **youtube_init** (Trace)
   - Métrique: Duration (ms)
   - Métrique custom: memory_before_mb, memory_after_mb
   - Segmentation: Network type (wifi/cellular)

3. **low_fps_detected** (Événement)
   - Paramètre: avg_fps, screen
   - Alerte: Si > 5% des utilisateurs

4. **high_memory_usage** (Événement)
   - Paramètre: location, mb
   - Alerte: Si > 10% des utilisateurs

---

## 🔔 Alertes Recommandées

### Alerte Critique #1: FPS Dégradé
**Condition:** FPS moyen écran d'accueil < 45 pendant 1 heure  
**Action:** 
1. Vérifier Firebase Performance
2. Checker logs Crashlytics
3. Rollback si nécessaire

### Alerte Critique #2: Crash Rate Élevé
**Condition:** Crash rate > 1% sur 24h  
**Action:**
1. Identifier stack trace commune
2. Désactiver feature problématique
3. Hotfix d'urgence

### Alerte Warning #1: Mémoire Haute
**Condition:** Utilisation RAM > 250 MB pour 20% users  
**Action:**
1. Analyser heap dump
2. Vérifier fuites mémoire
3. Planifier optimisation

### Alerte Info #1: Faible Engagement Vidéo
**Condition:** < 30% utilisateurs tapent thumbnail  
**Action:**
1. A/B test design thumbnail
2. Considérer auto-play optionnel
3. Améliorer CTA

---

## 🛠️ Outils de Monitoring

### 1. Firebase Performance Monitoring

**Setup:**
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_performance: ^0.9.3
  firebase_analytics: ^10.7.4
```

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  runApp(const MyksRadioApp());
}
```

### 2. Flutter DevTools (Développement)

**Lancer:**
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

**Widgets à surveiller:**
- **Performance → Timeline:** Frame times, shader compilation
- **Memory → Heap:** Fuites, objets non-disposés
- **Network → HTTP:** Latence API, taille responses

### 3. Sentry (Erreurs & Performance)

**Alternative/Complément à Firebase:**
```yaml
dependencies:
  sentry_flutter: ^7.14.0
```

```dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'YOUR_DSN';
    options.tracesSampleRate = 0.2; // 20% des transactions
    options.enableAutoPerformanceTracing = true;
  },
  appRunner: () => runApp(const MyksRadioApp()),
);
```

---

## 📈 Objectifs de Performance Long Terme

### Q1 2026
- [ ] FPS moyen écran d'accueil: 55+ (95th percentile)
- [ ] Temps chargement écran < 500ms (p50)
- [ ] Crash rate < 0.5%
- [ ] Utilisation RAM < 180 MB (p95)

### Q2 2026
- [ ] FPS toutes screens: 60 (p95)
- [ ] Zero memory leaks détectés
- [ ] Temps init YouTube < 1500ms (p50)
- [ ] Battery drain < 5% par 30min usage

### Q3 2026
- [ ] Support Flutter 3.19+ (dernière stable)
- [ ] Migration vers youtube_explode_dart (plus léger)
- [ ] App size < 35 MB (actuellement 41.9 MB)

---

## 🧪 Tests de Régression Performance

### Test Automatisé #1: Frame Time Budget

```dart
testWidgets('Home screen meets frame time budget', (tester) async {
  await tester.pumpWidget(const MyksRadioApp());
  await tester.pumpAndSettle();
  
  final binding = tester.binding;
  final List<Duration> frameDurations = [];
  
  binding.addTimingsCallback((timings) {
    frameDurations.addAll(timings.map((t) => t.totalSpan));
  });
  
  // Simuler scroll
  await tester.drag(find.byType(ListView), const Offset(0, -200));
  await tester.pumpAndSettle();
  
  // Vérifier que 95% des frames < 16ms (60 FPS)
  frameDurations.sort();
  final p95 = frameDurations[(frameDurations.length * 0.95).toInt()];
  expect(p95.inMilliseconds, lessThan(16));
});
```

### Test Automatisé #2: Memory Baseline

```dart
testWidgets('Home screen memory usage is acceptable', (tester) async {
  final memoryBefore = await getMemoryUsage();
  
  await tester.pumpWidget(const MyksRadioApp());
  await tester.pumpAndSettle();
  
  final memoryAfter = await getMemoryUsage();
  final memoryIncrease = memoryAfter - memoryBefore;
  
  expect(memoryIncrease, lessThan(60 * 1024 * 1024)); // < 60 MB
});
```

### Test Manuel Hebdomadaire

**Checklist:**
- [ ] Lancer app en mode profile
- [ ] Activer FPS overlay
- [ ] Visiter chaque écran 3× et noter FPS min/max/avg
- [ ] Charger lecteur YouTube, vérifier RAM avant/après
- [ ] Naviguer entre écrans 10×, vérifier pas de leak
- [ ] Documenter résultats dans spreadsheet

---

## 🚨 Plan d'Action si Performance Dégrade

### Étape 1: Identifier la Régression
```bash
# Comparer profiles entre versions
flutter run --profile --trace-startup
# Analyser trace dans DevTools
```

### Étape 2: Isoler la Cause
1. **Git bisect** pour trouver commit problématique:
   ```bash
   git bisect start
   git bisect bad HEAD  # Version actuelle lente
   git bisect good v1.0.0  # Dernière version rapide
   # Flutter run --profile et tester à chaque étape
   ```

2. **Profiler le code:**
   ```bash
   flutter run --profile --trace-skia
   # Ouvrir Chrome DevTools → Performance
   ```

### Étape 3: Corriger
- Si widget: Ajouter `const`, `RepaintBoundary`
- Si animation: Réduire durée, utiliser `AnimatedBuilder`
- Si I/O: Ajouter cache, async/await approprié
- Si third-party: Chercher alternative ou lazy-load

### Étape 4: Valider Fix
1. Lancer tests performance automatisés
2. Tester manuellement sur appareil réel
3. Déployer en beta (Firebase App Distribution)
4. Monitorer métriques 24h avant prod

---

## 📝 Checklist de Release

Avant chaque release production:

- [ ] `flutter analyze` 0 erreurs
- [ ] `flutter test` tous les tests passent
- [ ] FPS overlay vérifié sur device réel ≥ 55 FPS
- [ ] Memory profiling OK (< 200 MB après 10 min usage)
- [ ] Crash rate beta < 0.5%
- [ ] Firebase Performance traces configurées
- [ ] Version bumped dans `pubspec.yaml` et `build.gradle`
- [ ] Changelog mis à jour avec notes performance
- [ ] Screenshots/vidéos demo mises à jour si UI change

---

## 📚 Ressources

### Documentation Flutter
- [Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Performance Profiling](https://docs.flutter.dev/perf/ui-performance)
- [DevTools Memory View](https://docs.flutter.dev/tools/devtools/memory)

### Outils Externes
- [Firebase Performance](https://firebase.google.com/docs/perf-mon)
- [Sentry Flutter](https://docs.sentry.io/platforms/flutter/)
- [Flutter Gherkin](https://pub.dev/packages/flutter_gherkin) - Tests E2E

### Benchmarks Industrie
- Mobile apps cible: 60 FPS constant
- Temps chargement acceptable: < 1s
- Memory baseline typique: 100-150 MB
- Crash rate acceptable: < 1%

---

**Note finale:** Ce document doit être mis à jour trimestriellement avec les nouvelles métriques et seuils basés sur les données réelles de production.
