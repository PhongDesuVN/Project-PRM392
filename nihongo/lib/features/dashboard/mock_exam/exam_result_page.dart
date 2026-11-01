import 'package:flutter/material.dart';

import '../../../shared/ui.dart';
import 'models/exam_models.dart';

/// Kết quả sau khi nộp bài: điểm tổng, điểm theo phần thi và xem lại
/// từng câu kèm giải thích.
class ExamResultPage extends StatefulWidget {
  const ExamResultPage({
    super.key,
    required this.exam,
    required this.result,
  });

  final ExamDetail exam;
  final ExamResult result;

  @override
  State<ExamResultPage> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage> {
  static const _green = Color(0xFF2E9E5B);

  bool _onlyWrong = false;

  String get _message {
    final p = widget.result.percent;
    if (p >= 80) return 'Xuất sắc! Bạn nắm rất chắc phần này.';
    if (p >= 60) return 'Khá tốt! Xem lại các câu sai để chắc hơn.';
    return 'Cần ôn thêm. Hãy xem phần giải thích bên dưới.';
  }

  Color get _scoreColor {
    final p = widget.result.percent;
    if (p >= 80) return _green;
    if (p >= 60) return AppColors.blue;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final reviewById = {for (final r in result.review) r.questionId: r};
    final entries = <({int number, ExamQuestion question, ReviewItem review})>[
      for (var i = 0; i < widget.exam.questions.length; i++)
        if (reviewById[widget.exam.questions[i].id] != null)
          (
            number: i + 1,
            question: widget.exam.questions[i],
            review: reviewById[widget.exam.questions[i].id]!,
          ),
    ];
    final shown =
        _onlyWrong ? entries.where((e) => !e.review.correct).toList() : entries;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text(
          'Kết quả',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _ScoreCard(
            title: widget.exam.title,
            result: result,
            color: _scoreColor,
            message: _message,
          ),
          if (result.sections.length > 1) ...[
            const SizedBox(height: 16),
            _SectionBreakdown(sections: result.sections),
          ],
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Xem lại bài làm',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilterChip(
                label: const Text('Chỉ câu sai'),
                selected: _onlyWrong,
                onSelected: (v) => setState(() => _onlyWrong = v),
                selectedColor: AppColors.blue.withValues(alpha: 0.15),
                checkmarkColor: AppColors.blue,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (shown.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Bạn không sai câu nào. Tuyệt vời!',
                  style: TextStyle(color: AppColors.placeholder),
                ),
              ),
            ),
          for (final e in shown)
            _ReviewCard(
              number: e.number,
              question: e.question,
              review: e.review,
            ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
            onPressed: () => Navigator.pop(context),
            child: const Text('Hoàn tất'),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.title,
    required this.result,
    required this.color,
    required this.message,
  });

  final String title;
  final ExamResult result;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.placeholder,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: result.percent / 100,
                    strokeWidth: 9,
                    color: color,
                    backgroundColor: AppColors.border,
                  ),
                ),
                Text(
                  '${result.percent}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Đúng ${result.correct}/${result.total} câu',
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.placeholder, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SectionBreakdown extends StatelessWidget {
  const _SectionBreakdown({required this.sections});

  final List<SectionResult> sections;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Điểm theo phần thi',
            style: TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final s in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          examSectionLabel(s.section),
                          style: const TextStyle(color: AppColors.darkText),
                        ),
                      ),
                      Text(
                        '${s.correct}/${s.total}',
                        style: const TextStyle(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: s.total == 0 ? 0 : s.correct / s.total,
                      minHeight: 8,
                      color: AppColors.blue,
                      backgroundColor: AppColors.border,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.number,
    required this.question,
    required this.review,
  });

  final int number;
  final ExamQuestion question;
  final ReviewItem review;

  static const _green = Color(0xFF2E9E5B);

  String? _optionText(int? id) {
    if (id == null) return null;
    for (final o in question.options) {
      if (o.id == id) return o.text;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final yourAnswer = _optionText(review.selectedOptionId);
    final correctAnswer = _optionText(review.correctOptionId);
    final color = review.correct ? _green : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                review.correct ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Câu $number',
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.text,
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          _AnswerLine(
            label: 'Bạn chọn',
            value: yourAnswer ?? 'Chưa trả lời',
            color: review.correct ? _green : AppColors.error,
          ),
          if (!review.correct && correctAnswer != null)
            _AnswerLine(label: 'Đáp án', value: correctAnswer, color: _green),
          if (review.explanation != null && review.explanation!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                review.explanation!,
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: AppColors.placeholder),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 14.5),
      ),
    );
  }
}
