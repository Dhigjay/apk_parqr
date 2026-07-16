import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/domain/repositories/i_user_repository.dart';
import 'package:parqr/presentation/blocs/profile/profile_state.dart';
import 'package:parqr/injection/injection_container.dart';
import 'package:parqr/data/datasources/remote/notification_remote_ds.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final IUserRepository _userRepository;

  ProfileCubit({required IUserRepository userRepository})
      : _userRepository = userRepository,
        super(ProfileInitial());

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    try {
      final user = await _userRepository.requireCurrentProfile();
      emit(ProfileLoaded(
        name: user.fullName ?? '',
        address: user.address ?? '',
        phone: user.phone ?? '',
        email: user.email,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> completeProfile({
    required String name,
    required String address,
  }) async {
    emit(ProfileLoading());
    try {
      final user = await _userRepository.completeProfile(
          fullName: name, address: address);
      // Emit ProfileCompleted so onboarding pages dapat auto-navigate
      emit(ProfileCompleted(
        name: user.fullName ?? '',
        address: user.address ?? '',
        phone: user.phone ?? '',
        email: user.email,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    if (name.trim().isEmpty) {
      emit(const ProfileError('Nama lengkap tidak boleh kosong.'));
      return;
    }
    emit(ProfileLoading());
    try {
      final user = await _userRepository.upsertCurrentProfile(
        fullName: name.trim(),
        phone: phone.trim().isEmpty ? null : phone.trim(),
        address: address.trim().isEmpty ? null : address.trim(),
      );
      emit(ProfileLoaded(
        name: user.fullName ?? '',
        address: user.address ?? '',
        phone: user.phone ?? '',
        email: user.email,
      ));

      try {
        await sl<NotificationRemoteDataSource>().createNotification(
          title: 'Profil Diperbarui',
          body: 'Data profil Anda telah berhasil diperbarui.',
          type: 'profile_updated',
          userId: user.id,
        );
      } catch (_) {}
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
