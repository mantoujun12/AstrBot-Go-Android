import 'package:flutter_test/flutter_test.dart';
import 'package:astrbot_go/main.dart';

void main() {
  testWidgets('home shows the app title and early-development banner',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AstrBotGoApp());

    expect(find.text('AstrBot Go'), findsOneWidget);
    expect(find.text('Early development'), findsOneWidget);
    expect(find.text('Instances'), findsOneWidget);
    expect(find.text('Versions'), findsOneWidget);
    expect(find.text('Logs'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
