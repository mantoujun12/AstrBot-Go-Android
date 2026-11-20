import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:astrbot_go/main.dart';

void main() {
  testWidgets('app shell builds with four navigation destinations',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AstrBotGoApp());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
  });

  testWidgets('Instances page pins the chat entry first',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AstrBotGoApp());

    expect(find.text('Chat'), findsOneWidget);
    expect(
      find.text('Talk to a running instance - no key needed to open'),
      findsOneWidget,
    );
    // The mock state ships two instances.
    expect(find.text('v4.29.3 · Port 6185'), findsOneWidget);
    expect(find.text('v4.28.1 · Port 6186'), findsOneWidget);
  });

  testWidgets('switching tabs shows each page', (WidgetTester tester) async {
    await tester.pumpWidget(const AstrBotGoApp());

    await tester.tap(find.text('Versions').last);
    await tester.pumpAndSettle();
    expect(find.text('Components'), findsOneWidget);
    expect(find.text('Installed'), findsWidgets);

    await tester.tap(find.text('Logs').last);
    await tester.pumpAndSettle();
    expect(find.text('All sources'), findsOneWidget);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    // Settings is a two-level menu: all categories on the first level.
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Network'), findsOneWidget);
    expect(find.text('Data & maintenance'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    // Tapping a category pushes the second-level page.
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('AstrBot Go'), findsOneWidget);
    expect(find.text('Version 0.1.0 (development)'), findsOneWidget);
    // Back to the shell before switching tabs again.
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Instances').last);
    await tester.pumpAndSettle();
    expect(find.text('Create instance'), findsOneWidget);
  });
}
