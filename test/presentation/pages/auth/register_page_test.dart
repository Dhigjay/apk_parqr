import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/presentation/pages/auth/register_page.dart';
import 'package:parqr/presentation/blocs/auth/auth_bloc.dart';
import 'package:parqr/presentation/blocs/auth/auth_event.dart';
import 'package:parqr/presentation/blocs/auth/auth_state.dart';
import 'package:parqr/presentation/widgets/app_text_field.dart';
import 'package:parqr/presentation/widgets/app_button.dart';

class MockAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  MockAuthBloc() : super(AuthInitial());

  @override
  get authRepository => throw UnimplementedError();
}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  tearDown(() {
    mockAuthBloc.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const RegisterPage(),
      ),
    );
  }

  group('RegisterPage', () {
    testWidgets('renders name, email, phone, and password fields and register button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(AppTextField), findsNWidgets(4));
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('No. Handphone'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('shows validation error when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Scroll to the button to make it visible
      await tester.dragUntilVisible(
        find.byType(AppButton),
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(find.text('Nama wajib diisi'), findsOneWidget);
      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Nomor HP wajib diisi'), findsOneWidget);
      expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
    });
  });
}
