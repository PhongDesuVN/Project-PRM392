import 'package:flutter/material.dart';

import '../../../core/api.dart';
import '../../../shared/ui.dart';
import '../auth_service.dart';
import 'reset_password_page.dart';

Future<void> showForgotPasswordDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const ForgotPasswordDialog(),
  );
}

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    setState(() => _isLoading = true);

    try {
      final message = await _authService.forgotPassword(email: email);
      if (!mounted) return;

      // Backend dev mode nhet token vao message dang "[dev] token=xxx".
      final match = RegExp(r'token=(\S+)').firstMatch(message);
      final devToken = match?.group(1);

      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            devToken != null
                ? 'Đã tạo mã đặt lại mật khẩu.'
                : 'Nếu email hợp lệ, bạn sẽ nhận được hướng dẫn đặt lại mật khẩu.',
          ),
        ),
      );

      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => ResetPasswordPage(
            email: email,
            prefilledToken: devToken,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _emailController.text.contains('@') && !_isLoading;

    return AlertDialog(
      title: const Text(
        'Nhập email tài khoản Nihon của bạn',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      content: TextField(
        controller: _emailController,
        autofocus: true,
        enabled: !_isLoading,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: const TextStyle(color: AppColors.placeholder),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE8ECEF),
                    foregroundColor: AppColors.darkText,
                  ),
                  child: const Text('Hủy', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: canSubmit ? _submit : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Ok', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
