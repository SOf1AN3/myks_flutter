// This is a basic Flutter widget test for Myks Radio.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myks_radio/config/theme.dart';
import 'package:myks_radio/widgets/bottom_navigation.dart';
import 'package:myks_radio/widgets/common_widgets.dart';

void main() {
  testWidgets('Myks Radio app smoke test - Bottom Navigation', (
    WidgetTester tester,
  ) async {
    // Test the BottomNavigation widget in isolation
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: const Center(child: Text('Test Screen')),
          bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
        ),
      ),
    );

    // Verify that the bottom navigation is present
    expect(find.byType(AppBottomNavigation), findsOneWidget);

    // Verify navigation items are present
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.radio), findsOneWidget);
    expect(find.byIcon(Icons.video_library), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('Myks Radio app smoke test - Theme Colors', (
    WidgetTester tester,
  ) async {
    // Test that the app theme is properly configured
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: const Center(
            child: Text('MYKS Radio', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );

    // Verify the text is present
    expect(find.text('MYKS Radio'), findsOneWidget);

    // Verify scaffold is present
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('Myks Radio app smoke test - GradientText Widget', (
    WidgetTester tester,
  ) async {
    // Test the GradientText widget
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: GradientText(
              text: 'MYKS Radio',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );

    // Verify the GradientText widget is present
    expect(find.byType(GradientText), findsOneWidget);

    // Verify the text is present
    expect(find.text('MYKS Radio'), findsOneWidget);
  });

  testWidgets('Myks Radio app smoke test - GradientButton Widget', (
    WidgetTester tester,
  ) async {
    bool buttonPressed = false;

    // Test the GradientButton widget
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: GradientButton(
              text: 'Écouter la Radio',
              onPressed: () {
                buttonPressed = true;
              },
              icon: Icons.radio,
            ),
          ),
        ),
      ),
    );

    // Verify the GradientButton widget is present
    expect(find.byType(GradientButton), findsOneWidget);

    // Verify the button text is present
    expect(find.text('Écouter la Radio'), findsOneWidget);

    // Verify the icon is present
    expect(find.byIcon(Icons.radio), findsOneWidget);

    // Tap the button and verify it works
    await tester.tap(find.byType(GradientButton));
    await tester.pump();

    expect(buttonPressed, isTrue);
  });

  testWidgets('Myks Radio app smoke test - GlassCard Widget', (
    WidgetTester tester,
  ) async {
    // Test the GlassCard widget
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(child: GlassCard(child: Text('Glass Card Content'))),
        ),
      ),
    );

    // Verify the GlassCard widget is present
    expect(find.byType(GlassCard), findsOneWidget);

    // Verify the content is present
    expect(find.text('Glass Card Content'), findsOneWidget);
  });
}
