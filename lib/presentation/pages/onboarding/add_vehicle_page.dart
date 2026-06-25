import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_strings.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/app_text_field.dart';
import 'package:parqr/presentation/widgets/form_feedback_banner.dart';

enum _FormStatus { idle, loading, error, success }

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  String? _vehicleType;
  bool _hasPhoto = false;
  _FormStatus _status = _FormStatus.idle;
  String? _feedbackMessage;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false) || _vehicleType == null) {
      setState(() {
        _status = _FormStatus.error;
        _feedbackMessage =
            'Lengkapi merk, model, jenis, dan nomor polisi kendaraan.';
      });
      return;
    }

    setState(() {
      _status = _FormStatus.loading;
      _feedbackMessage = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _status = _FormStatus.success;
      _feedbackMessage = 'Kendaraan tersimpan. Kamu bisa lanjut ke Home.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addVehicle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Tambahkan kendaraan', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Kendaraan ini akan dipakai saat booking parkir dan validasi QR.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: AppStrings.brand,
                  controller: _brandController,
                  hintText: 'Contoh: Honda',
                  prefixIcon: Icons.directions_car_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Merk kendaraan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: AppStrings.model,
                  controller: _modelController,
                  hintText: 'Contoh: Vario 125',
                  prefixIcon: Icons.two_wheeler_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Model kendaraan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 18),
                Text('Jenis Kendaraan',
                    style: AppTextStyles.caption
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'motor',
                      icon: Icon(Icons.two_wheeler_rounded),
                      label: Text('Motor'),
                    ),
                    ButtonSegment(
                      value: 'mobil',
                      icon: Icon(Icons.directions_car_rounded),
                      label: Text('Mobil'),
                    ),
                  ],
                  selected: _vehicleType == null ? <String>{} : {_vehicleType!},
                  emptySelectionAllowed: true,
                  onSelectionChanged: (values) {
                    setState(() =>
                        _vehicleType = values.isEmpty ? null : values.first);
                  },
                ),
                if (_status == _FormStatus.error && _vehicleType == null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Jenis kendaraan wajib dipilih',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: 18),
                AppTextField(
                  label: AppStrings.plateNumber,
                  controller: _plateController,
                  hintText: 'Contoh: B 1234 QR',
                  prefixIcon: Icons.pin_outlined,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'Nomor polisi wajib diisi';
                    if (text.length < 4) return 'Nomor polisi belum valid';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _VehiclePhotoPicker(
                  hasPhoto: _hasPhoto,
                  onTap: () => setState(() => _hasPhoto = true),
                ),
                const SizedBox(height: 28),
                if (_feedbackMessage != null) ...[
                  FormFeedbackBanner(
                    message: _feedbackMessage!,
                    type: _status == _FormStatus.success
                        ? FormFeedbackType.success
                        : FormFeedbackType.error,
                  ),
                  const SizedBox(height: 18),
                ],
                AppButton(
                  label: AppStrings.save,
                  icon: Icons.save_outlined,
                  isLoading: _status == _FormStatus.loading,
                  onPressed: _status == _FormStatus.loading ? null : _submit,
                ),
                const SizedBox(height: 14),
                AppButton(
                  label: 'Masuk ke Home',
                  icon: Icons.home_rounded,
                  variant: AppButtonVariant.secondary,
                  onPressed: _status == _FormStatus.success
                      ? () => context.go(RouteNames.home)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VehiclePhotoPicker extends StatelessWidget {
  const _VehiclePhotoPicker({
    required this.hasPhoto,
    required this.onTap,
  });

  final bool hasPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.vehiclePhoto,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Material(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasPhoto ? AppColors.success : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasPhoto
                        ? Icons.check_circle_rounded
                        : Icons.add_photo_alternate_outlined,
                    color: hasPhoto ? AppColors.success : AppColors.accentBlue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasPhoto
                          ? 'Foto kendaraan dipilih'
                          : 'Upload foto kendaraan',
                      style: AppTextStyles.body,
                    ),
                  ),
                  Text('Opsional', style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
