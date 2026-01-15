#!/usr/bin/env dart

/// Script d'analyse des contrastes de couleurs WCAG
/// Vérifie que les couleurs de l'application respectent les normes WCAG AA

import 'dart:math' as math;

void main() {
  print('═' * 70);
  print('  Analyse des contrastes de couleurs - Myks Radio');
  print('  Normes WCAG AA:');
  print('    - Texte normal: 4.5:1 minimum');
  print('    - Texte large (18pt+): 3.0:1 minimum');
  print('    - Éléments UI: 3.0:1 minimum');
  print('═' * 70);
  print('');

  final results = <ContrastCheck>[];

  // Fond principal
  const bgDeep = Color(0xFF0B0118);
  const bgDark = Color(0xFF0A0A0A);

  // Textes
  const textLight = Color(0xFFFAFAFA);
  const textMuted = Color(0xFFA3A3A3);

  // Couleurs primaires
  const primary = Color(0xFFA855F7);
  const primaryLight = Color(0xFF8B5CF6);
  const primaryDark = Color(0xFFA78BFA);

  // Couleurs UI
  const error = Color(0xFFEF4444);
  const success = Color(0xFF22C55E);
  const warning = Color(0xFFF59E0B);

  // Tests de contraste
  print('📝 Texte principal:');
  print('─' * 70);
  results.add(
    checkContrast(
      'Texte principal (blanc sur fond violet foncé)',
      bgDeep,
      textLight,
      4.5,
    ),
  );
  results.add(
    checkContrast(
      'Texte principal (blanc sur fond noir)',
      bgDark,
      textLight,
      4.5,
    ),
  );
  results.add(
    checkContrast(
      'Texte secondaire (gris sur fond violet foncé)',
      bgDeep,
      textMuted,
      4.5,
    ),
  );
  print('');

  print('🎨 Boutons et éléments interactifs:');
  print('─' * 70);
  results.add(
    checkContrast(
      'Bouton primaire (blanc sur violet)',
      primary,
      textLight,
      3.0,
      isLargeText: true,
    ),
  );
  results.add(checkContrast('Icône sur fond violet', primary, textLight, 3.0));
  print('');

  print('⚠️  Couleurs de statut:');
  print('─' * 70);
  results.add(
    checkContrast('Erreur (rouge sur fond foncé)', bgDeep, error, 3.0),
  );
  results.add(
    checkContrast('Succès (vert sur fond foncé)', bgDeep, success, 3.0),
  );
  results.add(
    checkContrast(
      'Avertissement (orange sur fond foncé)',
      bgDeep,
      warning,
      3.0,
    ),
  );
  print('');

  print('🎯 Navigation:');
  print('─' * 70);
  results.add(
    checkContrast('Icône navigation active (violet)', bgDeep, primary, 3.0),
  );
  results.add(
    checkContrast(
      'Icône navigation inactive (gris 40%)',
      bgDeep,
      Color(0x66FFFFFF), // 40% opacity white
      3.0,
    ),
  );
  print('');

  // Résumé
  print('═' * 70);
  print('  RÉSUMÉ');
  print('═' * 70);

  final passed = results.where((r) => r.passes).length;
  final failed = results.where((r) => !r.passes).length;

  print('✅ Tests réussis: $passed');
  print('❌ Tests échoués: $failed');
  print('📊 Total: ${results.length}');
  print('');

  if (failed > 0) {
    print('⚠️  Éléments nécessitant une attention:');
    print('─' * 70);
    for (final result in results.where((r) => !r.passes)) {
      print('  • ${result.name}');
      print(
        '    Ratio: ${result.ratio.toStringAsFixed(2)}:1 '
        '(requis: ${result.required}:1)',
      );
    }
    print('');
  }

  print('═' * 70);
  if (failed == 0) {
    print('  ✨ Tous les tests de contraste sont réussis!');
  } else {
    print('  ⚠️  Certains contrastes ne respectent pas WCAG AA');
  }
  print('═' * 70);
}

ContrastCheck checkContrast(
  String name,
  Color bg,
  Color fg,
  double required, {
  bool isLargeText = false,
}) {
  final ratio = calculateContrastRatio(bg, fg);
  final passes = ratio >= required;

  final status = passes ? '✅' : '❌';
  final textType = isLargeText ? 'Texte large' : 'Texte normal';

  print('$status $name');
  print(
    '   Ratio: ${ratio.toStringAsFixed(2)}:1 '
    '(requis: $required:1) - $textType',
  );

  return ContrastCheck(
    name: name,
    ratio: ratio,
    required: required,
    passes: passes,
  );
}

class ContrastCheck {
  final String name;
  final double ratio;
  final double required;
  final bool passes;

  ContrastCheck({
    required this.name,
    required this.ratio,
    required this.required,
    required this.passes,
  });
}

class Color {
  final int value;

  const Color(this.value);

  int get red => (value >> 16) & 0xFF;
  int get green => (value >> 8) & 0xFF;
  int get blue => value & 0xFF;
  int get alpha => (value >> 24) & 0xFF;
}

/// Calcule le ratio de contraste WCAG entre deux couleurs
/// https://www.w3.org/WAI/GL/wiki/Contrast_ratio
double calculateContrastRatio(Color color1, Color color2) {
  final l1 = relativeLuminance(color1);
  final l2 = relativeLuminance(color2);

  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);

  return (lighter + 0.05) / (darker + 0.05);
}

/// Calcule la luminance relative d'une couleur
/// https://www.w3.org/WAI/GL/wiki/Relative_luminance
double relativeLuminance(Color color) {
  final r = linearizeColorComponent(color.red / 255.0);
  final g = linearizeColorComponent(color.green / 255.0);
  final b = linearizeColorComponent(color.blue / 255.0);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double linearizeColorComponent(double component) {
  if (component <= 0.03928) {
    return component / 12.92;
  } else {
    return math.pow((component + 0.055) / 1.055, 2.4).toDouble();
  }
}
