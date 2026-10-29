import 'package:flutter/material.dart';

import '../../../../shared/ui.dart';
import '../../../learn/topic_words/flashcard_page.dart';
import 'models/notebook_item.dart';
import 'notebook_words_list_page.dart';
import 'services/notebook_service.dart';
import 'widgets/notebook_list_section.dart';
import 'widgets/overview_stat_card.dart';

/// Màn hình "Sổ tay của tôi":
/// - Phần "Tổng quan" với 4 trạng thái học tập (Chưa thuộc, Thuộc lơ mơ, Thuộc kha khá, Thuộc làu làu).
/// - Công tắc "Học lặp lại ngắt quãng" (SRS).
/// - Nút "Ôn tập sổ tay (X từ)" thể hiện tổng số từ của các sổ tay bên dưới và khởi chạy Flashcard.
/// - Phần "Danh sách sổ tay" hỗ trợ tạo mới, đổi tên, xóa, tìm kiếm, lọc và xem/ôn tập từng sổ tay.
class MyNotebookView extends StatefulWidget {
  const MyNotebookView({
    super.key,
    this.onReviewNotebook,
    this.onStatTap,
  });

  final VoidCallback? onReviewNotebook;
  final ValueChanged<String>? onStatTap;

  @override
  State<MyNotebookView> createState() => _MyNotebookViewState();
}

class _MyNotebookViewState extends State<MyNotebookView> {
  bool _isSpacedRepetition = false;

  @override
  void initState() {
    super.initState();
    NotebookService.instance.init();
  }

  void _openWordsList(
    BuildContext context,
    NotebookWordStatus status,
    String title,
    Color color,
  ) {
    widget.onStatTap?.call(title);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => NotebookWordsListPage(
          status: status,
          statusTitle: title,
          themeColor: color,
        ),
      ),
    );
  }

  void _openNotebookWords(NotebookItem item) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => NotebookWordsListPage(
          notebookId: item.id,
          statusTitle: item.title,
          themeColor: AppColors.blue,
        ),
      ),
    );
  }

  void _startReviewNotebook(BuildContext context, {NotebookItem? targetNotebook}) {
    if (widget.onReviewNotebook != null && targetNotebook == null) {
      widget.onReviewNotebook!();
      return;
    }

    final service = NotebookService.instance;
    final notebookToReview = targetNotebook ?? service.selectedNotebook;
    final reviewWords = service.getAllReviewWords(notebookId: notebookToReview?.id);

    if (reviewWords.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              notebookToReview != null
                  ? 'Sổ tay "${notebookToReview.title}" chưa có từ nào để ôn tập!'
                  : 'Sổ tay chưa có từ nào! Hãy học bài ở phần Thư viện trước nhé.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final title = notebookToReview != null
        ? 'Ôn tập: ${notebookToReview.title}'
        : 'Ôn tập sổ tay';

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FlashcardPage(
          topicTitle: title,
          words: reviewWords,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NotebookService.instance,
      builder: (context, _) {
        final service = NotebookService.instance;
        final stats = service.stats;
        final selected = service.selectedNotebook;

        // Số từ hiển thị trên nút "Ôn tập sổ tay (X từ)"
        final reviewCount = selected != null
            ? selected.wordCount
            : service.totalReviewWordsCount;

        final buttonLabel = selected != null
            ? (reviewCount > 0
                ? 'Ôn tập "${selected.title}" ($reviewCount từ)'
                : 'Ôn tập "${selected.title}"')
            : (reviewCount > 0
                ? 'Ôn tập sổ tay ($reviewCount từ)'
                : 'Ôn tập sổ tay');

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Tiêu đề phần Tổng quan
            const Text(
              'Tổng quan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E242B),
              ),
            ),
            const SizedBox(height: 14),

            // Lưới 4 thẻ trạng thái học tập (2x2) giống ảnh chụp
            Row(
              children: [
                Expanded(
                  child: OverviewStatCard(
                    title: 'Chưa thuộc',
                    indicatorColor: const Color(0xFFE53935),
                    count: stats.chuaThuoc,
                    unit: 'câu',
                    onTap: () => _openWordsList(
                      context,
                      NotebookWordStatus.chuaThuoc,
                      'Chưa thuộc',
                      const Color(0xFFE53935),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OverviewStatCard(
                    title: 'Thuộc lơ mơ',
                    indicatorColor: const Color(0xFFFFB300),
                    count: stats.thuocLoMo,
                    unit: 'từ',
                    onTap: () => _openWordsList(
                      context,
                      NotebookWordStatus.thuocLoMo,
                      'Thuộc lơ mơ',
                      const Color(0xFFFFB300),
                    ),
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
                    count: stats.thuocKhaKha,
                    unit: 'từ',
                    onTap: () => _openWordsList(
                      context,
                      NotebookWordStatus.thuocKhaKha,
                      'Thuộc kha khá',
                      const Color(0xFF1E88E5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OverviewStatCard(
                    title: 'Thuộc làu làu',
                    indicatorColor: const Color(0xFF43A047),
                    count: stats.thuocLauLau,
                    unit: 'từ',
                    onTap: () => _openWordsList(
                      context,
                      NotebookWordStatus.thuocLauLau,
                      'Thuộc làu làu',
                      const Color(0xFF43A047),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Hàng công tắc "Học lặp lại ngắt quãng"
            Row(
              children: [
                const Text(
                  'Học lặp lại ngắt quãng',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Học lặp lại ngắt quãng (SRS)'),
                        content: const Text(
                          'Thuật toán ngắt quãng giúp tối ưu hóa thời gian ôn tập từ vựng: từ khó sẽ được nhắc lại nhiều lần hơn, từ đã ghi nhớ sẽ giãn cách thời gian để bạn ghi nhớ dài hạn.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Đã hiểu'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Color(0xFF8C98A4),
                  ),
                ),
                const Spacer(),
                Switch.adaptive(
                  value: _isSpacedRepetition,
                  activeTrackColor: AppColors.blue,
                  onChanged: (val) => setState(() => _isSpacedRepetition = val),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Nút bấm "Ôn tập sổ tay (X từ)" thể hiện số từ của danh sách sổ tay bên dưới
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _startReviewNotebook(context),
                icon: const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  buttonLabel,
                  style: const TextStyle(
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
            const SizedBox(height: 24),

            // Phần "Danh sách sổ tay"
            NotebookListSection(
              onReviewNotebook: (nb) => _startReviewNotebook(context, targetNotebook: nb),
              onViewNotebookWords: _openNotebookWords,
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}
