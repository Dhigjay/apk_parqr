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
                _buildCategory('Booking', [
                  _buildSwitch(context, 'Booking berhasil', settings.bookingSuccess, (val) {
                    _updateSettings(context, settings, bookingSuccess: val);
                  }),
                  _buildSwitch(context, 'Booking dibatalkan', settings.bookingCancelled, (val) {
                    _updateSettings(context, settings, bookingCancelled: val);
                  }),
                  _buildSwitch(context, 'Booking akan kadaluarsa', settings.bookingExpiring, (val) {
                    _updateSettings(context, settings, bookingExpiring: val);
                  }),
                ]),
                const Divider(),
                _buildCategory('Parkir', [
                  _buildSwitch(context, 'QR Masuk dibuat', settings.qrCreated, (val) {
                    _updateSettings(context, settings, qrCreated: val);
                  }),
                  _buildSwitch(context, 'Kendaraan Check In', settings.vehicleCheckin, (val) {
                    _updateSettings(context, settings, vehicleCheckin: val);
                  }),
                  _buildSwitch(context, 'Kendaraan Check Out', settings.vehicleCheckout, (val) {
                    _updateSettings(context, settings, vehicleCheckout: val);
                  }),
                  _buildSwitch(context, 'Pengingat durasi parkir', settings.parkingDurationReminder, (val) {
                    _updateSettings(context, settings, parkingDurationReminder: val);
                  }),
                ]),
                const Divider(),
                _buildCategory('Pembayaran', [
                  _buildSwitch(context, 'Pembayaran berhasil', settings.paymentSuccess, (val) {
                    _updateSettings(context, settings, paymentSuccess: val);
                  }),
                  _buildSwitch(context, 'Pembayaran gagal', settings.paymentFailed, (val) {
                    _updateSettings(context, settings, paymentFailed: val);
                  }),
                  _buildSwitch(context, 'Refund', settings.refund, (val) {
                    _updateSettings(context, settings, refund: val);
                  }),
                ]),
                const Divider(),
                _buildCategory('Akun', [
                  _buildSwitch(context, 'Password berhasil diubah', settings.passwordChanged, (val) {
                    _updateSettings(context, settings, passwordChanged: val);
                  }),
                  _buildSwitch(context, 'Login dari perangkat baru', settings.newDeviceLogin, (val) {
                    _updateSettings(context, settings, newDeviceLogin: val);
                  }),
                  _buildSwitch(context, 'Profil diperbarui', settings.profileUpdated, (val) {
                    _updateSettings(context, settings, profileUpdated: val);
                  }),
                  _buildSwitch(context, 'Operator disetujui', settings.operatorApproved, (val) {
                    _updateSettings(context, settings, operatorApproved: val);
                  }),
                  _buildSwitch(context, 'Operator ditolak', settings.operatorRejected, (val) {
                    _updateSettings(context, settings, operatorRejected: val);
                  }),
                ]),
                const Divider(),
                _buildCategory('Promo', [
                  _buildSwitch(context, 'Promo terbaru', settings.promoNew, (val) {
                    _updateSettings(context, settings, promoNew: val);
                  }),
                  _buildSwitch(context, 'Diskon parkir', settings.parkingDiscount, (val) {
                    _updateSettings(context, settings, parkingDiscount: val);
                  }),
                ]),
                const Divider(),
                _buildCategory('Sistem', [
                  _buildSwitch(context, 'Maintenance', settings.maintenance, (val) {
                    _updateSettings(context, settings, maintenance: val);
                  }),
                  _buildSwitch(context, 'Update aplikasi', settings.appUpdate, (val) {
                    _updateSettings(context, settings, appUpdate: val);
                  }),
                  _buildSwitch(context, 'Informasi keamanan', settings.securityInfo, (val) {
                    _updateSettings(context, settings, securityInfo: val);
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
      bool? bookingSuccess,
      bool? bookingCancelled,
      bool? bookingExpiring,
      bool? qrCreated,
      bool? vehicleCheckin,
      bool? vehicleCheckout,
      bool? parkingDurationReminder,
      bool? paymentSuccess,
      bool? paymentFailed,
      bool? refund,
      bool? passwordChanged,
      bool? newDeviceLogin,
      bool? profileUpdated,
      bool? operatorApproved,
      bool? operatorRejected,
      bool? promoNew,
      bool? parkingDiscount,
      bool? maintenance,
      bool? appUpdate,
      bool? securityInfo,
    }) {
    final updated = NotificationSettingsEntity(
      userId: current.userId,
      bookingSuccess: bookingSuccess ?? current.bookingSuccess,
      bookingCancelled: bookingCancelled ?? current.bookingCancelled,
      bookingExpiring: bookingExpiring ?? current.bookingExpiring,
      qrCreated: qrCreated ?? current.qrCreated,
      vehicleCheckin: vehicleCheckin ?? current.vehicleCheckin,
      vehicleCheckout: vehicleCheckout ?? current.vehicleCheckout,
      parkingDurationReminder: parkingDurationReminder ?? current.parkingDurationReminder,
      paymentSuccess: paymentSuccess ?? current.paymentSuccess,
      paymentFailed: paymentFailed ?? current.paymentFailed,
      refund: refund ?? current.refund,
      passwordChanged: passwordChanged ?? current.passwordChanged,
      newDeviceLogin: newDeviceLogin ?? current.newDeviceLogin,
      profileUpdated: profileUpdated ?? current.profileUpdated,
      operatorApproved: operatorApproved ?? current.operatorApproved,
      operatorRejected: operatorRejected ?? current.operatorRejected,
      promoNew: promoNew ?? current.promoNew,
      parkingDiscount: parkingDiscount ?? current.parkingDiscount,
      maintenance: maintenance ?? current.maintenance,
      appUpdate: appUpdate ?? current.appUpdate,
      securityInfo: securityInfo ?? current.securityInfo,
    );
    context.read<NotificationSettingsCubit>().updateSettings(updated);
  }
}
