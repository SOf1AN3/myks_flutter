# Analyse des Logs Android - Problèmes Identifiés

Date: 10 janvier 2026
App: Myks Radio Flutter

## 🔴 Problèmes Critiques

### 1. OnBackInvokedCallback manquant (API 33+)
**Symptôme:**
```
W/WindowOnBackDispatcher: OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher: Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
```

**Impact:** Gestion du bouton retour défectueuse sur Android 13+

**Solution:** ✅ CORRIGÉ - Ajout de `android:enableOnBackInvokedCallback="true"` dans AndroidManifest.xml

**Fichier:** `android/app/src/main/AndroidManifest.xml`

---

### 2. Déconnexion de l'appareil
**Symptôme:**
```
Lost connection to device.
```

**Contexte:** Arrive après la pause de l'AudioTrack
```
D/AudioTrack(21644): pause(5546): 0xb400006f770db630
Lost connection to device.
```

**Causes possibles:**
1. Crash de l'application (non visible dans les logs)
2. Problème de gestion mémoire
3. Erreur dans le service audio en arrière-plan
4. Exception non catchée

**Recommandations:**
- Ajouter plus de logging dans `AudioPlayerService`
- Vérifier la gestion des erreurs dans `RadioProvider`
- Tester avec `flutter run --verbose` pour plus de détails

---

## ⚠️ Avertissements Importants

### 3. Erreurs SSL/TLS avec YouTube
**Symptôme:**
```
E/chromium: [ERROR:net/socket/ssl_client_socket_impl.cc:916] handshake failed; returned -1, SSL error code 1, net_error -200
```

**Impact:** Échec de chargement de certaines ressources YouTube

**Causes possibles:**
- Certificat SSL expiré ou invalide
- Problème de réseau
- Restriction du réseau (pare-feu, proxy)

**Solution:**
- Vérifier la configuration réseau
- Ajouter un meilleur error handling pour les WebViews
- Considérer un fallback si YouTube ne charge pas

---

### 4. Problème Cross-Origin YouTube
**Symptôme:**
```
I/chromium: [INFO:CONSOLE:194] "Failed to execute 'postMessage' on 'DOMWindow': 
The target origin provided ('https://www.youtube.com') does not match the recipient 
window's origin ('https://youtube-nocookie.com')."
```

**Impact:** Communication entre iframe YouTube et app potentiellement défectueuse

**Solution:** 
- Vérifier la configuration de `flutter_inappwebview`
- S'assurer que les origines sont bien configurées
- Considérer utiliser uniquement `youtube-nocookie.com` partout

**Fichier à vérifier:** `lib/screens/videos/widgets/video_player_modal.dart`

---

### 5. Permissions audio manquantes (si nécessaire)
**Symptôme:**
```
W/cr_media: Requires MODIFY_AUDIO_SETTINGS and RECORD_AUDIO. No audio device will be available for recording
W/cr_media: BLUETOOTH_CONNECT permission is missing.
```

**Impact:** Fonctionnalités audio limitées

**Action nécessaire SEULEMENT SI vous prévoyez:**
- Enregistrement audio
- Contrôle Bluetooth avancé
- Modification des paramètres audio

**Permissions à ajouter (si nécessaire):**
```xml
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<!-- Pour Android 12+ -->
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

---

## ℹ️ Informations / Warnings Non-Critiques

### 6. Feature 'web-share' non reconnue
```
I/chromium: [INFO:CONSOLE:178] "Unrecognized feature: 'web-share'."
```
**Impact:** Mineur - fonctionnalité de partage web non disponible dans WebView
**Action:** Aucune nécessaire, c'est normal dans un contexte Android WebView

---

### 7. Nombreux warnings libc (vendor properties)
```
W/libc: Access denied finding property "vendor.camera.aux.packagelist"
W/libc: Access denied finding property "ro.vendor.display.iris_x7.support"
```
**Impact:** Aucun - warnings normaux du système Xiaomi MIUI
**Action:** Aucune

---

### 8. Messages MMUD et libMEOW
```
D/libMEOW: meow new tls: 0xb400006e67a3d9f0
D/MMUD: mtk_memory_debug_init com.example.myks_radio
```
**Impact:** Aucun - système de debug MediaTek (chipset du téléphone)
**Action:** Aucune

---

## 🎵 Observations Audio

### Lecture Audio Réussie
✅ **AAudioStream** initialisé correctement (s#1, 48000Hz, 2 canaux)
✅ **MediaCodec** VP9 (vidéo) et AAC (audio) démarrés avec succès
✅ **AudioTrack** créé et démarré sans erreur
✅ **Lecture/pause** fonctionne normalement

**Cependant:**
- La déconnexion survient immédiatement après une pause
- Cela suggère un problème dans la gestion du cycle de vie audio

---

## 📊 Statistiques Mémoire

```
NativeAlloc concurrent mark compact GC freed XXX KB
```
**Observations:**
- Plusieurs GC (Garbage Collections) effectués
- Valeurs normales (200-600KB libérés par GC)
- Pas de OutOfMemory apparent
- ✅ Gestion mémoire semble OK

---

## 🔧 Actions Recommandées

### Priorité 1 (Critique)
- [x] ~~Ajouter `android:enableOnBackInvokedCallback="true"` au manifest~~ ✅ FAIT
- [ ] Investiguer la cause de "Lost connection to device"
  - Ajouter try-catch global dans `main.dart`
  - Logger les erreurs dans `AudioPlayerService.pause()`
  - Tester la gestion des ressources audio

### Priorité 2 (Important)
- [ ] Améliorer la gestion d'erreur SSL dans les WebViews
- [ ] Vérifier la configuration YouTube cross-origin
- [ ] Ajouter un error boundary pour les crashes silencieux

### Priorité 3 (Nice to have)
- [ ] Documenter les permissions optionnelles
- [ ] Ajouter analytics/crash reporting (Firebase Crashlytics?)
- [ ] Optimiser la gestion mémoire des WebViews

---

## 📝 Notes de Test

**Appareil testé:** Xiaomi 2409BRN2CY (MIUI)
**Android Version:** API 35+ (Android 15 probable)
**Flutter Version:** 3.10+
**Scénario de crash:**
1. Application démarre ✅
2. Navigation entre écrans ✅
3. Lecture vidéo YouTube ✅
4. Lecture audio (ExoPlayer) ✅
5. Pause audio → **Lost connection** ❌

---

## 🔍 Prochaines Étapes

1. **Reproduire le crash** avec `flutter run --verbose`
2. **Ajouter logging** dans:
   - `lib/services/audio_player_service.dart`
   - `lib/providers/radio_provider.dart`
3. **Tester sur d'autres appareils** (non-Xiaomi)
4. **Vérifier les lifecycle hooks** Flutter
5. **Considérer** `audio_service` error callbacks

---

## 📚 Ressources

- [OnBackInvokedCallback Documentation](https://developer.android.com/about/versions/13/features/predictive-back-gesture)
- [Flutter WebView Best Practices](https://pub.dev/packages/flutter_inappwebview)
- [Audio Service Plugin](https://pub.dev/packages/audio_service)
- [Crash Reporting](https://firebase.google.com/docs/crashlytics)
