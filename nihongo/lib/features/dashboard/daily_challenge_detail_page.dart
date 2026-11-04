import 'package:flutter/material.dart';

import '../../shared/ui.dart';
import 'daily_challenge_service.dart';

/// Màn hình chi tiết xem tất cả 5 câu hỏi của "Thử thách mỗi ngày"
/// - Hiển thị đáp án đúng/sai cho các câu đã làm
/// - Câu nào chưa chọn thì ẩn đáp án và giải thích
class DailyChallengeDetailPage extends StatefulWidget {
  const DailyChallengeDetailPage({
    super.key,
    required this.quizzes,
    required this.userAnswers,
    this.onSelectAnswer,
  });

  final List<DailyChallengeQuiz> quizzes;
  final Map<int, int> userAnswers;
  final void Function(int quizIndex, int optionIndex)? onSelectAnswer;

  @override
  State<DailyChallengeDetailPage> createState() =>
      _DailyChallengeDetailPageState();
}

class _DailyChallengeDetailPageState extends State<DailyChallengeDetailPage> {
  late Map<int, int> _answers;

  @override
  void initState() {
    super.initState();
    _answers = Map<int, int>.from(widget.userAnswers);
  }

  void _chooseAnswer(int quizIndex, int optionIndex) {
    if (_answers.containsKey(quizIndex)) return; // Đã trả lời rồi thì không đổi
    setState(() {
      _answers[quizIndex] = optionIndex;
    });
    widget.onSelectAnswer?.call(quizIndex, optionIndex);
  }

  @override
  Widget build(BuildContext context) {
    int answeredCount = _answers.length;
    int correctCount = 0;
    for (int i = 0; i < widget.quizzes.length; i++) {
      if (_answers[i] == widget.quizzes[i].correctIndex) {
        correctCount++;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Thử thách mỗi ngày (5 câu)',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF1E242B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E242B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // Thẻ tóm tắt kết quả
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    color: Color(0xFF0284C7),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tiến độ thử thách',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E242B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            'Đã làm: $answeredCount/${widget.quizzes.length} câu',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '•',
                            style: TextStyle(color: Color(0xFFCBD5E1)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Đúng: $correctCount câu',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Danh sách 5 câu hỏi
          for (int i = 0; i < widget.quizzes.length; i++) ...[
            _buildQuizCard(i, widget.quizzes[i]),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizCard(int index, DailyChallengeQuiz quiz) {
    final hasAnswered = _answers.containsKey(index);
    final selectedOption = _answers[index];
    final isCorrect = hasAnswered && selectedOption == quiz.correctIndex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasAnswered
              ? (isCorrect
                    ? const Color(0xFF16A34A).withValues(alpha: 0.6)
                    : const Color(0xFFDC2626).withValues(alpha: 0.6))
              : AppColors.border,
          width: hasAnswered ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header câu hỏi
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Câu ${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: quiz.type == DailyQuizType.grammar
                      ? const Color(0xFFEDE7F6)
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  quiz.categoryLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: quiz.type == DailyQuizType.grammar
                        ? const Color(0xFF5E35B1)
                        : AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              if (hasAnswered)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCorrect
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 16,
                        color: isCorrect
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isCorrect ? 'Đúng' : 'Chưa đúng',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isCorrect
                              ? const Color(0xFF15803D)
                              : const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Text(
                  'Chưa trả lời',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Nội dung từ/câu hỏi
          Row(
            children: [
              Text(
                quiz.prompt,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E242B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  quiz.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 đáp án lựa chọn
          Column(
            children: [
              for (int optIdx = 0; optIdx < quiz.options.length; optIdx++) ...[
                _buildOptionItem(
                  quizIndex: index,
                  optionIndex: optIdx,
                  optionText: quiz.options[optIdx],
                  quiz: quiz,
                  hasAnswered: hasAnswered,
                  selectedOption: selectedOption,
                ),
                if (optIdx < quiz.options.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),

          // Phần giải thích: CHỈ HIỆN KHI ĐÃ TRẢ LỜI
          if (hasAnswered) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCorrect
                      ? const Color(0xFFBBF7D0)
                      : const Color(0xFFFDE68A),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.check_circle_outline_rounded
                            : Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: isCorrect
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Đáp án đúng: ${quiz.options[quiz.correctIndex]}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isCorrect
                                ? const Color(0xFF15803D)
                                : const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (quiz.explanation.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      quiz.explanation,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isCorrect
                            ? const Color(0xFF166534)
                            : const Color(0xFF78350F),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required int quizIndex,
    required int optionIndex,
    required String optionText,
    required DailyChallengeQuiz quiz,
    required bool hasAnswered,
    required int? selectedOption,
  }) {
    Color bgColor = const Color(0xFFF8FAFC);
    Color borderColor = const Color(0xFFE2E8F0);
    double borderWidth = 1.0;
    Color textColor = const Color(0xFF1E242B);
    FontWeight fontWeight = FontWeight.w600;
    Color badgeBg = const Color(0xFFF1F5F9);
    Color badgeTextColor = const Color(0xFF64748B);
    Widget? trailingWidget;

    const optionLetters = ['A', 'B', 'C', 'D'];
    final letter = optionIndex < optionLetters.length
        ? optionLetters[optionIndex]
        : '${optionIndex + 1}';

    if (hasAnswered) {
      if (optionIndex == quiz.correctIndex) {
        // ĐÁP ÁN ĐÚNG: Nổi bật với màu xanh lá cây
        bgColor = const Color(0xFFECFDF5);
        borderColor = const Color(0xFF16A34A);
        borderWidth = 1.8;
        textColor = const Color(0xFF15803D);
        fontWeight = FontWeight.w700;
        badgeBg = const Color(0xFF16A34A);
        badgeTextColor = Colors.white;
        trailingWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'Đáp án đúng',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      } else if (optionIndex == selectedOption) {
        // ĐÁP ÁN SAI MÀ NGƯỜI DÙNG CHỌN: Nổi bật với màu đỏ
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFDC2626);
        borderWidth = 1.8;
        textColor = const Color(0xFFB91C1C);
        fontWeight = FontWeight.w700;
        badgeBg = const Color(0xFFDC2626);
        badgeTextColor = Colors.white;
        trailingWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close_rounded, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'Bạn đã chọn',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      } else {
        // Các đáp án khác không chọn: làm mờ nhẹ
        textColor = const Color(0xFF94A3B8);
        badgeTextColor = const Color(0xFF94A3B8);
      }
    }

    return InkWell(
      onTap: hasAnswered ? null : () => _chooseAnswer(quizIndex, optionIndex),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: badgeTextColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
              ),
            ),
            if (trailingWidget != null) ...[
              const SizedBox(width: 8),
              trailingWidget,
            ],
          ],
        ),
      ),
    );
  }
}
