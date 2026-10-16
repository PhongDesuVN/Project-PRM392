import 'package:flutter/material.dart';

import '../../../shared/widgets/auth_text_field.dart';
import '../../../shared/widgets/google_sign_in_button.dart';
import '../../../shared/widgets/nihon_logo.dart';
import '../../../theme/app_theme.dart';
import '../forgot_password/forgot_password_dialog.dart';
import '../register/register_page.dart';
import '../../../shared/widgets/japanese_background.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:JapaneseBackground(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Quay lại',
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF888888),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const NihonLogo(),
                  const SizedBox(height: 72),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthTextField(
                          hintText: 'Nhập email của bạn',
                          prefixIcon: Icons.person_outline,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          hintText: 'Mật khẩu',
                          prefixIcon: Icons.visibility_outlined,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Vui lòng nhập mật khẩu'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PrimaryButton(
                    label: 'Đăng nhập',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showMessage('Giao diện đăng nhập đã sẵn sàng.');
                      }
                    },
                  ),
                  const SizedBox(height: 22),
                  TextButton(
                    onPressed: () => showForgotPasswordDialog(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkText,
                    ),
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GoogleSignInButton(
                    onPressed: () =>
                        _showMessage('Đăng nhập Google chưa được kết nối.'),
                  ),
                  const SizedBox(height: 68),
                  Padding(
                    padding: const EdgeInsets.only(top: 68, bottom: 24),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Bạn chưa có tài khoản Nihon?',
                          style: TextStyle(
                            color: AppColors.darkText,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const RegisterPage(),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                          ),
                          child: const Text(
                            'Đăng kí',
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!value.contains('@')) return 'Email không hợp lệ';
    return null;
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 19)),
      ),
    );
  }
}