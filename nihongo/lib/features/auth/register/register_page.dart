import 'package:flutter/material.dart';

import '../../../shared/widgets/auth_text_field.dart';
import '../../../theme/app_theme.dart';
import '../../../shared/widgets/japanese_background.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
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
                  const SizedBox(height: 24),
                  const Text(
                    'Tạo tài khoản',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 66),
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
                          controller: _passwordController,
                          textInputAction: TextInputAction.next,
                          validator: (value) => value == null || value.length < 6
                              ? 'Mật khẩu cần ít nhất 6 ký tự'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          hintText: 'Nhập lại mật khẩu',
                          prefixIcon: Icons.visibility_outlined,
                          isPassword: true,
                          textInputAction: TextInputAction.next,
                          validator: (value) => value != _passwordController.text
                              ? 'Mật khẩu nhập lại chưa khớp'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        const AuthTextField(
                          hintText: 'Mã giới thiệu',
                          prefixIcon: Icons.visibility_outlined,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) => setState(
                            () => _acceptedTerms = value ?? false,
                          ),
                          side: const BorderSide(
                            color: AppColors.placeholder,
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Tôi đồng ý với các ',
                              style: TextStyle(
                                color: AppColors.darkText,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showMessage(
                                'Điều khoản sử dụng sẽ được cập nhật.',
                              ),
                              child: const Text(
                                'điều khoản sử dụng',
                                style: TextStyle(
                                  color: AppColors.blue,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Text(
                              ' của Nihon',
                              style: TextStyle(
                                color: AppColors.darkText,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        final isValid = _formKey.currentState!.validate();
                        if (!isValid) return;
                        if (!_acceptedTerms) {
                          _showMessage('Vui lòng đồng ý với điều khoản sử dụng.');
                          return;
                        }
                        _showMessage('Giao diện đăng ký đã sẵn sàng.');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text('Đăng kí', style: TextStyle(fontSize: 19)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 60, bottom: 20),
                    child: _LoginFooter(),
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Bạn đã có tài khoản?',
          style: TextStyle(color: AppColors.darkText, fontSize: 16),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 5),
          ),
          child: const Text(
            'Đăng nhập',
            style: TextStyle(
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}