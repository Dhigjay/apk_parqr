import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/injection/injection_container.dart';
import 'package:parqr/data/datasources/remote/notification_remote_ds.dart';
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
  int? _selectedFloor;
  String? _selectedSlotCode;
  bool _isLoading = false;
  String? _errorMessage;

  String? _parkingLotId;
  String _parkingLotName = 'Memuat...';
  double _tariffPerHour = 5000.0;
  int _totalFloors = 1;
  Map<int, List<Map<String, String>>> _slotsPerFloor = {};

  bool _isInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      _loadParkingLot();
    }
  }

  Future<String> _getInternalUserId(SupabaseClient supabase) async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) throw Exception('Tidak terautentikasi.');

    final row = await supabase
        .from('users')
        .select('id')
        .eq('auth_id', authUser.id)
        .single();

    return row['id'] as String;
  }

  Future<void> _loadParkingLot() async {
    try {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null && extra['lotId'] != null) {
        setState(() {
          _parkingLotId = extra['lotId'] as String;
          _parkingLotName = extra['lotName'] as String? ?? 'Parkir';
          _tariffPerHour = _toDouble(extra['pricePerHour']) ?? 5000.0;
          _totalFloors = extra['totalFloors'] as int? ?? 1;
        });
        if (_parkingLotId != null) {
          await _loadSlotsForLot();
        }
        return;
      }
    } catch (e) {
      debugPrint('DEBUG ERROR accessing extra: $e');
    }

    try {
      final supabase = Supabase.instance.client;
      var lot = await supabase
          .from('parking_lots')
          .select()
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();

      lot ??=
          await supabase.from('parking_lots').select().limit(1).maybeSingle();

      if (lot != null && mounted) {
        final parkingLotData = lot;
        setState(() {
          _parkingLotId = parkingLotData['id']?.toString();
          _parkingLotName = parkingLotData['name']?.toString() ?? 'Parkir';
          _tariffPerHour = _toDouble(
                parkingLotData['hourly_rate'] ??
                    parkingLotData['price_per_hour'],
              ) ??
              5000.0;
          _totalFloors = (parkingLotData['floors'] ??
                  parkingLotData['total_floors']) as int? ??
              1;
        });
        await _loadSlotsForLot();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Tidak ada lahan parkir tersedia. Hubungi admin.';
          _parkingLotName = 'Tidak tersedia';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data parkir: $e';
          _parkingLotName = 'Gagal dimuat';
        });
      }
    }
  }

  Future<void> _loadSlotsForLot() async {
    if (_parkingLotId == null) return;
    try {
      final supabase = Supabase.instance.client;
      final parkingLotId = _parkingLotId!;
      final response = await supabase
          .from('parking_slots')
          .select('code, floor, floor_number, status')
          .eq('parking_lot_id', parkingLotId);

      final slots = response as List<dynamic>;
      final map = <int, List<Map<String, String>>>{};

      for (final slot in slots) {
        int floor = 1;
        if (slot['floor_number'] != null) {
          floor = slot['floor_number'] as int? ?? 1;
        } else if (slot['floor'] != null) {
          final floorText = slot['floor'].toString();
          final match = RegExp(r'(\d+)').firstMatch(floorText);
          if (match != null) {
            floor = int.tryParse(match.group(1) ?? '') ?? 1;
          }
        }

        final code = slot['code']?.toString() ?? 'Slot';
        final status = slot['status']?.toString() ?? 'occupied';

        map.putIfAbsent(floor, () => []);
        map[floor]!.add({'code': code, 'status': status});
      }

      if (mounted) {
        setState(() {
          _slotsPerFloor = map;
        });
      }
    } catch (e) {
      debugPrint('DEBUG _loadSlotsForLot error: $e');
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedVehicleId == null ||
        (_selectedSlotCode == null && _selectedFloor == null)) {
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
      final internalUserId = await _getInternalUserId(supabase);

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
        internalUserId: internalUserId,
        entryQrPayload: entryQrPayload,
      );

      try {
        await sl<NotificationRemoteDataSource>().createNotification(
          title: 'Booking Berhasil',
          body:
              'Booking parkir untuk $_selectedVehiclePlate di $_parkingLotName berhasil. QR masuk telah dibuat.',
          type: 'booking_success',
          userId: internalUserId,
        );
      } catch (_) {}

      if (!mounted) return;
      context.go(
        RouteNames.qrEntry,
        extra: {
          'sessionId': sessionId,
          'entryQrPayload': entryQrPayload,
          'parkingLotName': _parkingLotName,
          'vehiclePlate': _selectedVehiclePlate ?? '',
          'vehicleName': _selectedVehicleName ?? '',
          'slot': _selectedSlotCode ??
              (_selectedFloor != null
                  ? 'Lantai ${_selectedFloor!}'
                  : _selectedSlot),
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
    required String internalUserId,
    required String entryQrPayload,
  }) async {
    await supabase.from('parking_sessions').insert({
      'id': sessionId,
      'user_id': internalUserId,
      'vehicle_id': _selectedVehicleId,
      'parking_lot_id': _parkingLotId,
      'status': 'booked',
      'entry_qr_code': entryQrPayload,
    });
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
                  children:
                      List.generate(_totalFloors, (i) => i + 1).map((floorNum) {
                    final label = 'Lantai $floorNum';
                    final selected =
                        _selectedFloor == floorNum && _selectedSlotCode == null;
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected ||
                          (_selectedFloor == floorNum &&
                              _selectedSlotCode != null),
                      onSelected: (_) => setState(() {
                        _selectedFloor = floorNum;
                        _selectedSlotCode = null;
                        _selectedSlot = null;
                      }),
                      selectedColor:
                          AppColors.accentBlue.withValues(alpha: 0.18),
                      backgroundColor: AppColors.bgCard,
                      side: BorderSide(
                        color:
                            selected ? AppColors.accentBlue : AppColors.border,
                      ),
                      labelStyle: AppTextStyles.body.copyWith(
                        color: selected
                            ? AppColors.accentBlue
                            : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                if (_selectedFloor != null) ...[
                  Text('Pilih Slot - Lantai $_selectedFloor',
                      style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Builder(builder: (ctx) {
                    final slots = _slotsPerFloor[_selectedFloor!] ?? [];
                    if (slots.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'Tidak ada data slot untuk lantai ini',
                          style: AppTextStyles.bodySecondary,
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: slots.map((s) {
                        final code = s['code'] ?? 'Slot';
                        final status = s['status'] ?? 'occupied';
                        final isAvailable = status == 'available';
                        final isSelected = _selectedSlotCode == code;
                        return ChoiceChip(
                          label: Text(code),
                          selected: isSelected,
                          onSelected: isAvailable
                              ? (_) => setState(() {
                                    _selectedSlotCode = code;
                                    _selectedSlot = code;
                                  })
                              : null,
                          selectedColor:
                              AppColors.accentBlue.withValues(alpha: 0.18),
                          backgroundColor: AppColors.bgCard,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.accentBlue
                                : AppColors.border,
                          ),
                          labelStyle: AppTextStyles.body.copyWith(
                            color: isSelected
                                ? AppColors.accentBlue
                                : AppColors.textPrimary,
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
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
                        value: _selectedSlotCode ??
                            (_selectedFloor != null
                                ? 'Lantai $_selectedFloor'
                                : 'Belum dipilih'),
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
