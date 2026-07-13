import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParkingDetailPage extends StatefulWidget {
  const ParkingDetailPage({super.key});

  @override
  State<ParkingDetailPage> createState() => _ParkingDetailPageState();
}

class _ParkingDetailPageState extends State<ParkingDetailPage> {
  // Data dari route extra (dikirim oleh HomePage)
  late String _lotId;
  late String _name;
  late String _address;
  late int _totalCapacity;
  late int _totalFloors;
  late double _pricePerHour;
  late String _distance;

  // Data dari Supabase (slot per lantai)
  Map<int, int> _availablePerFloor = {}; // floor_number -> available count
  int _totalAvailable = 0;
  bool _loadingSlots = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

    _lotId = extra?['id'] as String? ?? '';
    _name = extra?['name'] as String? ?? 'Detail Parkir';
    _address = extra?['address'] as String? ?? '-';
    _totalCapacity = extra?['totalCapacity'] as int? ?? 0;
    _totalFloors = extra?['totalFloors'] as int? ?? 1;
    _pricePerHour = extra?['pricePerHour'] as double? ?? 0.0;
    _distance = extra?['distance'] as String? ?? '';

    if (_lotId.isNotEmpty) {
      _loadSlotData();
    }
  }

  Future<void> _loadSlotData() async {
    try {
      final response = await Supabase.instance.client
          .from('parking_slots')
          .select('floor_number, status')
          .eq('lot_id', _lotId);

      final slots = response as List<dynamic>;
      final Map<int, int> available = {};
      int totalAvail = 0;

      for (final slot in slots) {
        final floor = slot['floor_number'] as int? ?? 1;
        final status = slot['status'] as String? ?? 'occupied';
        available.putIfAbsent(floor, () => 0);
        if (status == 'available') {
          available[floor] = available[floor]! + 1;
          totalAvail++;
        }
      }

      if (mounted) {
        setState(() {
          _availablePerFloor = available;
          _totalAvailable = totalAvail;
          _loadingSlots = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  String _formatPrice(double price) {
    final p = price.toInt();
    final s = p.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp$s/jam';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const _MapThumbnail(),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name, style: AppTextStyles.h2),
                      const SizedBox(height: 8),
                      Text(_address, style: AppTextStyles.bodySecondary),
                    ],
                  ),
                ),
                StatusBadge(
                  label: _totalAvailable > 0 ? 'Tersedia' : 'Penuh',
                  type: _totalAvailable > 0
                      ? StatusBadgeType.active
                      : StatusBadgeType.expired,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Metrik
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.event_seat_outlined,
                    label: 'Kapasitas',
                    value: _loadingSlots
                        ? '...'
                        : '$_totalAvailable/$_totalCapacity',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.payments_outlined,
                    label: 'Tarif',
                    value: _formatPrice(_pricePerHour),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.layers_outlined,
                    label: 'Lantai',
                    value: '$_totalFloors lantai',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.near_me_outlined,
                    label: 'Jarak',
                    value: _distance.isNotEmpty ? _distance : 'N/A',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Info lantai dari DB
            Text('Info Lantai', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            if (_loadingSlots)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_availablePerFloor.isEmpty)
              // Jika tidak ada data slot, tampilkan lantai dari field floors DB
              ...List.generate(_totalFloors, (i) {
                final floor = i + 1;
                return _FloorAvailabilityTile(
                  floor: 'Lantai $floor',
                  slots: 'Data slot belum tersedia',
                  type: StatusBadgeType.neutral,
                );
              })
            else
              ...(_availablePerFloor.entries.toList()
                    ..sort((a, b) => a.key.compareTo(b.key)))
                  .map((entry) {
                final floor = entry.key;
                final avail = entry.value;
                return _FloorAvailabilityTile(
                  floor: 'Lantai $floor',
                  slots: avail > 0 ? '$avail slot tersedia' : 'Penuh',
                  type: avail > 0
                      ? StatusBadgeType.active
                      : StatusBadgeType.expired,
                );
              }),

            const SizedBox(height: 28),
            AppButton(
              label: 'Pesan Parkir',
              icon: Icons.qr_code_2_rounded,
              onPressed: _totalAvailable > 0 || _availablePerFloor.isEmpty
                  ? () => context.push(
                        RouteNames.booking,
                        extra: {
                          'lotId': _lotId,
                          'lotName': _name,
                          'pricePerHour': _pricePerHour,
                          'totalFloors': _totalFloors,
                        },
                      )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapThumbnail extends StatelessWidget {
  const _MapThumbnail();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _MapPatternPainter()),
          ),
          const Center(
            child: Icon(Icons.location_pin, color: AppColors.error, size: 44),
          ),
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: Text('Peta lokasi', style: AppTextStyles.caption),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentBlue, size: 22),
          const SizedBox(height: 12),
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FloorAvailabilityTile extends StatelessWidget {
  const _FloorAvailabilityTile({
    required this.floor,
    required this.slots,
    required this.type,
  });

  final String floor;
  final String slots;
  final StatusBadgeType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.layers_rounded, color: AppColors.accentPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(floor,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(slots, style: AppTextStyles.caption),
              ],
            ),
          ),
          StatusBadge(
            label: type == StatusBadgeType.active
                ? 'Open'
                : type == StatusBadgeType.expired
                    ? 'Full'
                    : '-',
            type: type,
          ),
        ],
      ),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final accentPaint = Paint()
      ..color = AppColors.accentBlue.withValues(alpha: 0.35)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height * 0.24),
        Offset(size.width, size.height * 0.1), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.72),
        Offset(size.width, size.height * 0.48), roadPaint);
    canvas.drawLine(Offset(size.width * 0.22, 0),
        Offset(size.width * 0.72, size.height), accentPaint);
    canvas.drawLine(Offset(size.width * 0.76, 0),
        Offset(size.width * 0.28, size.height), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
