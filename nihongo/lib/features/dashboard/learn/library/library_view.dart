import 'package:flutter/material.dart';

import '../../../../shared/ui.dart';
import '../../../alphabet/alphabet_page.dart';
import '../../../alphabet/models/alphabet_models.dart';
import '../../../learn/topic_words/topic_words_page.dart';
import '../../learning_topic.dart';
import 'widgets/alphabet_card.dart';
import 'widgets/library_topic_card.dart';

/// Màn hình "Thư viện" chi tiết theo ảnh thiết kế:
/// - Bảng chữ cái: Hira (あ) & Kata (ア)
/// - JLPT: Từ vựng N4, Ngữ pháp N4, Hán tự N4, Từ vựng N5
/// - Chuyên ngành (có nút Xem thêm): Xe cộ, Vật liệu điện và nước, Thợ cơ khí, Lối sống
/// - Khác: Giao tiếp hàng ngày, Du lịch & Ẩm thực
class LibraryView extends StatefulWidget {
  const LibraryView({super.key, this.onTopicTap});

  final ValueChanged<LearningTopic>? onTopicTap;

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  bool _isExpandedSpecialized = false;

  void _handleTopicClick(BuildContext context, String title, String subtitle) {
    final topicCode = _resolveTopicCode(title);

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TopicWordsPage(
          topicCode: topicCode,
          topicTitle: title,
        ),
      ),
    );
  }

  String _resolveTopicCode(String title) {
    switch (title.trim()) {
      case 'Từ vựng N4':
        return 'tu_vung_n4';
      case 'Ngữ pháp N4':
        return 'ngu_phap_n4';
      case 'Hán tự N4':
        return 'han_tu_n4';
      case 'Từ vựng N5':
        return 'tu_vung_n5';
      case 'Xe cộ':
        return 'xe_co';
      case 'Vật liệu điện và nước':
        return 'vat_lieu_dien_nuoc';
      case 'Thợ cơ khí':
        return 'tho_co_khi';
      case 'Lối sống':
        return 'loi_song';
      case 'Công nghệ thông tin':
        return 'it_cntt';
      case 'Xây dựng':
        return 'xay_dung';
      case 'Điều dưỡng & Y tế':
        return 'dieu_duong';
      case 'Khách sạn & Nhà hàng':
        return 'khach_san_nha_hang';
      case 'Nông nghiệp':
        return 'nong_nghiep';
      case 'Chế biến thực phẩm':
        return 'che_bien_thuc_pham';
      case 'May mặc':
        return 'may_mac';
      case 'Kinh doanh & Thương mại':
        return 'kinh_doanh';
      case 'Giao tiếp hàng ngày':
        return 'giao_tiep_hang_ngay';
      case 'Du lịch & Ẩm thực':
        return 'du_lich_am_thuc';
      default:
        return 'tu_vung_n4';
    }
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const AlphabetPage(script: AlphabetScript.hiragana),
                    ),
                  );
                },
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const AlphabetPage(script: AlphabetScript.katakana),
                    ),
                  );
                },
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
                onTap: () => _handleTopicClick(context, 'Từ vựng N4', '523 từ'),
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
                onTap: () => _handleTopicClick(context, 'Hán tự N4', '167 từ'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LibraryTopicCard(
                title: 'Từ vựng N5',
                itemCountText: '571 từ',
                onTap: () => _handleTopicClick(context, 'Từ vựng N5', '571 từ'),
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
                setState(() {
                  _isExpandedSpecialized = !_isExpandedSpecialized;
                });
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isExpandedSpecialized ? 'Thu gọn' : 'Xem thêm',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blue,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      _isExpandedSpecialized
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.blue,
                    ),
                  ],
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
                onTap: () => _handleTopicClick(
                  context,
                  'Vật liệu điện và nước',
                  '6 mục',
                ),
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
        if (_isExpandedSpecialized) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LibraryTopicCard(
                  title: 'Công nghệ thông tin',
                  itemCountText: '6 mục',
                  onTap: () => _handleTopicClick(
                    context,
                    'Công nghệ thông tin',
                    '6 mục',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LibraryTopicCard(
                  title: 'Xây dựng',
                  itemCountText: '4 mục',
                  onTap: () => _handleTopicClick(context, 'Xây dựng', '4 mục'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LibraryTopicCard(
                  title: 'Điều dưỡng & Y tế',
                  itemCountText: '4 mục',
                  onTap: () => _handleTopicClick(
                    context,
                    'Điều dưỡng & Y tế',
                    '4 mục',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LibraryTopicCard(
                  title: 'Khách sạn & Nhà hàng',
                  itemCountText: '4 mục',
                  onTap: () => _handleTopicClick(
                    context,
                    'Khách sạn & Nhà hàng',
                    '4 mục',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LibraryTopicCard(
                  title: 'Nông nghiệp',
                  itemCountText: '3 mục',
                  onTap: () => _handleTopicClick(context, 'Nông nghiệp', '3 mục'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LibraryTopicCard(
                  title: 'Chế biến thực phẩm',
                  itemCountText: '3 mục',
                  onTap: () => _handleTopicClick(
                    context,
                    'Chế biến thực phẩm',
                    '3 mục',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LibraryTopicCard(
                  title: 'May mặc',
                  itemCountText: '3 mục',
                  onTap: () => _handleTopicClick(context, 'May mặc', '3 mục'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LibraryTopicCard(
                  title: 'Kinh doanh & Thương mại',
                  itemCountText: '3 mục',
                  onTap: () => _handleTopicClick(
                    context,
                    'Kinh doanh & Thương mại',
                    '3 mục',
                  ),
                ),
              ),
            ],
          ),
        ],

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
