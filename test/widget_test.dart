import 'package:flutter_test/flutter_test.dart';
import 'package:codeacademy/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MyApp), findsOneWidget);
      // Wait for any immediate microtasks
      await Future.delayed(Duration.zero);
    });
  });
}
