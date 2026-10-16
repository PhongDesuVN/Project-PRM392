import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Nhập email tài khoản Mazii của bạn',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      content: TextField(
        controller: _emailController,
        autofocus: true,
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
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: _emailController.text.contains('@')
                      ? () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Nếu email hợp lệ, bạn sẽ nhận được hướng dẫn đặt lại mật khẩu.',
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Ok', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}