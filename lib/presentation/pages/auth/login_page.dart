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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  _FormStatus _status = _FormStatus.idle;
  String? _feedbackMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _status = _FormStatus.error;
        _feedbackMessage = 'Email dan kata sandi wajib diisi dengan benar.';
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
      _feedbackMessage = 'Login berhasil. Mengarahkan ke Home.';
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (mounted) context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AuthBrandHeader(
                  title: 'Masuk ke ParQr',
                  subtitle:
                      'Kelola parkir, kendaraan, dan pembayaran dari satu aplikasi.',
                ),
                const SizedBox(height: 36),
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
                  label: AppStrings.password,
                  controller: _passwordController,
                  hintText: 'Minimal 6 karakter',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(RouteNames.forgotPassword),
                    child: const Text(AppStrings.forgotPass),
                  ),
                ),
                const SizedBox(height: 12),
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
                  label: AppStrings.login,
                  icon: Icons.login_rounded,
                  isLoading: _status == _FormStatus.loading,
                  onPressed: _status == _FormStatus.loading ? null : _submit,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.noAccount,
                        style: AppTextStyles.bodySecondary),
                    TextButton(
                      onPressed: () => context.push(RouteNames.register),
                      child: const Text(AppStrings.register),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(Icons.local_parking_rounded,
              size: 42, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(AppStrings.appName, style: AppTextStyles.h1),
        const SizedBox(height: 8),
        Text(title, style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text(subtitle, style: AppTextStyles.bodySecondary),
      ],
    );
  }
}
