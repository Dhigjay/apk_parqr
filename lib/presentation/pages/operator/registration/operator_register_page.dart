import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/app_text_field.dart';
import 'package:parqr/data/datasources/remote/operator_registration_remote_ds.dart';

class OperatorRegisterPage extends StatefulWidget {
  const OperatorRegisterPage({super.key});

  @override
  State<OperatorRegisterPage> createState() => _OperatorRegisterPageState();
}

/// Controller pasangan untuk 1 baris input lantai: nama lantai + kapasitasnya.
class _FloorInputRow {
  _FloorInputRow({String? floorLabel})
      : floorLabelController = TextEditingController(text: floorLabel),
        capacityController = TextEditingController();

  final TextEditingController floorLabelController;
  final TextEditingController capacityController;

  void dispose() {
    floorLabelController.dispose();
    capacityController.dispose();
  }
}

class _OperatorRegisterPageState extends State<OperatorRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _sizeController = TextEditingController();
  final _tariffController = TextEditingController();
  final _mapsLinkController = TextEditingController();

  // Mulai dengan 1 baris lantai default.
  final List<_FloorInputRow> _floorRows = [_FloorInputRow(floorLabel: '1')];

  File? _selectedImage;
  bool _isLoading = false;

  late final OperatorRegistrationRemoteDataSource _registrationDataSource;

  @override
  void initState() {
    super.initState();
    _registrationDataSource = OperatorRegistrationRemoteDataSource(
      supabaseClient: Supabase.instance.client,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _sizeController.dispose();
    _tariffController.dispose();
    _mapsLinkController.dispose();
    for (final row in _floorRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addFloorRow() {
    setState(() {
      final nextFloorNumber = _floorRows.length + 1;
      _floorRows.add(_FloorInputRow(floorLabel: '$nextFloorNumber'));
    });
  }

  void _removeFloorRow(int index) {
    if (_floorRows.length <= 1) return; // minimal 1 lantai
    setState(() {
      _floorRows[index].dispose();
      _floorRows.removeAt(index);
    });
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

  /// Mengambil latitude & longitude dari link Google Maps yang di-paste user.
  /// Mendukung format umum, contoh:
  /// https://www.google.com/maps?q=-6.914744,107.609810
  /// https://maps.google.com/?q=-6.914744,107.609810
  /// https://www.google.com/maps/@-6.914744,107.609810,15z
  (double, double)? _parseLatLngFromMapsLink(String link) {
    final trimmed = link.trim();
    if (trimmed.isEmpty) return null;

    final regex = RegExp(r'(-?\d{1,3}\.\d+),\s*(-?\d{1,3}\.\d+)');
    final match = regex.firstMatch(trimmed);
    if (match == null) return null;

    final lat = double.tryParse(match.group(1)!);
    final lng = double.tryParse(match.group(2)!);
    if (lat == null || lng == null) return null;

    return (lat, lng);
  }

  /// Mengumpulkan semua input lantai jadi Map<String, int> dan total kapasitas.
  /// Contoh hasil: {"1": 20, "2": 30} dengan total 50.
  (Map<String, int>, int)? _collectFloorCapacities() {
    final result = <String, int>{};
    var total = 0;

    for (final row in _floorRows) {
      final label = row.floorLabelController.text.trim();
      final capacityText = row.capacityController.text.trim();

      if (label.isEmpty || capacityText.isEmpty) return null;

      final capacity = int.tryParse(capacityText);
      if (capacity == null || capacity <= 0) return null;

      result[label] = capacity;
      total += capacity;
    }

    return (result, total);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan unggah foto lokasi lahan parkir Anda.')),
      );
      return;
    }

    final floorData = _collectFloorCapacities();
    if (floorData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nama lantai & kapasitas dengan benar untuk setiap baris.')),
      );
      return;
    }
    final (capacityPerFloor, totalCapacity) = floorData;

    // Lokasi bersifat opsional — kalau link kosong atau tidak valid, tetap lanjut dengan null.
    final latLng = _parseLatLngFromMapsLink(_mapsLinkController.text);

    setState(() => _isLoading = true);

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.path.split('/').last}';
      final photoUrl = await _registrationDataSource.uploadLotPhoto(_selectedImage!, fileName);

      await _registrationDataSource.submitRegistration(
        businessName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        latitude: latLng?.$1,
        longitude: latLng?.$2,
        lotSizeM2: double.tryParse(_sizeController.text.trim()),
        floors: _floorRows.length,
        capacityPerFloor: capacityPerFloor,
        totalCapacity: totalCapacity,
        pricePerHour: double.tryParse(_tariffController.text.trim()) ?? 0,
        photoUrl: photoUrl,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan berhasil dikirim! Menunggu persetujuan Admin.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(RouteNames.home);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pengajuan: $e')),
      );
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
                AppTextField(
                  label: 'Link Google Maps Lokasi (opsional)',
                  controller: _mapsLinkController,
                  hintText: 'https://maps.google.com/?q=-6.914,107.609',
                  prefixIcon: Icons.map_outlined,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 4),
                Text(
                  'Buka lokasi lahan di Google Maps, lalu salin link-nya di sini.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Luas Lahan (m²)',
                  controller: _sizeController,
                  hintText: '150',
                  prefixIcon: Icons.photo_size_select_small_rounded,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Luas wajib diisi' : null,
                ),
                const SizedBox(height: 24),

                // ── Input dinamis per lantai ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kapasitas per Lantai',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addFloorRow,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Tambah Lantai'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...List.generate(_floorRows.length, (index) {
                  final row = _floorRows[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppTextField(
                            label: 'Nama Lantai',
                            controller: row.floorLabelController,
                            hintText: 'Contoh: 1, 2, Basement',
                            prefixIcon: Icons.layers_outlined,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: AppTextField(
                            label: 'Kapasitas',
                            controller: row.capacityController,
                            hintText: '20',
                            prefixIcon: Icons.local_parking_rounded,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        if (_floorRows.length > 1) ...[
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(top: 28),
                            child: IconButton(
                              onPressed: () => _removeFloorRow(index),
                              icon: const Icon(Icons.remove_circle_outline_rounded,
                                  color: AppColors.error, size: 22),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Tarif / Jam (Rp)',
                  controller: _tariffController,
                  hintText: '5000',
                  prefixIcon: Icons.monetization_on_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Tarif wajib diisi' : null,
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