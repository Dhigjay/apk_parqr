import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/domain/entities/notification_settings_entity.dart';
import 'package:parqr/domain/repositories/i_notification_repository.dart';

abstract class NotificationSettingsState extends Equatable {
  const NotificationSettingsState();
  @override
  List<Object?> get props => [];
}

class NotificationSettingsInitial extends NotificationSettingsState {}
class NotificationSettingsLoading extends NotificationSettingsState {}
class NotificationSettingsLoaded extends NotificationSettingsState {
  final NotificationSettingsEntity settings;
  const NotificationSettingsLoaded(this.settings);
  @override
  List<Object?> get props => [settings];
}
class NotificationSettingsError extends NotificationSettingsState {
  final String message;
  const NotificationSettingsError(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  final INotificationRepository _repository;

  NotificationSettingsCubit(this._repository) : super(NotificationSettingsInitial());

  Future<void> fetchSettings() async {
    emit(NotificationSettingsLoading());
    try {
      final settings = await _repository.getSettings();
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      emit(NotificationSettingsError('Gagal memuat pengaturan: $e'));
    }
  }

  Future<void> updateSettings(NotificationSettingsEntity newSettings) async {
    if (state is NotificationSettingsLoaded) {
      // Optimistic update
      emit(NotificationSettingsLoaded(newSettings));
    } else {
      emit(NotificationSettingsLoading());
    }

    try {
      await _repository.updateSettings(newSettings);
      emit(NotificationSettingsLoaded(newSettings));
    } catch (e) {
      // Revert or show error
      emit(NotificationSettingsError('Gagal menyimpan pengaturan: $e'));
    }
  }
}
