import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDisplayCard extends StatelessWidget {
  const QrDisplayCard({
    required this.data,
    this.size = 220,
    super.key,
  });

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: size,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
