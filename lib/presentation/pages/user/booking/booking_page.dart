import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/injection/injection_container.dart';
import 'package:parqr/presentation/blocs/vehicle/vehicle_cubit.dart';
import 'package:parqr/presentation/blocs/vehicle/vehicle_state.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/form_feedback_banner.dart';
import 'package:parqr/presentation/widgets/vehicle_card_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VehicleCubit>()..fetchVehicles(),
      child: const _BookingView(),
    );
  }
}

class _BookingView extends StatefulWidget {
  const _BookingView();

  @override
  State<_BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<_BookingView> {
  String? _selectedVehicleId;
  String? _selectedVehiclePlate;
  String? _selectedVehicleName;
  String? _selectedSlot;
  bool _isLoading = false;
  String? _errorMessage;

  // Data ini idealnya diterima dari parking_detail via route extra.
  // Untuk sementara diambil dari Supabase langsung.
  String? _parkingLotId;
  String _parkingLotName = 'Memuat...';
  double _tariffPerHour = 5000.0;

  @override
  void initState() {
    super.initState();
    _loadParkingLot();
  }

  Future<void> _loadParkingLot() async {
    // Coba baca dari route extra dulu (dikirim ParkingDetailPage)
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra != null && extra['lotId'] != null) {
      setState(() {
        _parkingLotId = extra['lotId'] as String;
        _parkingLotName = extra['lotName'] as String? ?? 'Parkir';
        _tariffPerHour = _toDouble(extra['pricePerHour']) ?? 5000.0;
      });
      return;
    }

    // Fallback: ambil dari Supabase jika tidak ada extra
    try {
      final supabase = Supabase.instance.client;
      var lot = await supabase
          .from('parking_lots')
          .select()
          .eq('status', 'active')
          .limit(1)
          .maybeSingle();

      lot ??= await supabase.from('parking_lots').select().limit(1).maybeSingle();

      if (lot != null && mounted) {
        final selectedLot = lot;
        setState(() {
          _parkingLotId = selectedLot['id']?.toString();
          _parkingLotName = selectedLot['name']?.toString() ?? 'Parkir';
          _tariffPerHour = _toDouble(
                selectedLot['hourly_rate'] ?? selectedLot['price_per_hour'],
              ) ??
              5000.0;
        });
      }
    } catch (_) {
      // Gunakan fallback jika gagal load
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedVehicleId == null || _selectedSlot == null) {
      setState(() => _errorMessage =
          'Pilih kendaraan dan slot/lantai sebelum konfirmasi.');
      return;
    }
    if (_parkingLotId == null) {
      setState(
          () => _errorMessage = 'Data lahan parkir belum tersedia. Coba lagi.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) throw Exception('Tidak terautentikasi.');

      final sessionId = const Uuid().v4();
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 24));

      final entryQrPayload = jsonEncode({
        'session_id': sessionId,
        'type': 'entry',
        'issued_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'nonce': const Uuid().v4(),
      });

      await _insertParkingSession(
        supabase: supabase,
        sessionId: sessionId,
        userId: currentUser.id,
        entryQrPayload: entryQrPayload,
        expiresAt: expiresAt,
      );

      if (!mounted) return;
      context.go(
        RouteNames.qrEntry,
        extra: {
          'sessionId': sessionId,
          'entryQrPayload': entryQrPayload,
          'parkingLotName': _parkingLotName,
          'vehiclePlate': _selectedVehiclePlate ?? '',
          'vehicleName': _selectedVehicleName ?? '',
          'slot': _selectedSlot,
          'tariffPerHour': _tariffPerHour,
          'bookedAt': now.toIso8601String(),
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal membuat booking: $e';
      });
    }
  }

  double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Future<void> _insertParkingSession({
    required SupabaseClient supabase,
    required String sessionId,
    required String userId,
    required String entryQrPayload,
    required DateTime expiresAt,
  }) async {
    final sprint0Payload = {
      'id': sessionId,
      'user_id': userId,
      'vehicle_id': _selectedVehicleId,
      'parking_lot_id': _parkingLotId,
      'status': 'booked',
      'entry_qr': entryQrPayload,
    };

    final initialSchemaPayload = {
      'id': sessionId,
      'user_id': userId,
      'vehicle_id': _selectedVehicleId,
      'lot_id': _parkingLotId,
      'status': 'booked',
      'entry_qr_token': entryQrPayload,
      'entry_qr_expires_at': expiresAt.toIso8601String(),
      'amount_due': 0,
    };

    try {
      await supabase.from('parking_sessions').insert(sprint0Payload);
    } on PostgrestException catch (e) {
      if (!_isSchemaMismatch(e)) rethrow;
      await supabase.from('parking_sessions').insert(initialSchemaPayload);
    }
  }

  bool _isSchemaMismatch(PostgrestException e) {
    return e.code == '42703' ||
        e.code == '23502' ||
        e.code == 'PGRST204' ||
        e.message.toLowerCase().contains('schema cache') ||
        e.message.toLowerCase().contains('column');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Booking')),
      body: SafeArea(
        child: BlocBuilder<VehicleCubit, VehicleState>(
          builder: (context, vehicleState) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                Text(_parkingLotName, style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Pilih kendaraan dan slot parkir sebelum QR masuk dibuat.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 24),
                Text('Kendaraan', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                if (vehicleState is VehicleLoading)
                  const Center(child: CircularProgressIndicator())
                else if (vehicleState is VehicleLoaded &&
                    vehicleState.vehicles.isNotEmpty)
                  ...vehicleState.vehicles.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: VehicleCardWidget(
                          plateNumber: v.plateNumber,
                          vehicleName: '${v.brand} ${v.model}',
                          typeLabel:
                              v.vehicleType == 'motor' ? 'Motor' : 'Mobil',
                          statusLabel:
                              _selectedVehicleId == v.id ? 'Dipilih' : null,
                          onTap: () => setState(() {
                            _selectedVehicleId = v.id;
                            _selectedVehiclePlate = v.plateNumber;
                            _selectedVehicleName = '${v.brand} ${v.model}';
                          }),
                        ),
                      ))
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Tidak ada kendaraan terdaftar. Tambah kendaraan di halaman Profil.',
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                Text('Slot / Lantai', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ['L1-A08', 'L2-B12', 'L2-B18', 'B1-C04']
                      .map((slot) => ChoiceChip(
                            label: Text(slot),
                            selected: _selectedSlot == slot,
                            onSelected: (_) =>
                                setState(() => _selectedSlot = slot),
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
                          ))
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
                      _SummaryRow(
                        label: 'Tarif',
                        value: 'Rp${_tariffPerHour.toInt()}/jam',
                      ),
                      _SummaryRow(
                        label: 'Kendaraan',
                        value: _selectedVehiclePlate ?? 'Belum dipilih',
                      ),
                      _SummaryRow(
                        label: 'Slot',
                        value: _selectedSlot ?? 'Belum dipilih',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  FormFeedbackBanner(
                    message: _errorMessage!,
                    type: FormFeedbackType.error,
                  ),
                  const SizedBox(height: 18),
                ],
                AppButton(
                  label: 'Konfirmasi Pemesanan',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _confirmBooking,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
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
