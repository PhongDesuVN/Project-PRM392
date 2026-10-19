import 'package:flutter/material.dart';

import '../../shared/ui.dart';

/// Tab Ho so: thong tin tai khoan va nut dang xuat.
class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.email,
    required this.fullName,
    required this.onLogout,
  });

  final String email;
  final String? fullName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final name = fullName?.trim();
    final displayName = name != null && name.isNotEmpty ? name : email;
    final initial = displayName.characters.first.toUpperCase();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text(
          'Tài khoản',
          style: TextStyle(
            color: AppColors.blue,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.blue.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.blue,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (name != null && name.isNotEmpty)
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.darkText, fontSize: 15),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất', style: TextStyle(fontSize: 17)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.blue,
              side: const BorderSide(color: AppColors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
