import 'package:flutter_test/flutter_test.dart';
import 'package:inspiration_app/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const InspirationApp());
    expect(find.text('心流屋'), findsOneWidget);
  });
}
