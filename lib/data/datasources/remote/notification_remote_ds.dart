import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class NotificationRemoteDataSource {
  final SupabaseClient _supabaseClient;

  NotificationRemoteDataSource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  Future<String> _getInternalUserId() async {
    final authUser = _supabaseClient.auth.currentUser;
    if (authUser == null) throw Exception('Not logged in');
    final row = await _supabaseClient
        .from('users')
        .select('id')
        .eq('auth_id', authUser.id)
        .single();
    return row['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final internalUserId = await _getInternalUserId();

    return await _supabaseClient
        .from('notifications')
        .select()
        .eq('user_id', internalUserId)
        .order('created_at', ascending: false);
  }

  Future<int> getUnreadCount() async {
    try {
      final internalUserId = await _getInternalUserId();

      final response = await _supabaseClient
          .from('notifications')
          .select('id')
          .eq('user_id', internalUserId)
        .eq('is_read', false)
        .count(CountOption.exact);

      return response.count ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markAsRead(String id) async {
    await _supabaseClient
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  Future<void> markAllAsRead() async {
    try {
      final internalUserId = await _getInternalUserId();

      await _supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', internalUserId)
          .eq('is_read', false);
    } catch (_) {}
  }

  Future<void> createNotification({
    required String title,
    required String body,
    required String type,
    String? userId,
  }) async {
    // Determine target user
    String? targetUserId = userId;
    if (targetUserId == null) {
      try {
        targetUserId = await _getInternalUserId();
      } catch (_) {
        return; // Cannot send notification if no user
      }
    }

    // Check settings first (if settings table exists and has row)
    try {
      final settings = await _supabaseClient
          .from('notification_settings')
          .select()
          .eq('user_id', targetUserId)
          .maybeSingle();
          
      if (settings != null) {
        // Find if this type is disabled
        final settingKey = _mapTypeToSettingKey(type);
        if (settingKey != null && settings.containsKey(settingKey) && settings[settingKey] == false) {
          return; // Notification disabled by user
        }
      }
    } catch (e) {
      // Ignored if table doesn't exist yet
    }

    await _supabaseClient.from('notifications').insert({
      'id': const Uuid().v4(),
      'user_id': targetUserId,
      'title': title,
      'body': body,
      'type': type,
      'is_read': false,
    });
  }

  Future<Map<String, dynamic>> getSettings() async {
    final internalUserId = await _getInternalUserId();

    try {
      var settings = await _supabaseClient
          .from('notification_settings')
          .select()
          .eq('user_id', internalUserId)
          .maybeSingle();

      if (settings == null) {
        // Create default settings if not exists
        settings = {
          'user_id': internalUserId,
          'booking_notification': true,
          'payment_notification': true,
          'parking_notification': true,
          'promotion_notification': true,
        };
        await _supabaseClient.from('notification_settings').insert(settings);
        // Re-fetch to get complete record (including dates)
        settings = await _supabaseClient
            .from('notification_settings')
            .select()
            .eq('user_id', internalUserId)
            .single();
      }

      return settings;
    } catch (e) {
      // Fallback if table does not exist or error occurs
      throw Exception('Gagal mengambil pengaturan notifikasi: $e');
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    final internalUserId = await _getInternalUserId();

    final updatePayload = Map<String, dynamic>.from(settings);
    updatePayload.remove('user_id');
    updatePayload['updated_at'] = DateTime.now().toUtc().toIso8601String();

    await _supabaseClient
        .from('notification_settings')
        .update(updatePayload)
        .eq('user_id', internalUserId);
  }
  
  String? _mapTypeToSettingKey(String type) {
    switch (type) {
      case 'booking_success':
      case 'booking_cancelled':
      case 'booking_expiring':
        return 'booking_notification';
      case 'payment_success':
      case 'payment_failed':
      case 'refund':
        return 'payment_notification';
      case 'qr_created':
      case 'vehicle_checkin':
      case 'vehicle_checkout':
      case 'parking_duration_reminder':
        return 'parking_notification';
      case 'promo_new':
      case 'parking_discount':
        return 'promotion_notification';
      // System or Admin notifications cannot be disabled by user preferences
      case 'password_changed':
      case 'new_device_login':
      case 'profile_updated':
      case 'operator_approved':
      case 'operator_rejected':
      case 'maintenance':
      case 'app_update':
      case 'security_info':
      default:
        return null;
    }
  }
}
