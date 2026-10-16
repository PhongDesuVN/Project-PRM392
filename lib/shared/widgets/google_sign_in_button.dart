import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.googleBackground,
          foregroundColor: AppColors.googleRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'G',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4285F4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Đăng nhập với Google',
              style: TextStyle(
                color: AppColors.googleRed,
                fontSize: 19,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}