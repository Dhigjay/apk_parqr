import 'package:flutter_test/flutter_test.dart';
import 'package:parqr/domain/repositories/i_auth_repository.dart';
import 'package:parqr/presentation/blocs/auth/auth_bloc.dart';
import 'package:parqr/presentation/blocs/auth/auth_event.dart';
import 'package:parqr/presentation/blocs/auth/auth_state.dart';

class MockAuthRepository implements IAuthRepository {
  bool shouldThrowError = false;
  bool _isLoggedIn = false;
  String? _role = 'user';

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  String? get currentRole => _role;

  @override
  Future<void> login(String email, String password) async {
    if (shouldThrowError) throw Exception('Login failed');
    _isLoggedIn = true;
  }

  @override
  Future<void> register(String email, String password, String name, String phone) async {
    if (shouldThrowError) throw Exception('Register failed');
    _isLoggedIn = true;
  }

  @override
  Future<void> forgotPassword(String email) async {
    if (shouldThrowError) throw Exception('Forgot password failed');
  }

  @override
  Future<void> logout() async {
    if (shouldThrowError) throw Exception('Logout failed');
    _isLoggedIn = false;
  }
}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    test('emits [AuthLoading, AuthAuthenticated] when login succeeds', () async {
      final expectedStates = [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ];
      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const AuthLoginRequested(email: 'test@test.com', password: 'password'));
    });

    test('emits [AuthLoading, AuthError] when login fails', () async {
      mockRepository.shouldThrowError = true;
      final expectedStates = [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ];
      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const AuthLoginRequested(email: 'test@test.com', password: 'password'));
    });

    test('emits [AuthLoading, AuthAuthenticated] when register succeeds', () async {
      final expectedStates = [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ];
      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const AuthRegisterRequested(email: 'test@test.com', password: 'password', name: 'Name', phone: '08123456789'));
    });

    test('emits [AuthLoading, AuthError] when register fails', () async {
      mockRepository.shouldThrowError = true;
      final expectedStates = [
        isA<AuthLoading>(),
        isA<AuthError>(),
      ];
      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const AuthRegisterRequested(email: 'test@test.com', password: 'password', name: 'Name', phone: '08123456789'));
    });
  });
}
