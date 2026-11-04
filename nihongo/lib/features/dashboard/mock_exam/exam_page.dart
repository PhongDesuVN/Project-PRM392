import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/api.dart';
import '../../../shared/ui.dart';
import 'exam_result_page.dart';
import 'models/exam_models.dart';
import 'services/mock_exam_service.dart';

/// Màn hình làm bài: tải đề, đếm ngược thời gian, chọn đáp án từng câu
/// rồi nộp để backend chấm điểm.
class ExamPage extends StatefulWidget {
  const ExamPage({super.key, required this.test, required this.service});

  final ExamSummary test;
  final MockExamService service;

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  ExamDetail? _exam;
  String? _error;
  bool _submitting = false;

  /// questionId -> optionId đã chọn.
  final Map<int, int> _answers = {};
  int _index = 0;

  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final exam = await widget.service.fetchTest(widget.test.id);
      if (!mounted) return;
      if (exam.questions.isEmpty) {
        setState(() => _error = 'Đề thi chưa có câu hỏi.');
        return;
      }
      setState(() {
        _exam = exam;
        _secondsLeft = exam.durationMinutes * 60;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  void _tick(Timer timer) {
    if (_submitting) return;
    if (_secondsLeft <= 1) {
      timer.cancel();
      setState(() => _secondsLeft = 0);
      _submit(timedOut: true);
      return;
    }
    setState(() => _secondsLeft--);
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiếp tục làm'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _onSubmitPressed() async {
    final exam = _exam!;
    final unanswered = exam.questions.length - _answers.length;
    final ok = await _confirm(
      title: 'Nộp bài?',
      message: unanswered == 0
          ? 'Bạn đã trả lời tất cả các câu.'
          : 'Bạn còn $unanswered câu chưa trả lời. Câu bỏ trống sẽ tính là sai.',
      confirmLabel: 'Nộp bài',
    );
    if (ok) _submit();
  }

  Future<void> _submit({bool timedOut = false}) async {
    final exam = _exam;
    if (exam == null || _submitting) return;
    setState(() => _submitting = true);
    _timer?.cancel();

    try {
      final result = await widget.service.submit(exam.id, _answers);
      if (!mounted) return;
      if (timedOut) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hết giờ, bài đã được nộp tự động.')),
        );
      }
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ExamResultPage(
            exam: exam,
            result: result,
            service: widget.service,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      // Cho làm tiếp để không mất bài khi lỗi mạng; hết giờ thì chỉ còn nộp lại.
      if (_secondsLeft > 0) {
        _timer = Timer.periodic(const Duration(seconds: 1), _tick);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nộp bài chưa được: ${e.message}')),
      );
    }
  }

  Future<void> _onBack() async {
    if (_exam == null || _answers.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final leave = await _confirm(
      title: 'Thoát bài thi?',
      message: 'Các câu đã chọn sẽ không được lưu.',
      confirmLabel: 'Thoát',
    );
    if (leave && mounted) Navigator.pop(context);
  }

  void _showQuestionGrid() {
    final exam = _exam!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đã trả lời ${_answers.length}/${exam.questions.length} câu',
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < exam.questions.length; i++)
                    _GridCell(
                      number: i + 1,
                      answered: _answers.containsKey(exam.questions[i].id),
                      current: i == _index,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _index = i);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _timeText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final exam = _exam;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Thoát',
            onPressed: _onBack,
          ),
          title: Text(
            widget.test.title,
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            if (exam != null) ...[
              IconButton(
                icon: const Icon(Icons.grid_view_rounded),
                tooltip: 'Danh sách câu hỏi',
                onPressed: _showQuestionGrid,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Center(
                  child: Text(
                    _timeText,
                    style: TextStyle(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w800,
                      color: _secondsLeft <= 60
                          ? AppColors.error
                          : AppColors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        body: _buildBody(exam),
      ),
    );
  }

  Widget _buildBody(ExamDetail? exam) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.darkText),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    if (exam == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final question = exam.questions[_index];
    final isLast = _index == exam.questions.length - 1;

    return Column(
      children: [
        LinearProgressIndicator(
          value: (_index + 1) / exam.questions.length,
          minHeight: 4,
          color: AppColors.blue,
          backgroundColor: AppColors.border,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            children: [
              Row(
                children: [
                  Text(
                    'Câu ${_index + 1}/${exam.questions.length}',
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        examSectionLabel(question.section),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (question.passage != null && question.passage!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8FB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    question.passage!,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Text(
                question.text,
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < question.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OptionTile(
                    label: String.fromCharCode(65 + i),
                    text: question.options[i].text,
                    selected: _answers[question.id] == question.options[i].id,
                    onTap: () => setState(
                      () => _answers[question.id] = question.options[i].id,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _index == 0 ? null : () => setState(() => _index--),
                    child: const Text('Câu trước'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.blue,
                    ),
                    onPressed: _submitting
                        ? null
                        : isLast
                            ? _onSubmitPressed
                            : () => setState(() => _index++),
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isLast ? 'Nộp bài' : 'Câu sau'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.blue.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.blue : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.blue : Colors.white,
                  border: Border.all(
                    color: selected ? AppColors.blue : AppColors.border,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppColors.darkText,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontSize: 17,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.number,
    required this.answered,
    required this.current,
    required this.onTap,
  });

  final int number;
  final bool answered;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: answered ? AppColors.blue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: current ? AppColors.darkText : AppColors.border,
            width: current ? 2 : 1,
          ),
        ),
        child: Text(
          '$number',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: answered ? Colors.white : AppColors.darkText,
          ),
        ),
      ),
    );
  }
}
