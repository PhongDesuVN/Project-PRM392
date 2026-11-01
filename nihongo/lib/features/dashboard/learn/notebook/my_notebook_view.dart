import 'package:flutter/material.dart';

import '../../../../shared/ui.dart';
import '../../../auth/login/login_page.dart';
import '../../../learn/topic_words/flashcard_page.dart';
import 'models/notebook_item.dart';
import 'notebook_detail_page.dart';
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
    if (NotebookService.instance.isGuest) {
      _showGuestLoginDialog(context, 'xem chi tiết trạng thái từ');
      return;
    }
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

  void _showGuestLoginDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline_rounded, color: AppColors.blue),
            SizedBox(width: 8),
            Text(
              'Yêu cầu đăng nhập',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Bạn cần đăng nhập tài khoản để $action và lưu trữ dữ liệu cá nhân.',
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

  void _openNotebookWords(NotebookItem item) async {
    if (NotebookService.instance.isGuest) {
      _showGuestLoginDialog(context, 'mở Sổ tay cá nhân');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => NotebookDetailPage(
          notebook: item,
        ),
      ),
    );
    NotebookService.instance.refreshAll();
  }

  void _startReviewNotebook(BuildContext context, {NotebookItem? targetNotebook}) {
    if (NotebookService.instance.isGuest) {
      _showGuestLoginDialog(context, 'Ôn tập sổ tay cá nhân');
      return;
    }
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
        final isGuest = service.isGuest;
        final stats = service.stats;

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

            // 3 thẻ trạng thái học tập (Chưa thuộc, Thuộc lơ mơ, Thuộc làu làu)
            Row(
              children: [
                Expanded(
                  child: OverviewStatCard(
                    title: 'Chưa thuộc',
                    indicatorColor: const Color(0xFFE53935),
                    count: isGuest ? null : stats.chuaThuoc,
                    unit: 'từ',
                    onTap: () => _openWordsList(
                      context,
                      NotebookWordStatus.chuaThuoc,
                      'Chưa thuộc',
                      const Color(0xFFE53935),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OverviewStatCard(
                    title: 'Thuộc lơ mơ',
                    indicatorColor: const Color(0xFFFFB300),
                    count: isGuest ? null : stats.thuocLoMo,
                    unit: 'từ',
                    onTap: () => _openWordsList(
                      context,
                      NotebookWordStatus.thuocLoMo,
                      'Thuộc lơ mơ',
                      const Color(0xFFFFB300),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OverviewStatCard(
                    title: 'Thuộc làu làu',
                    indicatorColor: const Color(0xFF43A047),
                    count: isGuest ? null : stats.thuocLauLau,
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
            const SizedBox(height: 16),

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
