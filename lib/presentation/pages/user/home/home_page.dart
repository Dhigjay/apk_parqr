import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_strings.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/pages/user/home/widgets/parking_card_widget.dart';
import 'package:parqr/presentation/widgets/app_bottom_nav.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parqr/presentation/widgets/empty_state_widget.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';
import 'package:parqr/presentation/blocs/parking_lot/parking_lot_bloc.dart';
import 'package:parqr/presentation/blocs/parking_lot/parking_lot_state.dart';
import 'package:parqr/presentation/blocs/parking_lot/parking_lot_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  String _query = '';

  // Remove dummy static const _parkingLots

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
    });

    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<ParkingLotBloc>().add(SearchParkingLotsRequested(value));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          BlocBuilder<ParkingLotBloc, ParkingLotState>(
            builder: (context, state) {
              if (state is ParkingLotLoading || state is ParkingLotInitial) {
                return Column(
                  children: List.generate(
                    3,
                    (index) => const Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: ParkingCardSkeleton(),
                    ),
                  ),
                );
              } else if (state is ParkingLotLoaded) {
                final lots = state.parkingLots;
                if (lots.isEmpty) {
                  return EmptyStateWidget(
                    title: 'Parkir tidak ditemukan',
                    message:
                        'Coba cari nama tempat atau area lain untuk melihat hasil parkir.',
                    icon: Icons.search_off_rounded,
                    actionLabel: 'Reset Pencarian',
                    onAction: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  );
                }

                return Column(
                  children: lots.map((lot) {
                    final formatCurrency = NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp',
                      decimalDigits: 0,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: ParkingCardWidget(
                        name: lot.name,
                        address: lot.address,
                        distance: state.distances[lot.id] ?? 'TBD',
                        pricePerHour:
                            '${formatCurrency.format(lot.pricePerHour)}/jam',
                        availableSlots: lot.totalCapacity,
                        totalSlots: lot.totalCapacity,
                        onTap: () => context.push(
                          RouteNames.parkingDetail,
                          extra: {
                            'id': lot.id,
                            'name': lot.name,
                            'address': lot.address,
                            'totalCapacity': lot.totalCapacity,
                            'totalFloors': lot.totalFloors,
                            'pricePerHour': lot.pricePerHour,
                            'latitude': lot.latitude,
                            'longitude': lot.longitude,
                            'distance': state.distances[lot.id] ?? '',
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              } else if (state is ParkingLotError) {
                return Center(
                    child: Text(state.message,
                        style: const TextStyle(color: Colors.red)));
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            context.push(RouteNames.history);
          } else if (index == 2) {
            context.go(RouteNames.profile);
          }
        },
      ),
    );
  }
}

// Removed _ParkingLotViewData
