import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_strings.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/pages/user/home/widgets/parking_card_widget.dart';
import 'package:parqr/presentation/widgets/app_bottom_nav.dart';
import 'package:parqr/presentation/widgets/empty_state_widget.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _isLoading = false;

  static const _parkingLots = [
    _ParkingLotViewData(
      name: 'ParQr Sudirman Hub',
      address: 'Jl. Jend. Sudirman No. 12, Jakarta Pusat',
      distance: '350 m',
      pricePerHour: 'Rp5.000/jam',
      availableSlots: 24,
      totalSlots: 80,
    ),
    _ParkingLotViewData(
      name: 'Mall Atrium Parking',
      address: 'Jl. Senen Raya No. 135, Jakarta Pusat',
      distance: '1.2 km',
      pricePerHour: 'Rp7.000/jam',
      availableSlots: 7,
      totalSlots: 120,
    ),
    _ParkingLotViewData(
      name: 'Kemang Night Park',
      address: 'Jl. Kemang Selatan VIII, Jakarta Selatan',
      distance: '2.8 km',
      pricePerHour: 'Rp6.000/jam',
      availableSlots: 18,
      totalSlots: 64,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      _isLoading = true;
    });

    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredLots = _parkingLots
        .where(
          (lot) =>
              lot.name.toLowerCase().contains(_query.toLowerCase()) ||
              lot.address.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(AppStrings.tagline, style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Cari parkir, pesan slot, dan gunakan QR untuk masuk-keluar area parkir.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: AppStrings.searchParking,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => context.push(RouteNames.operatorRegister),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.registerLot,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(AppStrings.nearbyParking, style: AppTextStyles.h3),
              ),
              const StatusBadge(
                label: 'Realtime',
                type: StatusBadgeType.active,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isLoading)
            ...List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: ParkingCardSkeleton(),
              ),
            )
          else if (filteredLots.isEmpty)
            EmptyStateWidget(
              title: 'Parkir tidak ditemukan',
              message:
                  'Coba cari nama tempat atau area lain untuk melihat hasil parkir.',
              icon: Icons.search_off_rounded,
              actionLabel: 'Reset Pencarian',
              onAction: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            )
          else
            ...filteredLots.map(
              (lot) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ParkingCardWidget(
                  name: lot.name,
                  address: lot.address,
                  distance: lot.distance,
                  pricePerHour: lot.pricePerHour,
                  availableSlots: lot.availableSlots,
                  totalSlots: lot.totalSlots,
                  onTap: () => context.push(RouteNames.parkingDetail),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            context.push(RouteNames.history);
          } else if (index == 2) {
            context.push(RouteNames.profile);
            context.go(RouteNames.history);
          }
        },
      ),
    );
  }
}

class _ParkingLotViewData {
  const _ParkingLotViewData({
    required this.name,
    required this.address,
    required this.distance,
    required this.pricePerHour,
    required this.availableSlots,
    required this.totalSlots,
  });

  final String name;
  final String address;
  final String distance;
  final String pricePerHour;
  final int availableSlots;
  final int totalSlots;
}
