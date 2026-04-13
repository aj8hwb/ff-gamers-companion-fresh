import 'package:flutter_test/flutter_test.dart';
import 'package:ff_gamers_companion/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FFGamersApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('FF GAMERS'), findsOneWidget);
  });
}
