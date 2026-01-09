# 🎨 Guide Visuel des Composants - Liquid Glass Design

## 📐 Structure de l'Interface Radio

```
┌─────────────────────────────────────────┐
│   ⌄    STREAMING NOW      ⋯            │  ← Header (40px buttons)
│        MYKS Radio                       │
├─────────────────────────────────────────┤
│                                         │
│   ╔═══════════════════════════════╗    │
│   ║  ▌▌▌▌▌▌▌▌▌▌ (Audio Bars)    ║    │  ← CurvedGlassViewer
│   ╚═══════════════════════════════╝    │     (200px height)
│                                         │
│      Vibe Urbaine Vol. 3                │  ← Track Title (32px)
│      Original Mix • 102.4 FM            │  ← Subtitle (18px violet)
│                                         │
│   ⏮    ◯ ▶ ◯    ⏭                     │  ← Controls
│       (48) (96) (48)                    │     (spacing: 32px)
│                                         │
│   🔇 ═════════ 🔊                       │  ← Volume Slider
│        (280px max)                      │
│                                         │
├─────────────────────────────────────────┤
│   ━                                     │  ← Handle
│   Live Community 🔴    2.4k Listening   │  ← Panel Header
│                                         │
│   ┌─────────────────────────────────┐  │
│   │ JD  Jean Dupont        2m ago   │  │  ← Comment
│   │     Le mix est incroyable !      │  │
│   └─────────────────────────────────┘  │
│                                         │
│   🎵  Midnight City Remix        ⋮     │  ← Up Next
│       Up Next • 03:45                   │
│                                         │
├─────────────────────────────────────────┤
│   🏠      📻      🧭      👤            │  ← Bottom Nav
│         ●                               │     (dot indicator)
└─────────────────────────────────────────┘
```

## 🎨 Composants Créés

### 1. **MeshGradientBackground**
```
File: lib/widgets/mesh_gradient_background.dart
```
- Fond #0B0118
- 3 gradients radiaux :
  - Top-Left : violet 20%
  - Top-Right : violet 25%
  - Bottom-Center : violet foncé 40%

**Usage :**
```dart
MeshGradientBackground(
  child: YourContent(),
)
```

---

### 2. **LiquidGlassContainer**
```
File: lib/widgets/liquid_glass_container.dart
```

**Variantes :**

#### a) Container Principal
```dart
LiquidGlassContainer(
  padding: EdgeInsets.all(24),
  borderRadius: GlassEffects.radiusMedium, // 24px
  showInnerGlow: true,
  child: YourWidget(),
)
```

#### b) Control Button
```dart
LiquidControlContainer(
  size: 40,
  onTap: () {},
  child: Icon(Icons.menu),
)
```

#### c) Curved Glass Viewer
```dart
CurvedGlassViewer(
  height: 200,
  child: AudioBars(),
)
```

**Effets :**
- BackdropFilter blur: 24px
- Background: rgba(255,255,255,0.08)
- Border: rgba(255,255,255,0.12)
- Box shadows

---

### 3. **LiquidButton**
```
File: lib/widgets/liquid_button.dart
```

**Types :**

#### a) Play Button (96x96)
```dart
LiquidButton.play(
  isPlaying: true,
  isLoading: false,
  onTap: () => play(),
)
```
- Gradient violet semi-transparent
- Border blanc 30%
- Glow violet 40px
- Scale animation 0.95

#### b) Control Button (48x48)
```dart
LiquidButton.control(
  icon: Icons.skip_previous,
  onTap: () => previous(),
)
```
- Gradient glass blanc
- Opacité 70%

---

### 4. **AudioVisualizer**
```
File: lib/screens/radio/widgets/audio_visualizer.dart
```

**Spécifications :**
- **10 barres** fixes
- Hauteurs : `[48, 96, 64, 128, 80, 144, 96, 64, 112, 56]`
- Largeur : 5px
- Espacement : 6px
- Gradient : #A855F7 → #D8B4FE → #FFFFFF

**Usage :**
```dart
AudioVisualizer(
  isPlaying: radioProvider.isPlaying,
  height: 200,
)
```

**Animations :**
- Duration : 400-800ms aléatoire
- Curve : easeInOut
- Repeat : reverse

---

### 5. **PlayerControls**
```
File: lib/screens/radio/widgets/player_controls.dart
```

**Layout :**
```
     ⏮        ▶        ⏭
    (48)     (96)     (48)
  
      🔇 ═══════ 🔊
         (280px)
```

**Usage :**
```dart
PlayerControls(
  isPlaying: radioProvider.isPlaying,
  isLoading: radioProvider.isLoading,
  volume: radioProvider.volume,
  onTogglePlay: () => radioProvider.togglePlayPause(),
  onVolumeChange: (v) => radioProvider.setVolume(v),
)
```

**Volume Slider :**
- Track avec BackdropFilter
- Active : gradient violet + glow
- Icônes : 20px, opacity 40%

