import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class VehicleCardWidget extends StatelessWidget {
  const VehicleCardWidget({
    required this.title,
    required this.plateNumber,
    this.subtitle,
    super.key,
  });

  final String title;
  final String plateNumber;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.directions_car, color: AppColors.accentBlue),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: Text(
          plateNumber,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
