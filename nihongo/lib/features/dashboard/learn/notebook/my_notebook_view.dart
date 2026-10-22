import 'package:flutter/material.dart';

import '../../../../shared/ui.dart';
import 'widgets/overview_stat_card.dart';

/// Màn hình "Sổ tay của tôi":
/// - Phần "Tổng quan" với 4 trạng thái học tập (Chưa thuộc, Thuộc lơ mơ, Thuộc kha khá, Thuộc làu làu).
/// - Nút "Ôn tập sổ tay".
/// - Đã lược bỏ phần "Học lặp lại ngắt quãng" và "Danh sách sổ tay" theo yêu cầu.
class MyNotebookView extends StatelessWidget {
  const MyNotebookView({
    super.key,
    this.onReviewNotebook,
    this.onStatTap,
  });

  final VoidCallback? onReviewNotebook;
  final ValueChanged<String>? onStatTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const Text(
          'Tổng quan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242B),
          ),
        ),
        const SizedBox(height: 14),

        // Lưới 4 thẻ trạng thái học tập (2x2)
        Row(
          children: [
            Expanded(
              child: OverviewStatCard(
                title: 'Chưa thuộc',
                indicatorColor: const Color(0xFFE53935),
                value: '--',
                onTap: () => onStatTap?.call('Chưa thuộc'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OverviewStatCard(
                title: 'Thuộc lơ mơ',
                indicatorColor: const Color(0xFFFFB300),
                value: '--',
                onTap: () => onStatTap?.call('Thuộc lơ mơ'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OverviewStatCard(
                title: 'Thuộc kha khá',
                indicatorColor: const Color(0xFF1E88E5),
                value: '--',
                onTap: () => onStatTap?.call('Thuộc kha khá'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OverviewStatCard(
                title: 'Thuộc làu làu',
                indicatorColor: const Color(0xFF43A047),
                value: '--',
                onTap: () => onStatTap?.call('Thuộc làu làu'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Nút bấm "Ôn tập sổ tay"
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: onReviewNotebook ??
                () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Bắt đầu ôn tập sổ tay!'),
                      ),
                    );
                },
            icon: const Icon(
              Icons.assignment_outlined,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              'Ôn tập sổ tay',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
