import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/domain/repositories/i_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Mengecek apakah user sudah login sebelumnya (dipanggil dari Splash)
    on<AuthCheckStatusRequested>((event, emit) async {
      if (authRepository.isLoggedIn) {
        // currentRole adalah cache di memory — kosong lagi setiap app restart,
        // jadi harus di-refresh dulu dari database sebelum dipakai.
        final role = await authRepository.refreshCurrentRole();
        emit(AuthAuthenticated(role: role));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    // Menangani aksi Login
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.login(event.email, event.password);
        final role = authRepository.currentRole ?? 'visitor';
        emit(AuthAuthenticated(role: role));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // Menangani aksi Register
    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.register(event.email, event.password, event.name, event.phone);
        final role = authRepository.currentRole ?? 'visitor';
        emit(AuthAuthenticated(role: role));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.forgotPassword(event.email);
        emit(const AuthPasswordResetSent());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // Menangani aksi Logout
    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.logout();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}