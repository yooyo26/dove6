// Smoke test — verifies the app starts without crashing
import 'package:flutter_test/flutter_test.dart';
import 'package:dove6_client/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const Dove6App());
    await tester.pump();
  });
}
