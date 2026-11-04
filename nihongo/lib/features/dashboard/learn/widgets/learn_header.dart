import 'package:flutter/material.dart';

import '../../../../shared/ui.dart';

/// Header của màn hình Học tập: Tiêu đề "Học tập" và nút "Nâng cấp" giống ảnh mẫu
class LearnHeader extends StatelessWidget {
  const LearnHeader({super.key, this.onUpgradeTap});

  final VoidCallback? onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Học tập',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (onUpgradeTap != null) {
              onUpgradeTap!();
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng Nâng cấp VIP đang được cập nhật!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3DF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  size: 16,
                  color: AppColors.gold,
                ),
                SizedBox(width: 4),
                Text(
                  'Nâng cấp',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
