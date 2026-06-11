import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    
    // Mengecek apakah user sudah login sebelumnya
    on<AuthCheckStatusRequested>((event, emit) {
      if (authRepository.isLoggedIn) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    });

    // Menangani aksi Login
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.login(event.email, event.password);
        emit(AuthAuthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // Menangani aksi Register
    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.register(event.email, event.password, event.name);
        // Bisa langsung dianggap login setelah register sukses
        emit(AuthAuthenticated()); 
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