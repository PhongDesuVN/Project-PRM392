import 'package:flutter/material.dart';

import '../../../shared/ui.dart';

/// Modal Bottom Sheet hiển thị danh sách các tính năng trong "Tiện ích mở rộng":
/// - Từ điển
/// - Dịch
/// - Học tập
/// - Thi thử
class ExtensionsBottomSheet extends StatelessWidget {
  const ExtensionsBottomSheet({
    super.key,
    required this.onOpenDictionary,
    required this.onOpenTranslation,
    required this.onOpenLearning,
    required this.onOpenMockExam,
  });

  final VoidCallback onOpenDictionary;
  final VoidCallback onOpenTranslation;
  final VoidCallback onOpenLearning;
  final VoidCallback onOpenMockExam;

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onOpenDictionary,
    required VoidCallback onOpenTranslation,
    required VoidCallback onOpenLearning,
    required VoidCallback onOpenMockExam,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExtensionsBottomSheet(
        onOpenDictionary: onOpenDictionary,
        onOpenTranslation: onOpenTranslation,
        onOpenLearning: onOpenLearning,
        onOpenMockExam: onOpenMockExam,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh gạt vuốt (Drag handle)
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tiêu đề & nút đóng
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tiện ích mở rộng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E242B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Truy cập nhanh các công cụ học tiếng Nhật',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.placeholder,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lưới 2x2 các tùy chọn tiện ích
            Row(
              children: [
                Expanded(
                  child: _ExtensionCard(
                    title: 'Từ điển',
                    subtitle: 'Tra cứu từ vựng, ngữ pháp, kanji',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF1976D2),
                    onTap: () {
                      Navigator.pop(context);
                      onOpenDictionary();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExtensionCard(
                    title: 'Dịch',
                    subtitle: 'Dịch câu, văn bản Nhật - Việt',
                    icon: Icons.g_translate_rounded,
                    color: const Color(0xFF00897B),
                    onTap: () {
                      Navigator.pop(context);
                      onOpenTranslation();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ExtensionCard(
                    title: 'Học tập',
                    subtitle: 'Bảng chữ cái, sổ tay & thư viện',
                    icon: Icons.school_rounded,
                    color: const Color(0xFF7E57C2),
                    onTap: () {
                      Navigator.pop(context);
                      onOpenLearning();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExtensionCard(
                    title: 'Thi thử',
                    subtitle: 'Luyện thi chứng chỉ JLPT N5 - N1',
                    icon: Icons.fact_check_rounded,
                    color: const Color(0xFFE65100),
                    onTap: () {
                      Navigator.pop(context);
                      onOpenMockExam();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtensionCard extends StatelessWidget {
  const _ExtensionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.22),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E242B),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade600,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

