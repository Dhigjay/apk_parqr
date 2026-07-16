import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/injection/injection_container.dart';
import 'package:parqr/presentation/blocs/notification/notification_settings_cubit.dart';
import 'package:parqr/domain/entities/notification_settings_entity.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationSettingsCubit>()..fetchSettings(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
      ),
      body: BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
        builder: (context, state) {
          if (state is NotificationSettingsLoading || state is NotificationSettingsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationSettingsError) {
            return Center(child: Text(state.message));
          } else if (state is NotificationSettingsLoaded) {
            final settings = state.settings;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildCategory('Pengaturan Notifikasi', [
                  _buildSwitch(context, 'Booking Parkir', settings.bookingNotification, (val) {
                    _updateSettings(context, settings, bookingNotification: val);
                  }),
                  _buildSwitch(context, 'Pembayaran', settings.paymentNotification, (val) {
                    _updateSettings(context, settings, paymentNotification: val);
                  }),
                  _buildSwitch(context, 'Aktivitas Parkir', settings.parkingNotification, (val) {
                    _updateSettings(context, settings, parkingNotification: val);
                  }),
                  _buildSwitch(context, 'Promo & Informasi', settings.promotionNotification, (val) {
                    _updateSettings(context, settings, promotionNotification: val);
                  }),
                ]),
                const SizedBox(height: 32),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildCategory(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitch(BuildContext context, String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
    );
  }

  void _updateSettings(
    BuildContext context, 
    NotificationSettingsEntity current, 
    {
      bool? bookingNotification,
      bool? paymentNotification,
      bool? parkingNotification,
      bool? promotionNotification,
    }) {
    final updated = NotificationSettingsEntity(
      id: current.id,
      userId: current.userId,
      bookingNotification: bookingNotification ?? current.bookingNotification,
      paymentNotification: paymentNotification ?? current.paymentNotification,
      parkingNotification: parkingNotification ?? current.parkingNotification,
      promotionNotification: promotionNotification ?? current.promotionNotification,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt,
    );
    context.read<NotificationSettingsCubit>().updateSettings(updated);
  }
}
