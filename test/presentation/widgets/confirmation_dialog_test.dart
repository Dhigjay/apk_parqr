import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parqr/presentation/widgets/confirmation_dialog.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('ConfirmationDialog', () {
    testWidgets('approve dialog shows correct title and confirm button', (tester) async {
      await tester.pumpWidget(buildTestApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ConfirmationDialog.showApprove(context, businessName: 'Parkir Sejahtera'),
            child: const Text('Open'),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Setujui Pengajuan'), findsOneWidget);
      expect(find.text('Setujui'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.textContaining('Parkir Sejahtera'), findsOneWidget);
    });

    testWidgets('reject dialog shows title, reason field, and reject button', (tester) async {
      await tester.pumpWidget(buildTestApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ConfirmationDialog.showReject(context, businessName: 'Parkir Sejahtera'),
            child: const Text('Open'),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Tolak Pengajuan'), findsOneWidget);
      expect(find.text('Tolak'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('tapping Batal dismisses dialog', (tester) async {
      await tester.pumpWidget(buildTestApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ConfirmationDialog.showApprove(context, businessName: 'Test'),
            child: const Text('Open'),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Setujui Pengajuan'), findsOneWidget);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Setujui Pengajuan'), findsNothing);
    });
  });
}
