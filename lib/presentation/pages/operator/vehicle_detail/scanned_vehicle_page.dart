import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:intl/intl.dart';

class ScannedVehiclePage extends StatefulWidget {
  const ScannedVehiclePage({
    super.key,
    this.qrPayload,
    required this.sessionId,
    required this.vehicleName,
    required this.licensePlate,
    required this.checkInTime,
    required this.floor,
    required this.currentTariff,
  });

  final String? qrPayload;
  final String sessionId;
  final String vehicleName;
  final String licensePlate;
  final DateTime checkInTime;
  final String floor;
  final double currentTariff;

  @override
  State<ScannedVehiclePage> createState() => _ScannedVehiclePageState();
}

class _ScannedVehiclePageState extends State<ScannedVehiclePage> {
  bool _isLoading = false;
  bool _isCheckOut = false;

  @override
  void initState() {
    super.initState();
    // Decide if this is check-in or check-out based on tariff/payload
    // (If tariff > 0 or payload contains 'exit', it's checkout)
    if (widget.currentTariff > 0 || (widget.qrPayload?.contains('EXIT') ?? false)) {
      _isCheckOut = true;
    }
  }

  void _showCashVerificationDialog() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.bgElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.monetization_on_rounded, color: AppColors.warning, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Verifikasi Tunai',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Pastikan Anda telah menerima uang tunai sejumlah:',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    currencyFormatter.format(widget.currentTariff),
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _processCheckOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Verifikasi & Lepas', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _processCheckIn() async {
    setState(() => _isLoading = true);

    // Simulate API check in
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kendaraan berhasil Check-In.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(RouteNames.operatorDashboard);
    }
  }

  void _processCheckOut() async {
    setState(() => _isLoading = true);

    // Simulate API check out
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi parkir selesai. Kendaraan dikeluarkan.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(RouteNames.operatorDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final timeFormatter = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCheckOut ? 'Detail Keluar Parkir' : 'Detail Masuk Parkir'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle Photo Placeholder
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car_rounded,
                      size: 64,
                      color: AppColors.accentBlue,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Foto Kendaraan (Supabase Storage)',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // License Plate Display
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentBlue, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentBlue.withValues(alpha: 0.1),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.licensePlate,
                    style: AppTextStyles.h1.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Vehicle Details list
              _infoRow('Nama Kendaraan', widget.vehicleName),
              _infoRow('Lantai/Slot', widget.floor),
              _infoRow('Waktu Masuk', timeFormatter.format(widget.checkInTime)),
              if (_isCheckOut) ...[
                _infoRow(
                  'Durasi Parkir',
                  '${DateTime.now().difference(widget.checkInTime).inHours} Jam ${DateTime.now().difference(widget.checkInTime).inMinutes % 60} Menit',
                ),
                const Divider(height: 32, color: AppColors.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Tarif',
                      style: AppTextStyles.bodySecondary.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currencyFormatter.format(widget.currentTariff),
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 48),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_isCheckOut)
                ElevatedButton.icon(
                  onPressed: _showCashVerificationDialog,
                  icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                  label: const Text('Verifikasi & Lepas Kendaraan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTextStyles.button,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _processCheckIn,
                  icon: const Icon(Icons.login_rounded, color: Colors.white),
                  label: const Text('Konfirmasi Check-In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTextStyles.button,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySecondary),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