---

### 6. **LiveCommunityPanel**
```
File: lib/screens/radio/widgets/live_community_panel.dart
```

**Sections :**

#### a) Handle
- 48x4px
- Blanc 10%
- Centré

#### b) Header
```dart
Live Community 🔴    [2.4k Listening]
```
- Dot rouge 8px avec glow
- Badge semi-transparent

#### c) Comment Card
- Avatar gradient circulaire 40px
- Nom uppercase 11px bold
- Message 14px
- Timestamp 10px

#### d) Up Next Card
- Icône queue_music dans carré 48px
- Titre + durée
- Bouton more 32px

---

### 7. **RadioScreen**
```
File: lib/screens/radio/radio_screen.dart
```

**Structure :**
```dart
Scaffold(
  backgroundColor: transparent,
  body: MeshGradientBackground(
    child: SafeArea(
      child: Column([
        Header,
        Expanded(
          SingleChildScrollView(
            AudioVisualizer,
            TrackInfo,
            PlayerControls,
          ),
        ),
        LiveCommunityPanel,
      ]),
    ),
  ),
  bottomNavigationBar: AppBottomNavigation,
)
```

**Animations :**
- fadeIn + slideY
- Delays : 100, 200, 300, 400ms

---

### 8. **AppBottomNavigation**
```
File: lib/widgets/bottom_navigation.dart
```

**Design :**
- BackdropFilter blur 24px
- Background glass rgba(255,255,255,0.08)
- Border top rgba(255,255,255,0.1)
- 4 icônes : 28px
- Spacing : spaceBetween
- Active : violet + dot 4px

---

## 🎯 Constantes de Design

### Spacing
```dart
8px  : SizedBox(height: 8)
16px : SizedBox(height: 16)
24px : SizedBox(height: 24)
32px : SizedBox(height: 32)
40px : SizedBox(height: 40)
```

### Border Radius
```dart
GlassEffects.radiusSmall   = 12px
GlassEffects.radiusMedium  = 24px
GlassEffects.radiusLarge   = 40px
GlassEffects.radiusXLarge  = 48px
```

### Blur
```dart
GlassEffects.blurIntensity        = 24px
GlassEffects.blurIntensityControl = 12px
```

### Shadows
```dart
GlassEffects.glowShadow       // Violet glow
GlassEffects.glassShadow      // Depth shadow
GlassEffects.innerGlowShadow  // Inner glow
```

### Colors
```dart
AppColors.darkBackgroundDeep     // #0B0118
AppColors.primary                // #A855F7
AppColors.glassBackground        // rgba(255,255,255,0.08)
AppColors.glassBorder            // rgba(255,255,255,0.12)
AppColors.glassControlBg         // rgba(255,255,255,0.15)
AppColors.meshGradient1          // rgba(168,85,247,0.2)
AppColors.meshGradient2          // rgba(139,92,246,0.25)
AppColors.meshGradient3          // rgba(76,29,149,0.4)
```

---

## 📱 Responsive

### Contraintes
```dart
// Volume slider max width
maxWidth: 280

// Content padding
horizontal: 24
vertical: varies

// Safe area
top: system
bottom: 96 (nav + panel)
```

---

## 🔄 Animations

### Entry Animations (flutter_animate)
```dart
.animate()
  .fadeIn(duration: 400ms)
  .slideY(begin: 0.1, end: 0)
```

### Button Scale
```dart
AnimationController scale
Tween: 1.0 → 0.95
Duration: 100ms
```

### Audio Bars
```dart
Each bar: independent controller
Duration: 400-800ms random
Repeat: reverse
Curve: easeInOut
```

---

## 💡 Tips d'Utilisation

### Performance
- BackdropFilter est coûteux : limiter le nombre
- Dispose des AnimationControllers
- Éviter nested BackdropFilters

### Personnalisation
```dart
// Changer intensité blur
LiquidGlassContainer(
  blurIntensity: 32.0, // Plus intense
)

// Changer couleur border
borderColor: Colors.white.withOpacity(0.2),

// Désactiver inner glow
showInnerGlow: false,
```

### Debug
```dart
// Voir les containers
debugPaintSizeEnabled = true

// Désactiver blur temporairement
// Commenter BackdropFilter
```

---

## 📚 Fichiers Principaux

```
lib/
├── config/
│   └── theme.dart              ← Couleurs + GlassEffects
├── widgets/
│   ├── liquid_glass_container.dart
│   ├── mesh_gradient_background.dart
│   ├── liquid_button.dart
│   └── bottom_navigation.dart
└── screens/radio/
    ├── radio_screen.dart
    └── widgets/
        ├── audio_visualizer.dart
        ├── player_controls.dart
        └── live_community_panel.dart
```

---

**Référence Design** : design.html  
**Style** : Liquid Glass / Glassmorphism  
**Framework** : Flutter 3.10+
