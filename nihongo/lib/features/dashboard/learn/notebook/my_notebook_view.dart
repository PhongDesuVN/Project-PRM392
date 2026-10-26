import 'package:flutter/material.dart';

import '../../../../shared/ui.dart';
import '../../../learn/topic_words/flashcard_page.dart';
import 'notebook_words_list_page.dart';
import 'services/notebook_service.dart';
import 'widgets/overview_stat_card.dart';

/// Màn hình "Sổ tay của tôi":
/// - Phần "Tổng quan" với 4 trạng thái học tập (Chưa thuộc, Thuộc lơ mơ, Thuộc kha khá, Thuộc làu làu).
/// - Hiển thị số lượng từ vựng động theo kết quả luyện tập Flashcard.
/// - Nhấn vào từng thẻ để xem danh sách từ thuộc nhóm đó.
/// - Nút "Ôn tập sổ tay" khởi chạy Flashcard trực tiếp từ các từ đã lưu.
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

  void _startReviewNotebook(BuildContext context) {
    if (widget.onReviewNotebook != null) {
      widget.onReviewNotebook!();
      return;
    }

    final reviewWords = NotebookService.instance.getAllReviewWords();
    if (reviewWords.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Sổ tay chưa có từ nào! Hãy học bài ở phần Thư viện trước nhé.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FlashcardPage(
          topicTitle: 'Ôn tập sổ tay',
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
        final stats = NotebookService.instance.stats;

        final chuaThuocText =
            stats.chuaThuoc > 0 ? '${stats.chuaThuoc} từ' : '0 từ';
        final thuocLoMoText =
            stats.thuocLoMo > 0 ? '${stats.thuocLoMo} từ' : '0 từ';
        final thuocKhaKhaText =
            stats.thuocKhaKha > 0 ? '${stats.thuocKhaKha} từ' : '0 từ';
        final thuocLauLauText =
            stats.thuocLauLau > 0 ? '${stats.thuocLauLau} từ' : '0 từ';

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
                    value: chuaThuocText,
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
                    value: thuocLoMoText,
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
                    value: thuocKhaKhaText,
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
                    value: thuocLauLauText,
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
            const SizedBox(height: 20),

            // Nút bấm "Ôn tập sổ tay"
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _startReviewNotebook(context),
                icon: const Icon(
                  Icons.assignment_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  stats.total > 0
                      ? 'Ôn tập sổ tay (${stats.total} từ)'
                      : 'Ôn tập sổ tay',
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
          ],
        );
      },
    );
  }
}
