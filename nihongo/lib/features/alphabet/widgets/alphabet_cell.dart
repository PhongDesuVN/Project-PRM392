import 'package:flutter/material.dart';

import '../../../shared/ui.dart';
import '../models/alphabet_models.dart';

/// Widget hiển thị 1 ô ký tự trong bảng chữ cái (hoặc ô trống)
class AlphabetCell extends StatelessWidget {
  const AlphabetCell({super.key, required this.item, this.onTap});

  final AlphabetItem? item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      // Ô trống giữ khoảng cách đều
      return const SizedBox();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item!.character,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item!.romaji,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
