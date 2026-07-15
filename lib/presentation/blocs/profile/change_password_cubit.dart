import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/domain/repositories/i_auth_repository.dart';
import 'package:parqr/core/error/exceptions.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final IAuthRepository _authRepository;

  ChangePasswordCubit(this._authRepository) : super(ChangePasswordInitial());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.isEmpty) {
      emit(const ChangePasswordFailure('Password lama tidak boleh kosong'));
      return;
    }
    if (newPassword.length < 6) {
      emit(const ChangePasswordFailure('Password minimal 6 karakter'));
      return;
    }
    if (newPassword != confirmPassword) {
      emit(const ChangePasswordFailure('Password baru dan konfirmasi harus sama'));
      return;
    }

    emit(ChangePasswordLoading());
    try {
      await _authRepository.changePassword(currentPassword, newPassword);
      emit(ChangePasswordSuccess());
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('invalid login credentials') || msg.contains('invalid password')) {
        emit(const ChangePasswordFailure('Password lama tidak sesuai'));
      } else {
        emit(const ChangePasswordFailure('Gagal mengubah password, coba lagi'));
      }
    }
  }
}
