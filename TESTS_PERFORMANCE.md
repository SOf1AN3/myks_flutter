# Guide de Tests - Optimisations Page d'Accueil

## 🎯 Objectif
Valider que les optimisations ont amélioré les performances de ~30 FPS à 55-60 FPS

---

## ⚡ Test Rapide (2 minutes)

### 1. Activer l'Overlay FPS
```dart
// lib/main.dart - ligne 19
MaterialApp(
  showPerformanceOverlay: true,  // ⚡ DÉCOMMENTER
  title: 'Myks Radio',
  // ...
)
```

### 2. Lancer l'app
```bash
flutter run
```

### 3. Observer les FPS
**Page d'accueil (AVANT tap vidéo) :**
- ✅ **Attendu : 55-60 FPS** (barre verte pleine)
- ❌ Avant : ~30 FPS (barre verte à moitié)

**Après tap "Charger la vidéo" :**
- ✅ **Attendu : 50-55 FPS** (acceptable)
- ❌ Avant : ~25 FPS

---

## 🔬 Test Détaillé (DevTools)

### 1. Lancer en mode Profile
```bash
flutter run --profile
```

### 2. Ouvrir DevTools
```bash
# Dans un autre terminal
flutter pub global activate devtools
flutter pub global run devtools
```

### 3. Tests Performance

#### A. Timeline View
1. Onglet "Performance"
2. Cliquer "Record"
3. Naviguer vers page d'accueil
4. Attendre 5 secondes
5. Stop recording

**Vérifications :**
- [ ] Frame time moyen <16ms (avant tap vidéo)
- [ ] Pas de barres rouges (janks)
- [ ] GPU time <10ms

#### B. Memory View
1. Onglet "Memory"
2. Cliquer "Record"
3. Naviguer page d'accueil
4. Attendre 5 secondes
5. Tap "Charger vidéo"
6. Attendre 5 secondes
7. Retour arrière
8. Stop recording

**Vérifications :**
- [ ] Heap avant tap : ~140 MB
- [ ] Heap après tap : ~200 MB
- [ ] Heap après retour : revient à ~140 MB (pas de leak)

---

## 📱 Test sur Device Low-End

### Devices Recommandés
- Galaxy A14
- Moto G Power
- Redmi Note 8

### Checklist
- [ ] App démarre en <3s
- [ ] Page d'accueil fluide (45-50 FPS minimum)
- [ ] Thumbnail charge en <1s
- [ ] Scroll fluide
- [ ] Tap vidéo → player charge en <3s
- [ ] Pas de freeze/crash

---

## ✅ Critères de Succès

| Métrique | Cible | Comment Mesurer |
|----------|-------|-----------------|
| FPS avant tap | ≥55 | Overlay FPS / DevTools |
| FPS après tap | ≥50 | Overlay FPS / DevTools |
| Frame time | <16ms | DevTools Timeline |
| Memory avant tap | <150 MB | DevTools Memory |
| Memory après tap | <220 MB | DevTools Memory |
| Jank count | <10% | DevTools Timeline |
| Cold start | <3s | Chronomètre |

---

## 🐛 Troubleshooting

### Problème : FPS toujours bas (~30)
**Solutions :**
1. Vérifier que c'est bien en mode Release/Profile (pas Debug)
2. Vérifier que thumbnail s'affiche (pas le player)
3. Checker logs : `flutter logs | grep PERFORMANCE`

### Problème : Thumbnail ne s'affiche pas
**Solutions :**
1. Vérifier connexion internet
2. Vérifier URL thumbnail dans logs
3. Tester avec featured video différente

### Problème : Player ne charge pas après tap
**Solutions :**
1. Vérifier logs : `flutter logs | grep YouTube`
2. Vérifier que `_controllerInitialized` passe à true
3. Vérifier que setState() est appelé

---

## 📊 Logs à Surveiller

```bash
# Activer logs verbeux
flutter run --profile -v

# Filtrer les logs pertinents
flutter logs | grep -E "(FPS|PERFORMANCE|YouTube|Memory)"
```

---

## 🎬 Comportement Attendu

### Scénario 1 : Utilisateur ne clique PAS la vidéo
```
1. Page charge
2. Thumbnail s'affiche (image statique)
3. 60 FPS constant ✅
4. Memory stable ~140 MB ✅
```

### Scénario 2 : Utilisateur clique la vidéo
```
1. Page charge (60 FPS)
2. Thumbnail affiché
3. User tap "Charger la vidéo"
4. Loading indicator (CircularProgressIndicator)
5. Player s'initialise (2-3s)
6. Player affiché, FPS ~50-55 ✅
7. Memory ~200 MB ✅
```

### Scénario 3 : Navigation retour
```
1. User sur page d'accueil avec player chargé
2. Navigate vers autre page
3. Retour page d'accueil
4. Player RESTE chargé (ne re-init pas)
5. FPS ~50-55 ✅
```

---

## ⏱️ Temps Estimés

| Test | Durée |
|------|-------|
| Test rapide (overlay FPS) | 2 min |
| Test DevTools complet | 10 min |
| Test device low-end | 5 min |
| **Total** | **~20 min** |

---

## 📝 Template de Rapport

```markdown
## Résultats Tests Performance

**Date :** 
**Device :** 
**Flutter Version :** 

### Métriques

| Métrique | Avant | Après | Statut |
|----------|-------|-------|--------|
| FPS (avant tap) | 30 | ___ | ✅/❌ |
| FPS (après tap) | 25 | ___ | ✅/❌ |
| Memory (avant) | 200 MB | ___ | ✅/❌ |
| Memory (après) | 220 MB | ___ | ✅/❌ |
| Cold start | 3s | ___ | ✅/❌ |

### Observations
- 
- 

### Issues
- 
- 

### Conclusion
✅ Optimisations validées / ❌ Problèmes détectés
```

---

**Prêt à tester !** 🚀
