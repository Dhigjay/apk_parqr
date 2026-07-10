import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_strings.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/injection/injection_container.dart';
import 'package:parqr/presentation/blocs/profile/profile_cubit.dart';
import 'package:parqr/presentation/blocs/profile/profile_state.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/app_text_field.dart';
import 'package:parqr/presentation/widgets/form_feedback_banner.dart';

enum _FormStatus { idle, loading, error, success }

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>(),
      child: const _CompleteProfileView(),
    );
  }
}

class _CompleteProfileView extends StatefulWidget {
  const _CompleteProfileView();

  @override
  State<_CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<_CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  _FormStatus _status = _FormStatus.idle;
  String? _feedbackMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _status = _FormStatus.error;
        _feedbackMessage = 'Nama lengkap dan alamat wajib diisi.';
      });
      return;
    }

    // Panggil ProfileCubit untuk benar-benar menyimpan ke Supabase
    context.read<ProfileCubit>().completeProfile(
          name: _fullNameController.text.trim(),
          address: _addressController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.completeProfile)),
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoading) {
              setState(() {
                _status = _FormStatus.loading;
                _feedbackMessage = null;
              });
            } else if (state is ProfileLoaded) {
              setState(() {
                _status = _FormStatus.success;
                _feedbackMessage =
                    'Profil tersimpan. Lanjut tambahkan kendaraan.';
              });
            } else if (state is ProfileError) {
              setState(() {
                _status = _FormStatus.error;
                _feedbackMessage = state.message;
              });
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Lengkapi profilmu', style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    Text(
                      'Data ini membantu operator mengenali pemilik kendaraan saat proses parkir.',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      label: AppStrings.fullName,
                      controller: _fullNameController,
                      hintText: 'Nama sesuai identitas',
                      prefixIcon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Nama lengkap wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: AppStrings.address,
                      controller: _addressController,
                      hintText: 'Alamat rumah',
                      prefixIcon: Icons.home_outlined,
                      textInputAction: TextInputAction.newline,
                      maxLines: 4,
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Alamat wajib diisi'
                          : null,
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
                      onPressed:
                          _status == _FormStatus.loading ? null : _submit,
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      label: 'Lanjut Tambah Kendaraan',
                      icon: Icons.directions_car_filled_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: _status == _FormStatus.success
                          ? () => context.go(RouteNames.addVehicle)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
