import 'package:flutter/material.dart';

import '../../../learn/topic_words/flashcard_page.dart';
import 'services/notebook_service.dart';

/// Màn hình danh sách từ vựng trong Sổ tay theo từng nhóm trạng thái
/// (Chưa thuộc, Thuộc lơ mơ, Thuộc kha khá, Thuộc làu làu).
class NotebookWordsListPage extends StatelessWidget {
  const NotebookWordsListPage({
    super.key,
    required this.status,
    required this.statusTitle,
    required this.themeColor,
  });

  final NotebookWordStatus status;
  final String statusTitle;
  final Color themeColor;

  void _playAudio(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Phát âm: $text'),
            ],
          ),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final words = NotebookService.instance.getWordsByStatus(status);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F3F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E242B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$statusTitle (${words.length} từ)',
          style: const TextStyle(
            color: Color(0xFF1E242B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: words.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có từ nào ở trạng thái "$statusTitle"',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy học bài và luyện tập Flashcard để lưu từ vào đây nhé!',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: words.length,
              itemBuilder: (context, index) {
                final word = words[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Vạch màu trạng thái
                      Container(
                        width: 4,
                        height: 38,
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Thông tin từ vựng
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  word.word,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  word.reading,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              word.meaning,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Nút loa phát âm
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up_outlined,
                          color: Color(0xFF546E7A),
                          size: 22,
                        ),
                        onPressed: () => _playAudio(context, word.word),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: words.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              color: Colors.white,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => FlashcardPage(
                          topicTitle: statusTitle,
                          words: words,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.style_rounded, color: Colors.white),
                  label: Text(
                    'Luyện tập ${words.length} thẻ này',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
