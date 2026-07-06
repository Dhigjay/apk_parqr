import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/domain/repositories/i_user_repository.dart';
import 'package:parqr/presentation/blocs/profile/profile_state.dart';

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
      final user = await _userRepository.completeProfile(fullName: name, address: address);
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

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    emit(ProfileLoading());
    try {
      final user = await _userRepository.upsertCurrentProfile(
        fullName: name,
        phone: phone,
        address: address,
      );
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
}
