import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/injection/injection_container.dart';
import 'package:parqr/presentation/blocs/notification/notification_cubit.dart';
import 'package:parqr/domain/entities/notification_entity.dart';
import 'package:go_router/go_router.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Return Provider wrapped view if not already provided at higher level.
    // For list of notifications it's often good to provide at page level
    return BlocProvider(
      create: (_) => sl<NotificationCubit>()..fetchNotifications(),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Tandai semua sudah dibaca',
                  onPressed: () {
                    context.read<NotificationCubit>().markAllAsRead();
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationError) {
            return Center(child: Text(state.message));
          } else if (state is NotificationLoaded) {
            final notifications = state.notifications;
            if (notifications.isEmpty) {
              return const Center(child: Text('Tidak ada notifikasi.'));
            }
            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _NotificationItem(notification: notif);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _getIcon(notification.type),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(notification.body),
          const SizedBox(height: 4),
          Text(
            _formatTime(notification.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationCubit>().markAsRead(notification.id);
        }
        // Additional routing if needed based on type
        // e.g. context.push('/history-detail/${notification.referenceId}')
      },
    );
  }

  Widget _getIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'booking_success':
      case 'vehicle_checkin':
      case 'vehicle_checkout':
        iconData = Icons.directions_car;
        color = Colors.blue;
        break;
      case 'payment_success':
      case 'refund':
        iconData = Icons.payment;
        color = Colors.green;
        break;
      case 'qr_created':
        iconData = Icons.qr_code;
        color = Colors.orange;
        break;
      case 'payment_failed':
      case 'booking_cancelled':
      case 'operator_rejected':
        iconData = Icons.error_outline;
        color = Colors.red;
        break;
      case 'maintenance':
      case 'app_update':
      case 'security_info':
        iconData = Icons.info_outline;
        color = Colors.blueGrey;
        break;
      case 'operator_approved':
        iconData = Icons.verified;
        color = Colors.green;
        break;
      default:
        iconData = Icons.notifications;
        color = Colors.grey;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
