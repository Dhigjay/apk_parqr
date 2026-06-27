import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String role; // 'visitor' | 'operator' | 'admin'
  const AuthAuthenticated({required this.role});
}

class AuthUnauthenticated extends AuthState {}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
