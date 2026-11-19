import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:astrbot_go/main.dart';

void main() {
  testWidgets('app shell builds with four navigation destinations',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AstrBotGoApp());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('Early development'), findsOneWidget);
    expect(find.text('No instances yet'), findsOneWidget);
  });

  testWidgets('switching tabs shows each page', (WidgetTester tester) async {
    await tester.pumpWidget(const AstrBotGoApp());

    await tester.tap(find.text('Versions'));
    await tester.pumpAndSettle();
    expect(find.text('Free version selection from a signed catalog'),
        findsOneWidget);

    await tester.tap(find.text('Logs'));
    await tester.pumpAndSettle();
    expect(find.text('Live logs for each running instance'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Manual-only updates: the app never applies them on its '
        'own'), findsOneWidget);

    await tester.tap(find.text('Instances'));
    await tester.pumpAndSettle();
    expect(find.text('No instances yet'), findsOneWidget);
  });
}
