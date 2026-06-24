import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_strings.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/app_text_field.dart';
import 'package:parqr/presentation/widgets/form_feedback_banner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/presentation/blocs/auth/auth_bloc.dart';
import 'package:parqr/presentation/blocs/auth/auth_event.dart';
import 'package:parqr/presentation/blocs/auth/auth_state.dart';
import 'package:parqr/core/router/route_names.dart';

enum _FormStatus { idle, loading, error, success }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text,
              password: _passwordController.text,
              name: _nameController.text,
              phone: _phoneController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(RouteNames.home);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.register)),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Text('Buat akun ParQr', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Daftar untuk mulai mencari tempat parkir dan menyimpan kendaraanmu.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: AppStrings.fullName,
                  controller: _nameController,
                  hintText: 'Nama lengkap',
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  hintText: 'nama@email.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Email wajib diisi';
                    if (!text.contains('@')) return 'Format email belum valid';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: AppStrings.phone,
                  controller: _phoneController,
                  hintText: '08xxxxxxxxxx',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Nomor HP wajib diisi'
                      : null,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: AppStrings.password,
                  controller: _passwordController,
                  hintText: 'Minimal 6 karakter',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                  ),
                  validator: (value) {
                    if ((value ?? '').isEmpty) {
                      return 'Kata sandi wajib diisi';
                    }
                    if ((value ?? '').length < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                if (state is AuthError) ...[
                  FormFeedbackBanner(
                    message: state.message,
                    type: FormFeedbackType.error,
                  ),
                  const SizedBox(height: 18),
                ],
                AppButton(
                  label: AppStrings.register,
                  icon: Icons.person_add_alt_1_rounded,
                  isLoading: state is AuthLoading,
                  onPressed: state is AuthLoading ? null : _submit,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.hasAccount,
                        style: AppTextStyles.bodySecondary),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(AppStrings.login),
                    ),
                  ],
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
