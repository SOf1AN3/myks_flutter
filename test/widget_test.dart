// This is a basic Flutter widget test for Myks Radio.

import 'package:flutter_test/flutter_test.dart';

import 'package:myks_radio/app.dart';

void main() {
  testWidgets('Myks Radio app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyksRadioApp());

    // Verify that the app starts successfully
    expect(find.text('Myks'), findsWidgets);
  });
}
