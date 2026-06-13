import 'package:flutter/material.dart';
import 'package:parqr/core/constants/app_strings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName), automaticallyImplyLeading: false),
      body: const Center(child: Text('Halaman Home Pengunjung (Visitor)')),
    );
  }
}