import 'package:flutter/material.dart';

/// Thẻ thống kê trong mục "Tổng quan" của Sổ tay
class OverviewStatCard extends StatelessWidget {
  const OverviewStatCard({
    super.key,
    required this.title,
    required this.indicatorColor,
    this.value = '--',
    this.count,
    this.unit = 'câu',
    this.onTap,
  });

  final String title;
  final Color indicatorColor;
  final String value;
  final int? count;
  final String unit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveCount = count;
    final isDash = effectiveCount == null
        ? (value == '--' || value == '0' || value == '0 từ' || value == '0 câu')
        : (effectiveCount == 0);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9EDF1), width: 1.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3.5,
                height: 42,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (isDash)
                      const Text(
                        '--',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF9AA5B1),
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            effectiveCount != null
                                ? '$effectiveCount'
                                : value.replaceAll(RegExp(r'[^0-9]'), ''),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E242B),
                            ),
                          ),
                          Text(
                            unit,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF718096),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
