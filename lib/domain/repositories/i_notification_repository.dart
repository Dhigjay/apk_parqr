import 'package:parqr/domain/entities/notification_entity.dart';
import 'package:parqr/domain/entities/notification_settings_entity.dart';

abstract class INotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> createNotification({
    required String title,
    required String body,
    required String type,
    String? userId,
  });
  Future<NotificationSettingsEntity> getSettings();
  Future<void> updateSettings(NotificationSettingsEntity settings);
}
