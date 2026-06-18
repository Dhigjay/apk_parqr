import 'package:flutter_test/flutter_test.dart';
import 'package:parqr/main.dart';

void main() {
  testWidgets('shows splash then navigates to login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('ParQr'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Masuk'), findsOneWidget);
  });
}
