import 'package:flutter_test/flutter_test.dart';
import 'package:pronunciation_app/main.dart';

void main() {
  testWidgets('VocalisApp basic pump test', (WidgetTester tester) async {
    await tester.pumpWidget(const VocalisApp());
    expect(find.textContaining('Vocalis'), findsOneWidget);
  });
}
