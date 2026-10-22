import 'package:flutter/material.dart';

/// Thẻ bảng chữ cái (Hira / Kata) với viền màu và huy hiệu ký tự tiếng Nhật xoay nhẹ ở góc trên phải.
class AlphabetCard extends StatelessWidget {
  const AlphabetCard({
    super.key,
    required this.title,
    required this.badgeSymbol,
    required this.themeColor,
    required this.borderColor,
    required this.badgeColor,
    this.badgeRotation = 0.0,
    this.onTap,
  });

  final String title;
  final String badgeSymbol;
  final Color themeColor;
  final Color borderColor;
  final Color badgeColor;
  final double badgeRotation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Thẻ chính
          Positioned.fill(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: themeColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Huy hiệu ký tự tiếng Nhật ở góc trên phải (xoay góc theo phong cách thiết kế)
          Positioned(
            top: -6,
            right: 12,
            child: Transform.rotate(
              angle: badgeRotation,
              child: IgnorePointer(
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badgeSymbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
