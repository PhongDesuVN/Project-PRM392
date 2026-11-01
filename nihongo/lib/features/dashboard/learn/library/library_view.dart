import 'package:flutter/material.dart';

import '../../../../core/api.dart';
import '../../../../shared/ui.dart';
import '../../../alphabet/alphabet_page.dart';
import '../../../alphabet/models/alphabet_models.dart';
import '../../../auth/login/login_page.dart';
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
  const LibraryView({super.key, this.onTopicTap, this.isGuest = false});

  final ValueChanged<LearningTopic>? onTopicTap;
  final bool isGuest;

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  bool _isExpandedSpecialized = false;
  late final ApiClient _apiClient = ApiClient();

  static const Map<String, String> _defaultTopicCounts = {
    'tu_vung_n4': '20 từ',
    'ngu_phap_n4': '16 mục',
    'han_tu_n4': '5 chữ',
    'tu_vung_n5': '3 từ',
    'xe_co': '4 mục',
    'vat_lieu_dien_nuoc': '6 mục',
    'tho_co_khi': '5 mục',
    'loi_song': '4 mục',
    'it_cntt': '6 mục',
    'xay_dung': '4 mục',
    'dieu_duong': '4 mục',
    'khach_san_nha_hang': '4 mục',
    'nong_nghiep': '3 mục',
    'che_bien_thuc_pham': '3 mục',
    'may_mac': '3 mục',
    'kinh_doanh': '3 mục',
    'giao_tiep_hang_ngay': '5 mục',
    'du_lich_am_thuc': '4 mục',
  };

  late Map<String, String> _topicCounts = Map.from(_defaultTopicCounts);

  @override
  void initState() {
    super.initState();
    _fetchTopicCounts();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _fetchTopicCounts() async {
    try {
      final list = await _apiClient.getList(ApiConfig.topics);
      if (list.isNotEmpty && mounted) {
        final newCounts = Map<String, String>.from(_topicCounts);
        for (final item in list) {
          if (item is Map) {
            final code = item['code']?.toString();
            final countText = item['itemCountText']?.toString();
            if (code != null && countText != null && countText.isNotEmpty) {
              newCounts[code] = countText;
            }
          }
        }
        setState(() {
          _topicCounts = newCounts;
        });
      }
    } catch (_) {
      // Dùng dữ liệu đếm mặc định nếu server offline
    }
  }

  String _getCount(String topicCode) {
    return _topicCounts[topicCode] ?? _defaultTopicCounts[topicCode] ?? '0 mục';
  }

  void _showGuestLoginDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: AppColors.blue),
            SizedBox(width: 8),
            Text(
              'Yêu cầu đăng nhập',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Bạn cần đăng nhập tài khoản để $action và lưu tiến độ học tập cá nhân.',
          style: const TextStyle(fontSize: 14.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Đăng nhập', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleTopicClick(BuildContext context, String title, String subtitle) {
    if (widget.isGuest) {
      _showGuestLoginDialog(context, 'học bài "$title"');
      return;
    }

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
                  if (widget.isGuest) {
                    _showGuestLoginDialog(context, 'học Bảng chữ cái');
                    return;
                  }
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
                  if (widget.isGuest) {
                    _showGuestLoginDialog(context, 'học Bảng chữ cái');
                    return;
                  }
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
                itemCountText: _getCount('tu_vung_n4'),
                onTap: () => _handleTopicClick(
                  context,
                  'Từ vựng N4',
                  _getCount('tu_vung_n4'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LibraryTopicCard(
                title: 'Ngữ pháp N4',
                itemCountText: _getCount('ngu_phap_n4'),
                onTap: () => _handleTopicClick(
                  context,
                  'Ngữ pháp N4',
                  _getCount('ngu_phap_n4'),
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
                title: 'Hán tự N4',
                itemCountText: _getCount('han_tu_n4'),
                onTap: () => _handleTopicClick(
                  context,
                  'Hán tự N4',
                  _getCount('han_tu_n4'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LibraryTopicCard(
                title: 'Từ vựng N5',
                itemCountText: _getCount('tu_vung_n5'),
                onTap: () => _handleTopicClick(
                  context,
                  'Từ vựng N5',
                  _getCount('tu_vung_n5'),
                ),
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
                itemCountText: _getCount('xe_co'),
                onTap: () => _handleTopicClick(
                  context,
                  'Xe cộ',
                  _getCount('xe_co'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LibraryTopicCard(
                title: 'Vật liệu điện và nước',
                itemCountText: _getCount('vat_lieu_dien_nuoc'),
                onTap: () => _handleTopicClick(
                  context,
                  'Vật liệu điện và nước',
                  _getCount('vat_lieu_dien_nuoc'),
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
                itemCountText: _getCount('tho_co_khi'),
                onTap: () => _handleTopicClick(
                  context,
                  'Thợ cơ khí',
                  _getCount('tho_co_khi'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LibraryTopicCard(
                title: 'Lối sống',
                itemCountText: _getCount('loi_song'),
                onTap: () => _handleTopicClick(
                  context,
                  'Lối sống',
                  _getCount('loi_song'),
                ),
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
                  itemCountText: _getCount('it_cntt'),
                  onTap: () => _handleTopicClick(
                    context,
                    'Công nghệ thông tin',
                    _getCount('it_cntt'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LibraryTopicCard(
                  title: 'Xây dựng',
                  itemCountText: _getCount('xay_dung'),
                  onTap: () => _handleTopicClick(
                    context,
                    'Xây dựng',
                    _getCount('xay_dung'),
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
                  title: 'Điều dưỡng & Y tế',
                  itemCountText: _getCount('dieu_duong'),
                  onTap: () => _handleTopicClick(
                    context,
                    'Điều dưỡng & Y tế',
                    _getCount('dieu_duong'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LibraryTopicCard(
                  title: 'Khách sạn & Nhà hàng',
                  itemCountText: _getCount('khach_san_nha_hang'),
                  onTap: () => _handleTopicClick(
                    context,
                    'Khách sạn & Nhà hàng',
                    _getCount('khach_san_nha_hang'),
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
                  itemCountText: _getCount('nong_nghiep'),
                  onTap: () => _handleTopicClick(
                    context,
                    'Nông nghiệp',
                    _getCount('nong_nghiep'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LibraryTopicCard(
                  title: 'Chế biến thực phẩm',
                  itemCountText: _getCount('che_bien_thuc_pham'),
                  onTap: () => _handleTopicClick(
                    context,
                    'Chế biến thực phẩm',
                    _getCount('che_bien_thuc_pham'),
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
                  itemCountText: _getCount('may_mac'),
                  onTap: () => _handleTopicClick(
                    context,
                    'May mặc',
                    _getCount('may_mac'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LibraryTopicCard(
                  title: 'Kinh doanh & Thương mại',
                  itemCountText: _getCount('kinh_doanh'),
                  onTap: () => _handleTopicClick(
                    context,
                    'Kinh doanh & Thương mại',
                    _getCount('kinh_doanh'),
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
                itemCountText: _getCount('giao_tiep_hang_ngay'),
                onTap: () => _handleTopicClick(
                  context,
                  'Giao tiếp hàng ngày',
                  _getCount('giao_tiep_hang_ngay'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LibraryTopicCard(
                title: 'Du lịch & Ẩm thực',
                itemCountText: _getCount('du_lich_am_thuc'),
                onTap: () => _handleTopicClick(
                  context,
                  'Du lịch & Ẩm thực',
                  _getCount('du_lich_am_thuc'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
