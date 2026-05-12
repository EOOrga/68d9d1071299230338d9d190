import 'package:besnard_christian/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows seeded operations dashboard and navigates to work log', (
    tester,
  ) async {
    await tester.pumpWidget(const BesnardChristianApp(screenshotMode: true));

    expect(find.text('Operations control'), findsOneWidget);
    expect(find.text('Open records'), findsOneWidget);

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    expect(find.text('Daily work log'), findsOneWidget);
    expect(find.text('Outbound shipment LX-290'), findsOneWidget);
  });

  testWidgets('creates a local operations record', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BesnardChristianApp(screenshotMode: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-record-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('record-title-field')),
      'Receiving dock checklist',
    );
    await tester.enterText(
      find.byKey(const Key('record-reference-field')),
      'QC-220',
    );
    await tester.enterText(
      find.byKey(const Key('record-notes-field')),
      'Dock sweep completed.',
    );
    await tester.drag(
      find.byKey(const Key('record-form-scroll')),
      const Offset(0, -520),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-record-button')));
    await tester.pumpAndSettle();

    expect(find.text('Receiving dock checklist'), findsOneWidget);
  });
}
