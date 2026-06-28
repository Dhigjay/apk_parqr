import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/presentation/blocs/profile/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  Future<void> completeProfile({
    required String name,
    required String address,
  }) async {
    emit(ProfileLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      emit(ProfileLoaded(name: name, address: address));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
