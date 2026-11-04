import 'package:flutter/material.dart';

import '../../../../shared/ui.dart';

/// Thanh tab bar chuyển đổi chỉ gồm 2 mục: "Sổ tay của tôi" và "Thư viện".
class LearnTopTabBar extends StatelessWidget {
  const LearnTopTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  static const List<String> tabs = ['Sổ tay của tôi', 'Thư viện'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < tabs.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _TabPill(
              title: tabs[i],
              isSelected: selectedIndex == i,
              onTap: () => onTabChanged(i),
            ),
          ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.border,
              width: 1,
            ),
            boxShadow: null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
