import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_strings.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/blocs/vehicle/vehicle_cubit.dart';
import 'package:parqr/presentation/blocs/vehicle/vehicle_state.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/app_text_field.dart';
import 'package:parqr/presentation/widgets/form_feedback_banner.dart';
import 'package:parqr/injection/injection_container.dart';

class AddVehiclePage extends StatelessWidget {
  const AddVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<VehicleCubit>(),
      child: const AddVehicleView(),
    );
  }
}

class AddVehicleView extends StatefulWidget {
  const AddVehicleView({super.key});

  @override
  State<AddVehicleView> createState() => _AddVehicleViewState();
}

class _AddVehicleViewState extends State<AddVehicleView> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  String? _vehicleType;
  bool _hasPhoto = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi merk, model, jenis, dan nomor polisi kendaraan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call VehicleCubit to add vehicle to database
    context.read<VehicleCubit>().addVehicle(
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      vehicleType: _vehicleType!,
      plateNumber: _plateController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VehicleCubit, VehicleState>(
      listener: (context, state) {
        if (state is VehicleAdded) {
          // Vehicle saved successfully, go to home
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kendaraan berhasil ditambahkan! Selamat datang di ParQr.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to home
          context.go(RouteNames.home);
        } else if (state is VehicleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is VehicleLoading;
        final errorMessage = state is VehicleError ? state.message : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.addVehicle),
            automaticallyImplyLeading: false, // Don't allow back during onboarding
          ),
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
                      enabled: !isLoading,
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
                      enabled: !isLoading,
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
                      onSelectionChanged: isLoading ? null : (values) {
                        setState(() =>
                            _vehicleType = values.isEmpty ? null : values.first);
                      },
                    ),
                    if (_vehicleType == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Jenis kendaraan wajib dipilih',
                        style:
                            AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 18),
                    AppTextField(
                      label: AppStrings.plateNumber,
                      controller: _plateController,
                      hintText: 'Contoh: B 1234 QR',
                      prefixIcon: Icons.pin_outlined,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
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
                      onTap: isLoading ? null : () => setState(() => _hasPhoto = true),
                    ),
                    const SizedBox(height: 28),
                    if (errorMessage != null) ...[
                      FormFeedbackBanner(
                        message: errorMessage,
                        type: FormFeedbackType.error,
                      ),
                      const SizedBox(height: 18),
                    ],
                    AppButton(
                      label: 'Simpan & Masuk ke Home',
                      icon: Icons.arrow_forward_rounded,
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VehiclePhotoPicker extends StatelessWidget {
  const _VehiclePhotoPicker({
    required this.hasPhoto,
    this.onTap,
  });

  final bool hasPhoto;
  final VoidCallback? onTap;

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
