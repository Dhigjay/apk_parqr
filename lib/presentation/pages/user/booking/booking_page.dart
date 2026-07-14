import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/form_feedback_banner.dart';
import 'package:parqr/presentation/widgets/vehicle_card_widget.dart';

enum _BookingStatus { idle, loading, error, success }

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? _selectedVehicle = 'B 1234 QR';
  String? _selectedSlot;
  _BookingStatus _status = _BookingStatus.idle;
  String? _feedbackMessage;

  Future<void> _confirmBooking() async {
    if (_selectedVehicle == null || _selectedSlot == null) {
      setState(() {
        _status = _BookingStatus.error;
        _feedbackMessage =
            'Pilih kendaraan dan slot/lantai sebelum konfirmasi.';
      });
      return;
    }

    setState(() {
      _status = _BookingStatus.loading;
      _feedbackMessage = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() {
      _status = _BookingStatus.success;
      _feedbackMessage = 'Booking berhasil. QR masuk sudah dibuat.';
    });

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) context.go(RouteNames.qrEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Booking')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Text('ParQr Sudirman Hub', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(
              'Pilih kendaraan dan slot parkir sebelum QR masuk dibuat.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 24),
            Text('Kendaraan', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            VehicleCardWidget(
              plateNumber: 'B 1234 QR',
              vehicleName: 'Honda Vario 125',
              typeLabel: 'Motor',
              statusLabel: _selectedVehicle == 'B 1234 QR' ? 'Dipilih' : null,
              onTap: () => setState(() => _selectedVehicle = 'B 1234 QR'),
            ),
            const SizedBox(height: 24),
            Text('Slot / Lantai', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['L1-A08', 'L2-B12', 'L2-B18', 'B1-C04']
                  .map(
                    (slot) => ChoiceChip(
                      label: Text(slot),
                      selected: _selectedSlot == slot,
                      onSelected: (_) => setState(() => _selectedSlot = slot),
                      selectedColor:
                          AppColors.accentBlue.withValues(alpha: 0.18),
                      backgroundColor: AppColors.bgCard,
                      side: BorderSide(
                        color: _selectedSlot == slot
                            ? AppColors.accentBlue
                            : AppColors.border,
                      ),
                      labelStyle: AppTextStyles.body.copyWith(
                        color: _selectedSlot == slot
                            ? AppColors.accentBlue
                            : AppColors.textPrimary,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ringkasan', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  const _SummaryRow(label: 'Tarif', value: 'Rp5.000/jam'),
                  const _SummaryRow(label: 'Kendaraan', value: 'B 1234 QR'),
                  _SummaryRow(
                      label: 'Slot', value: _selectedSlot ?? 'Belum dipilih'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_feedbackMessage != null) ...[
              FormFeedbackBanner(
                message: _feedbackMessage!,
                type: _status == _BookingStatus.success
                    ? FormFeedbackType.success
                    : FormFeedbackType.error,
              ),
              const SizedBox(height: 18),
            ],
            AppButton(
              label: 'Konfirmasi Pemesanan',
              icon: Icons.check_circle_outline_rounded,
              isLoading: _status == _BookingStatus.loading,
              onPressed:
                  _status == _BookingStatus.loading ? null : _confirmBooking,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySecondary)),
          Text(value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
