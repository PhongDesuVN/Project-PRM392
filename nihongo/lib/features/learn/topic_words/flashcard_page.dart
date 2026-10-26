import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models/topic_word_model.dart';
import '../../dashboard/learn/notebook/services/notebook_service.dart';

/// Màn hình học Flashcard theo chuẩn thiết kế Ảnh 2.
/// - Viền hoa văn xanh Nhật Bản
/// - Hiệu ứng lật thẻ 3D
/// - 4 nút điều khiển: Quay lại (Undo), Chưa thuộc (X), Chưa chắc chắn (?), Đã thuộc (V)
/// - Thanh tiến độ, nút Xáo trộn, Tự động phát
class FlashcardPage extends StatefulWidget {
  const FlashcardPage({
    super.key,
    required this.topicTitle,
    required this.words,
  });

  final String topicTitle;
  final List<TopicWord> words;

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  late List<TopicWord> _studyWords;
  int _currentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Thống kê kết quả học
  final Set<int> _masteredWordIds = {};
  final Set<int> _needReviewWordIds = {};
  final Set<int> _hardWordIds = {};

  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    _studyWords = List<TopicWord>.from(widget.words);

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _nextCard() {
    if (_currentIndex < _studyWords.length - 1) {
      if (_isFlipped) {
        _flipController.reverse();
        _isFlipped = false;
      }
      setState(() => _currentIndex++);
    } else {
      _showCompletionDialog();
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      if (_isFlipped) {
        _flipController.reverse();
        _isFlipped = false;
      }
      setState(() => _currentIndex--);
    }
  }

  void _markWord(String status) {
    final currentWord = _studyWords[_currentIndex];
    if (status == 'known') {
      _masteredWordIds.add(currentWord.id);
      _needReviewWordIds.remove(currentWord.id);
      _hardWordIds.remove(currentWord.id);
    } else if (status == 'unknown') {
      _needReviewWordIds.add(currentWord.id);
      _masteredWordIds.remove(currentWord.id);
    } else if (status == 'hard') {
      _hardWordIds.add(currentWord.id);
      _masteredWordIds.remove(currentWord.id);
    }
    _nextCard();
  }

