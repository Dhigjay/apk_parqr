import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:intl/intl.dart';

class LotManagementPage extends StatefulWidget {
  const LotManagementPage({super.key});

  @override
  State<LotManagementPage> createState() => _LotManagementPageState();
}

class _LotManagementPageState extends State<LotManagementPage> {
  // Mock data operator lot settings
  String _lotName = 'ParQr Sudirman Hub';
  String _address = 'Jl. Jend. Sudirman No. 12, Jakarta Pusat';
  int _capacity = 80;
  int _floors = 3;
  double _pricePerHour = 5000.0;

  final List<Map<String, dynamic>> _mockSlots = [
    {'floor': 'Lantai 1', 'slots': 30, 'filled': 12},
    {'floor': 'Lantai 2', 'slots': 30, 'filled': 8},
    {'floor': 'Lantai 3', 'slots': 20, 'filled': 4},
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Lahan'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Current Lot Card Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _lotName,
                          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final result = await context.push<Map<String, dynamic>>(
                            '/add-edit-lot',
                            extra: {
                              'name': _lotName,
                              'address': _address,
                              'capacity': _capacity,
                              'floors': _floors,
                              'pricePerHour': _pricePerHour,
                            },
                          );

                          if (result != null) {
                            setState(() {
                              _lotName = result['name'] ?? _lotName;
                              _address = result['address'] ?? _address;
                              _capacity = result['capacity'] ?? _capacity;
                              _floors = result['floors'] ?? _floors;
                              _pricePerHour = result['pricePerHour'] ?? _pricePerHour;
                            });
                          }
                        },
                        icon: const Icon(Icons.edit_rounded, color: AppColors.accentBlue),
                        tooltip: 'Edit Pengaturan',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _address,
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.border),
                  _infoTile('Kapasitas Total', '$_capacity Slot', Icons.local_parking_rounded),
                  _infoTile('Jumlah Lantai', '$_floors Lantai', Icons.layers_outlined),
                  _infoTile('Tarif per Jam', currencyFormatter.format(_pricePerHour), Icons.monetization_on_outlined),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Tata Letak Lantai & Slot',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            ..._mockSlots.map(
              (slot) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot['floor'] as String,
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kapasitas: ${slot['slots']} slot',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${slot['filled']} terisi',
                          style: AppTextStyles.bodySecondary.copyWith(
                            color: (slot['filled'] as int) > 25 ? AppColors.error : AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            // Edit floor layout slots mockup
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Mengedit konfigurasi ${slot['floor']}'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings_outlined, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.bodySecondary),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
