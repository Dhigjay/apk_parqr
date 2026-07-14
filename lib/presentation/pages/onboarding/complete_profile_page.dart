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

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<ProfileCubit>().completeProfile(
          name: _fullNameController.text.trim(),
          address: _addressController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileCompleted) {
          // Profil tersimpan, langsung navigasi ke halaman tambah kendaraan
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Profil berhasil disimpan! Silakan tambahkan kendaraan.'),
              backgroundColor: Colors.green,
            ),
          );
          context.go(RouteNames.addVehicle);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileLoading;
        final errorMessage = state is ProfileError ? state.message : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.completeProfile),
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
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
                      enabled: !isLoading,
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
                      textInputAction: TextInputAction.done,
                      maxLines: 4,
                      enabled: !isLoading,
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Alamat wajib diisi'
                          : null,
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
                      label: 'Simpan & Lanjut Tambah Kendaraan',
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
