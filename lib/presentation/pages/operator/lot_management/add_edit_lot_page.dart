import 'package:flutter/material.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/app_text_field.dart';

class AddEditLotPage extends StatefulWidget {
  const AddEditLotPage({
    super.key,
    required this.initialName,
    required this.initialAddress,
    required this.initialCapacity,
    required this.initialFloors,
    required this.initialPricePerHour,
  });

  final String initialName;
  final String initialAddress;
  final int initialCapacity;
  final int initialFloors;
  final double initialPricePerHour;

  @override
  State<AddEditLotPage> createState() => _AddEditLotPageState();
}

class _AddEditLotPageState extends State<AddEditLotPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _capacityController;
  late final TextEditingController _floorsController;
  late final TextEditingController _tariffController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _addressController = TextEditingController(text: widget.initialAddress);
    _capacityController = TextEditingController(text: widget.initialCapacity.toString());
    _floorsController = TextEditingController(text: widget.initialFloors.toString());
    _tariffController = TextEditingController(text: widget.initialPricePerHour.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _capacityController.dispose();
    _floorsController.dispose();
    _tariffController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    // Simulate saving settings
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context, {
        'name': _nameController.text,
        'address': _addressController.text,
        'capacity': int.tryParse(_capacityController.text) ?? widget.initialCapacity,
        'floors': int.tryParse(_floorsController.text) ?? widget.initialFloors,
        'pricePerHour': double.tryParse(_tariffController.text) ?? widget.initialPricePerHour,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengaturan Lahan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Konfigurasi Lahan Parkir',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ubah parameter operasional lahan parkir Anda secara langsung.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: 'Nama Lahan',
                  controller: _nameController,
                  hintText: 'Nama parkiran',
                  prefixIcon: Icons.local_parking_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Nama lahan wajib diisi' : null,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Alamat Lahan',
                  controller: _addressController,
                  hintText: 'Alamat lengkap',
                  prefixIcon: Icons.location_on_outlined,
                  textInputAction: TextInputAction.next,
                  maxLines: 2,
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Alamat wajib diisi' : null,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Kapasitas Total',
                        controller: _capacityController,
                        hintText: 'Kapasitas total slot',
                        prefixIcon: Icons.warehouse_rounded,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            (value ?? '').trim().isEmpty ? 'Wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        label: 'Jumlah Lantai',
                        controller: _floorsController,
                        hintText: 'Lantai',
                        prefixIcon: Icons.layers_outlined,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            (value ?? '').trim().isEmpty ? 'Wajib diisi' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Tarif per Jam (Rp)',
                  controller: _tariffController,
                  hintText: 'Tarif',
                  prefixIcon: Icons.monetization_on_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Tarif per jam wajib diisi' : null,
                ),
                const SizedBox(height: 36),
                AppButton(
                  label: 'Simpan Perubahan',
                  icon: Icons.save_rounded,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