  void _shuffleWords() {
    setState(() {
      _studyWords.shuffle();
      _currentIndex = 0;
      if (_isFlipped) {
        _flipController.reverse();
        _isFlipped = false;
      }
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Đã xáo trộn danh sách thẻ!'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _toggleAutoPlay() {
    setState(() => _isAutoPlaying = !_isAutoPlaying);
    if (_isAutoPlaying) {
      _startAutoPlayLoop();
    }
  }

  Future<void> _startAutoPlayLoop() async {
    while (_isAutoPlaying && mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!_isAutoPlaying || !mounted) break;
      _flipCard();
      await Future.delayed(const Duration(seconds: 2));
      if (!_isAutoPlaying || !mounted) break;
      if (_currentIndex < _studyWords.length - 1) {
        _nextCard();
      } else {
        _isAutoPlaying = false;
        if (mounted) setState(() {});
        break;
      }
    }
  }

  void _playAudioFeedback(String text) {
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
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showCompletionDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 32),
            SizedBox(width: 10),
            Text('Chúc mừng!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn đã hoàn thành xong ${_studyWords.length} thẻ flashcard!',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _resultRow(
              'Đã thuộc:',
              '${_masteredWordIds.length} từ',
              Colors.green.shade700,
            ),
            const SizedBox(height: 8),
            _resultRow(
              'Chưa chắc chắn:',
              '${_hardWordIds.length} từ',
              Colors.orange.shade700,
            ),
            const SizedBox(height: 8),
            _resultRow(
              'Cần ôn lại:',
              '${_needReviewWordIds.length} từ',
              Colors.red.shade700,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _currentIndex = 0;
                _masteredWordIds.clear();
                _needReviewWordIds.clear();
                _hardWordIds.clear();
                if (_isFlipped) {
                  _flipController.reverse();
                  _isFlipped = false;
                }
              });
            },
            child: const Text('Học lại'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final masteredList = _studyWords
                  .where((w) => _masteredWordIds.contains(w.id))
                  .toList();
              final hardList = _studyWords
                  .where((w) => _hardWordIds.contains(w.id))
                  .toList();
              final unknownList = _studyWords
                  .where((w) => _needReviewWordIds.contains(w.id))
                  .toList();

              // Nếu có từ nào trong bài chưa được đánh dấu riêng lẻ, xếp vào nhóm đã thuộc
              for (final w in _studyWords) {
                if (!_masteredWordIds.contains(w.id) &&
                    !_hardWordIds.contains(w.id) &&
                    !_needReviewWordIds.contains(w.id)) {
                  masteredList.add(w);
                }
              }

              await NotebookService.instance.saveStudyResult(
                masteredWords: masteredList,
                hardWords: hardList,
                unknownWords: unknownList,
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật tiến độ học vào "Sổ tay của tôi"!'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Hoàn tất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_studyWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcard')),
        body: const Center(
          child: Text('Không có từ vựng nào trong chủ đề này'),
        ),
      );
    }

    final currentWord = _studyWords[_currentIndex];
    final progress = (_currentIndex + 1) / _studyWords.length;
    final indexFormatted = (_currentIndex + 1).toString().padLeft(2, '0');
    final totalFormatted = _studyWords.length.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EEF4),
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
          'Flashcard - $indexFormatted/$totalFormatted',
          style: const TextStyle(
            color: Color(0xFF1E242B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E242B)),
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Tùy chọn flashcard'),
                    duration: Duration(seconds: 1),
                  ),
                );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFF1E242B),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Đã báo cáo đóng góp nội dung từ vựng!'),
                    duration: Duration(seconds: 1),
                  ),
                );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
            minHeight: 3.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Top action buttons (Shuffle & Auto Play)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _RoundActionButton(
                    icon: Icons.shuffle_rounded,
                    onTap: _shuffleWords,
                  ),
                  const SizedBox(width: 12),
                  _RoundActionButton(
                    icon: _isAutoPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: _isAutoPlaying ? const Color(0xFF1976D2) : null,
                    onTap: _toggleAutoPlay,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Main Flashcard with Japanese pattern border & 3D Flip
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final angle = _flipAnimation.value * math.pi;
                      final isFront = angle < math.pi / 2;

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        alignment: Alignment.center,
                        child: isFront
                            ? _buildFrontCard(currentWord)
                            : Transform(
                                transform: Matrix4.identity()..rotateY(math.pi),
                                alignment: Alignment.center,
                                child: _buildBackCard(currentWord),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 4 Action Buttons: Undo, Wrong (X), Unsure (?), Correct (V)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 1. Undo button
                  _CircleButton(
                    onTap: _prevCard,
                    icon: const Icon(
                      Icons.replay_rounded,
                      color: Color(0xFF5A6678),
                      size: 26,
                    ),
                  ),

                  // 2. Wrong (X) button
                  _CircleButton(
                    onTap: () => _markWord('unknown'),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFE53935),
                      size: 28,
                    ),
                  ),

                  // 3. Unsure (?) button
                  _CircleButton(
                    onTap: () => _markWord('hard'),
                    icon: const Text(
                      '?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFA000),
                      ),
                    ),
                  ),

                  // 4. Correct (Check) button
                  _CircleButton(
                    onTap: () => _markWord('known'),
                    icon: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF43A047),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Viền hoa văn chữ Nhật mờ quanh thẻ như Ảnh 2
  Widget _cardContainer({required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Stack(
        children: [
          // Pattern chữ Nhật chìm trang trí viền ngoài
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.12,
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(
                    40,
                    (i) => const Text(
                      'あ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Lõi thẻ màu trắng
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: content,
          ),
        ],
      ),
    );
  }

  // Mặt trước Flashcard (Ảnh 2)
  Widget _buildFrontCard(TopicWord word) {
    return _cardContainer(
      content: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Từ chính (Kanji hoặc Kana to màu xanh)
                Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1565C0),
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Cách đọc Furigana trong ngoặc 「...」
                Text(
                  word.reading,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF424242),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),

                // Icon loa phát âm
                InkWell(
                  onTap: () => _playAudioFeedback(word.word),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_outlined,
                      size: 26,
                      color: Color(0xFF424242),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Gợi ý chạm
                Text(
                  'Chạm để lật xem nghĩa',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Logo badge góc phải dưới (nihon)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD6E4F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'nihon',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF90A4AE),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mặt sau Flashcard (Hiện nghĩa tiếng Việt & Ví dụ)
  Widget _buildBackCard(TopicWord word) {
    return _cardContainer(
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Từ vựng thu nhỏ
            Text(
              word.word,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              word.reading,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            if (word.romaji != null && word.romaji!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                word.romaji!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 14),

            // Nghĩa tiếng Việt
            const Text(
              'Ý nghĩa:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              word.meaning,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E242B),
              ),
            ),
            const SizedBox(height: 18),

            // Ví dụ câu tiếng Nhật và dịch nghĩa
            if (word.exampleJp != null && word.exampleJp!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      word.exampleJp!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF263238),
                      ),
                    ),
                    if (word.exampleVi != null &&
                        word.exampleVi!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        word.exampleVi!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const Spacer(),
            Text(
              'Chạm để quay lại mặt trước',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nút bo tròn nhỏ ở trên cùng (Shuffle & Play)
class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          child: Icon(icon, color: color ?? const Color(0xFF1E242B), size: 22),
        ),
      ),
    );
  }
}

/// 4 Nút tròn điều khiển phía dưới Flashcard
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          child: icon,
        ),
      ),
    );
  }
}
