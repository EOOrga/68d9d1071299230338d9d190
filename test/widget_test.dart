import 'package:besnard_christian/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows seeded rental dashboard and navigates to work log', (
    tester,
  ) async {
    await tester.pumpWidget(const OthmanGoldCarApp(screenshotMode: true));

    expect(find.text('Rental control'), findsOneWidget);
    expect(find.text('Open records'), findsOneWidget);

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    expect(find.text('Daily work log'), findsOneWidget);
    expect(find.text('Check-out inspection — Range Rover'), findsOneWidget);
  });

  testWidgets('creates a local rental record', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const OthmanGoldCarApp(screenshotMode: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-record-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('record-title-field')),
      'BMW X5 weekend booking',
    );
    await tester.enterText(
      find.byKey(const Key('record-reference-field')),
      'BK-220',
    );
    await tester.enterText(
      find.byKey(const Key('record-notes-field')),
      'Pickup confirmed with deposit.',
    );
    await tester.drag(
      find.byKey(const Key('record-form-scroll')),
      const Offset(0, -520),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-record-button')));
    await tester.pumpAndSettle();

    expect(find.text('BMW X5 weekend booking'), findsOneWidget);
  });
}
