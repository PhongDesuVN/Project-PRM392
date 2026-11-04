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
                    color: AppColors.blue,
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
                      const SizedBox(height: 2),
                      Text(
                        'Đã làm: $answeredCount/${widget.quizzes.length} câu • Đúng: $correctCount câu',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
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
              ? (isCorrect ? const Color(0xFF00B894) : const Color(0xFFE74C3C))
              : AppColors.border,
          width: hasAnswered ? 1.4 : 1.0,
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
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Câu ${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blue,
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
                Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 18,
                      color: isCorrect
                          ? const Color(0xFF00B894)
                          : const Color(0xFFE74C3C),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCorrect ? 'Đúng' : 'Sai',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isCorrect
                            ? const Color(0xFF00B894)
                            : const Color(0xFFE74C3C),
                      ),
                    ),
                  ],
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
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: Color(0xFF475569),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Đáp án đúng: ${quiz.options[quiz.correctIndex]}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  if (quiz.explanation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      quiz.explanation,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
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
    Color textColor = const Color(0xFF1E242B);
    Widget? trailingIcon;

    if (hasAnswered) {
      if (optionIndex == quiz.correctIndex) {
        bgColor = const Color(0xFFE8F8F5);
        borderColor = const Color(0xFF00B894);
        textColor = const Color(0xFF00B894);
        trailingIcon = const Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: Color(0xFF00B894),
        );
      } else if (optionIndex == selectedOption) {
        bgColor = const Color(0xFFFDEDEC);
        borderColor = const Color(0xFFE74C3C);
        textColor = const Color(0xFFE74C3C);
        trailingIcon = const Icon(
          Icons.cancel_rounded,
          size: 18,
          color: Color(0xFFE74C3C),
        );
      }
    }

    return InkWell(
      onTap: hasAnswered ? null : () => _chooseAnswer(quizIndex, optionIndex),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            ?trailingIcon,
          ],
        ),
      ),
    );
  }
}
