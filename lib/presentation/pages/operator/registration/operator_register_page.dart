import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/app_text_field.dart';

class OperatorRegisterPage extends StatefulWidget {
  const OperatorRegisterPage({super.key});

  @override
  State<OperatorRegisterPage> createState() => _OperatorRegisterPageState();
}

class _OperatorRegisterPageState extends State<OperatorRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _sizeController = TextEditingController();
  final _floorsController = TextEditingController();
  final _capacityController = TextEditingController();
  final _tariffController = TextEditingController();
  
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _sizeController.dispose();
    _floorsController.dispose();
    _capacityController.dispose();
    _tariffController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan unggah foto lokasi lahan parkir Anda.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate registration API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan berhasil dikirim! Menunggu persetujuan Admin.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftarkan Lahan Parkir'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Mulai Usaha Parkir Anda',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan detail informasi bisnis lahan parkir Anda untuk ditinjau oleh Admin.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: 'Nama Usaha / Lahan',
                  controller: _nameController,
                  hintText: 'Contoh: Parkir Jaya Sudirman',
                  prefixIcon: Icons.storefront_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Nama usaha wajib diisi' : null,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Alamat Lengkap Lahan',
                  controller: _addressController,
                  hintText: 'Jalan, RT/RW, Kelurahan, Kecamatan, Kota',
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
                        label: 'Luas Lahan (m²)',
                        controller: _sizeController,
                        hintText: '150',
                        prefixIcon: Icons.photo_size_select_small_rounded,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Luas wajib diisi'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        label: 'Jumlah Lantai',
                        controller: _floorsController,
                        hintText: '1',
                        prefixIcon: Icons.layers_outlined,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Jumlah lantai wajib'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Kapasitas Total',
                        controller: _capacityController,
                        hintText: '50',
                        prefixIcon: Icons.local_parking_rounded,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Kapasitas wajib'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        label: 'Tarif / Jam (Rp)',
                        controller: _tariffController,
                        hintText: '5000',
                        prefixIcon: Icons.monetization_on_outlined,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Tarif wajib'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Foto Lahan Parkir',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 42,
                                color: AppColors.accentBlue,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pilih Foto dari Galeri',
                                style: AppTextStyles.bodySecondary,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Ajukan Pendaftaran',
                  icon: Icons.send_rounded,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
