import 'package:flutter/material.dart';

import '../../../../shared/ui.dart';
import '../../learning_topic.dart';
import 'widgets/alphabet_card.dart';
import 'widgets/library_topic_card.dart';

/// Màn hình "Thư viện" chi tiết theo ảnh thiết kế:
/// - Bảng chữ cái: Hira (あ) & Kata (ア)
/// - JLPT: Từ vựng N4, Ngữ pháp N4, Hán tự N4, Từ vựng N5
/// - Chuyên ngành (có nút Xem thêm): Xe cộ, Vật liệu điện và nước, Thợ cơ khí, Lối sống
/// - Khác: Giao tiếp hàng ngày, Du lịch & Ẩm thực
class LibraryView extends StatelessWidget {
  const LibraryView({
    super.key,
    this.onTopicTap,
  });

  final ValueChanged<LearningTopic>? onTopicTap;

  void _handleTopicClick(BuildContext context, String title, String subtitle) {
    // Nếu trùng với topic có sẵn trong hệ thống thì mở bài học chi tiết
    final matchedTopic = learningTopics.cast<LearningTopic?>().firstWhere(
          (t) =>
              t?.title.toLowerCase() == title.toLowerCase() ||
              (title == 'Hira' && t?.title == 'Hiragana') ||
              (title == 'Kata' && t?.title == 'Katakana'),
          orElse: () => null,
        );

    if (matchedTopic != null && onTopicTap != null) {
      onTopicTap!(matchedTopic);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$title ($subtitle) sẽ sớm được cập nhật bài tập!'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // ================= SECTION 1: BẢNG CHỮ CÁI =================
        const Text(
          'Bảng chữ cái',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242B),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AlphabetCard(
                title: 'Hira',
                badgeSymbol: 'あ',
                themeColor: const Color(0xFF1976D2),
                borderColor: const Color(0xFF90CAF9),
                badgeColor: const Color(0xFF1565C0),
                badgeRotation: -0.15,
                onTap: () => _handleTopicClick(context, 'Hira', '46 chữ cái'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AlphabetCard(
                title: 'Kata',
                badgeSymbol: 'ア',
                themeColor: const Color(0xFFE65100),
                borderColor: const Color(0xFFFFCC80),
                badgeColor: const Color(0xFFFFA000),
                badgeRotation: 0.15,
                onTap: () => _handleTopicClick(context, 'Kata', '46 chữ cái'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ================= SECTION 2: JLPT =================
        const Text(
          'JLPT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242B),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: LibraryTopicCard(
                title: 'Từ vựng N4',
                itemCountText: '523 từ',
                onTap: () =>
                    _handleTopicClick(context, 'Từ vựng N4', '523 từ'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LibraryTopicCard(
                title: 'Ngữ pháp N4',
                itemCountText: '436 từ',
                onTap: () =>
                    _handleTopicClick(context, 'Ngữ pháp N4', '436 từ'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: LibraryTopicCard(
                title: 'Hán tự N4',
                itemCountText: '167 từ',
                onTap: () =>
                    _handleTopicClick(context, 'Hán tự N4', '167 từ'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LibraryTopicCard(
                title: 'Từ vựng N5',
                itemCountText: '571 từ',
                onTap: () =>
                    _handleTopicClick(context, 'Từ vựng N5', '571 từ'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ================= SECTION 3: CHUYÊN NGÀNH =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Chuyên ngành',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E242B),
              ),
            ),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Danh sách chuyên ngành mở rộng đang cập nhật.'),
                    ),
                  );
              },
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Xem thêm',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: LibraryTopicCard(
                title: 'Xe cộ',
                itemCountText: '4 mục',
                onTap: () => _handleTopicClick(context, 'Xe cộ', '4 mục'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LibraryTopicCard(
                title: 'Vật liệu điện và nước',
                itemCountText: '6 mục',
                onTap: () =>
                    _handleTopicClick(context, 'Vật liệu điện và nước', '6 mục'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: LibraryTopicCard(
                title: 'Thợ cơ khí',
                itemCountText: '7 mục',
                onTap: () => _handleTopicClick(context, 'Thợ cơ khí', '7 mục'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LibraryTopicCard(
                title: 'Lối sống',
                itemCountText: '12 mục',
                onTap: () => _handleTopicClick(context, 'Lối sống', '12 mục'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ================= SECTION 4: KHÁC =================
        const Text(
          'Khác',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E242B),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: LibraryTopicCard(
                title: 'Giao tiếp hàng ngày',
                itemCountText: '15 mục',
                onTap: () =>
                    _handleTopicClick(context, 'Giao tiếp hàng ngày', '15 mục'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LibraryTopicCard(
                title: 'Du lịch & Ẩm thực',
                itemCountText: '8 mục',
                onTap: () =>
                    _handleTopicClick(context, 'Du lịch & Ẩm thực', '8 mục'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
