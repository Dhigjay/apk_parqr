import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_strings.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/app_text_field.dart';
import 'package:parqr/presentation/widgets/form_feedback_banner.dart';

enum _FormStatus { idle, loading, error, success }

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  _FormStatus _status = _FormStatus.idle;
  String? _feedbackMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _status = _FormStatus.error;
        _feedbackMessage = 'Masukkan email valid untuk menerima link reset.';
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
      _feedbackMessage =
          'Jika email terdaftar, link reset kata sandi akan dikirim.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Kata Sandi')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppStrings.forgotPass, style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Masukkan email akun ParQr. Kami akan menyiapkan tautan untuk membuat kata sandi baru.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  hintText: 'nama@email.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Email wajib diisi';
                    if (!text.contains('@')) return 'Format email belum valid';
                    return null;
                  },
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
                  label: 'Kirim Link Reset',
                  icon: Icons.mark_email_read_outlined,
                  isLoading: _status == _FormStatus.loading,
                  onPressed: _status == _FormStatus.loading ? null : _submit,
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Kembali ke Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
