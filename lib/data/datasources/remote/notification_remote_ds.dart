import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class NotificationRemoteDataSource {
  final SupabaseClient _supabaseClient;

  NotificationRemoteDataSource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    return await _supabaseClient
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
  }

  Future<int> getUnreadCount() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return 0;

    final response = await _supabaseClient
        .from('notifications')
        .select('id')
        .eq('user_id', user.id)
        .eq('is_read', false)
        .count(CountOption.exact);

    return response.count ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _supabaseClient
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  Future<void> markAllAsRead() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    await _supabaseClient
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', user.id)
        .eq('is_read', false);
  }

  Future<void> createNotification({
    required String title,
    required String body,
    required String type,
    String? userId,
  }) async {
    // Determine target user
    final targetUserId = userId ?? _supabaseClient.auth.currentUser?.id;
    if (targetUserId == null) return; // Cannot send notification if no user

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
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    try {
      var settings = await _supabaseClient
          .from('notification_settings')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (settings == null) {
        // Create default settings if not exists
        settings = {
          'user_id': user.id,
        };
        await _supabaseClient.from('notification_settings').insert(settings);
        // Re-fetch
        settings = await _supabaseClient
            .from('notification_settings')
            .select()
            .eq('user_id', user.id)
            .single();
      }

      return settings;
    } catch (e) {
      // Fallback if table does not exist
      return {'user_id': user.id};
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final updatePayload = Map<String, dynamic>.from(settings);
    updatePayload.remove('user_id');
    updatePayload['updated_at'] = DateTime.now().toUtc().toIso8601String();

    await _supabaseClient
        .from('notification_settings')
        .update(updatePayload)
        .eq('user_id', user.id);
  }
  
  String? _mapTypeToSettingKey(String type) {
    switch (type) {
      case 'booking_success': return 'booking_success';
      case 'booking_cancelled': return 'booking_cancelled';
      case 'booking_expiring': return 'booking_expiring';
      case 'qr_created': return 'qr_created';
      case 'vehicle_checkin': return 'vehicle_checkin';
      case 'vehicle_checkout': return 'vehicle_checkout';
      case 'parking_duration_reminder': return 'parking_duration_reminder';
      case 'payment_success': return 'payment_success';
      case 'payment_failed': return 'payment_failed';
      case 'refund': return 'refund';
      case 'password_changed': return 'password_changed';
      case 'new_device_login': return 'new_device_login';
      case 'profile_updated': return 'profile_updated';
      case 'operator_approved': return 'operator_approved';
      case 'operator_rejected': return 'operator_rejected';
      case 'promo_new': return 'promo_new';
      case 'parking_discount': return 'parking_discount';
      case 'maintenance': return 'maintenance';
      case 'app_update': return 'app_update';
      case 'security_info': return 'security_info';
      default: return null;
    }
  }
}
