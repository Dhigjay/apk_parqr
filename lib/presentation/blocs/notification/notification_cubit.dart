import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/domain/entities/notification_entity.dart';
import 'package:parqr/domain/repositories/i_notification_repository.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}
class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationCubit extends Cubit<NotificationState> {
  final INotificationRepository _repository;

  NotificationCubit(this._repository) : super(NotificationInitial());

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());
    try {
      final notifications = await _repository.getNotifications();
      final unreadCount = await _repository.getUnreadCount();
      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError('Gagal memuat notifikasi: $e'));
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        final updatedList = current.notifications.map((n) {
          if (n.id == id) {
            return NotificationEntity(
              id: n.id,
              userId: n.userId,
              title: n.title,
              body: n.body,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
        final newUnreadCount = current.unreadCount > 0 ? current.unreadCount - 1 : 0;
        
        emit(NotificationLoaded(
          notifications: updatedList,
          unreadCount: newUnreadCount,
        ));
      } else {
        await fetchNotifications();
      }
    } catch (e) {
      // Ignore error quietly or refresh
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        final updatedList = current.notifications.map((n) {
          return NotificationEntity(
            id: n.id,
            userId: n.userId,
            title: n.title,
            body: n.body,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();
        
        emit(NotificationLoaded(
          notifications: updatedList,
          unreadCount: 0,
        ));
      } else {
        await fetchNotifications();
      }
    } catch (e) {
      // Ignore error quietly
    }
  }

  Future<void> refreshUnreadCount() async {
    if (state is NotificationLoaded) {
      try {
        final current = state as NotificationLoaded;
        final count = await _repository.getUnreadCount();
        emit(NotificationLoaded(
          notifications: current.notifications,
          unreadCount: count,
        ));
      } catch (_) {}
    } else {
      await fetchNotifications();
    }
  }
}
