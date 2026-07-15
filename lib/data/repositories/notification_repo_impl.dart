import 'package:parqr/data/datasources/remote/notification_remote_ds.dart';
import 'package:parqr/domain/entities/notification_entity.dart';
import 'package:parqr/domain/entities/notification_settings_entity.dart';
import 'package:parqr/domain/repositories/i_notification_repository.dart';

class NotificationRepoImpl implements INotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepoImpl(this._remoteDataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final results = await _remoteDataSource.getNotifications();
    return results.map((e) => NotificationEntity.fromJson(e)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    return await _remoteDataSource.getUnreadCount();
  }

  @override
  Future<void> markAsRead(String id) async {
    await _remoteDataSource.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() async {
    await _remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> createNotification({
    required String title,
    required String body,
    required String type,
    String? userId,
  }) async {
    await _remoteDataSource.createNotification(
      title: title,
      body: body,
      type: type,
      userId: userId,
    );
  }

  @override
  Future<NotificationSettingsEntity> getSettings() async {
    final result = await _remoteDataSource.getSettings();
    return NotificationSettingsEntity.fromJson(result);
  }

  @override
  Future<void> updateSettings(NotificationSettingsEntity settings) async {
    await _remoteDataSource.updateSettings(settings.toJson());
  }
}
