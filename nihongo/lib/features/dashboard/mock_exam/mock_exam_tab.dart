import 'package:flutter/material.dart';

import '../../../core/api.dart';
import '../../../shared/ui.dart';
import '../shared/dashboard_tool_widgets.dart';
import 'exam_page.dart';
import 'models/exam_models.dart';
import 'services/mock_exam_service.dart';

/// Tab "Thi thử": chọn cấp độ, làm test từ vựng / ngữ pháp
/// hoặc đề thi thử theo cấu trúc JLPT.
class MockExamTab extends StatefulWidget {
  const MockExamTab({super.key, this.service});

  /// Cho phép test truyền service giả; mặc định gọi backend thật.
  final MockExamService? service;

  @override
  State<MockExamTab> createState() => _MockExamTabState();
}

class _MockExamTabState extends State<MockExamTab> {
  static const _levels = ['N5', 'N4', 'N3'];

  late final MockExamService _service = widget.service ?? MockExamService();
  String _level = _levels.first;
  List<ExamSummary> _tests = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final level = _level;
    try {
      final tests = await _service.fetchTests(level: level);
      if (!mounted || level != _level) return;
      setState(() {
        _tests = tests;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted || level != _level) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  void _selectLevel(String level) {
    if (level == _level) return;
    setState(() => _level = level);
    _load();
  }

  Future<void> _openExam(ExamSummary test) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExamPage(test: test, service: _service),
      ),
    );
    // Quay lại thì tải lại để cập nhật điểm cao nhất / số lần làm.
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final quick = _tests.where((t) => t.type != ExamType.jlpt).toList();
    final jlpt = _tests.where((t) => t.type == ExamType.jlpt).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
        children: [
          const DashboardToolHeading(
            eyebrow: 'ÔN LUYỆN',
            title: 'Thi thử',
            subtitle: 'Test từ vựng, ngữ pháp và đề thi theo cấu trúc JLPT.',
          ),
          const SizedBox(height: 18),
          _LevelSelector(
            levels: _levels,
            selected: _level,
            onSelected: _selectLevel,
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _ErrorState(message: _error!, onRetry: _load)
          else if (_tests.isEmpty)
            const DashboardEmptyState(
              icon: Icons.fact_check_outlined,
              title: 'Chưa có đề cho cấp độ này',
              message: 'Hãy chọn cấp độ khác hoặc quay lại sau.',
            )
          else ...[
            if (quick.isNotEmpty) ...[
              const _SectionTitle('Luyện tập nhanh'),
              for (final test in quick)
                _ExamCard(test: test, onTap: () => _openExam(test)),
              const SizedBox(height: 14),
            ],
            if (jlpt.isNotEmpty) ...[
              const _SectionTitle('Thi thử JLPT theo cấu trúc đề'),
              for (final test in jlpt)
                _ExamCard(test: test, onTap: () => _openExam(test)),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Đề gồm 文字・語彙, 文法 và 読解. Phần nghe hiểu (聴解) '
                  'chưa có trong bản này.',
                  style: TextStyle(
                    color: AppColors.placeholder,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.darkText,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LevelSelector extends StatelessWidget {
  const _LevelSelector({
    required this.levels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> levels;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final level in levels)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(level),
              selected: level == selected,
              onSelected: (_) => onSelected(level),
              showCheckmark: false,
              selectedColor: AppColors.blue,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: level == selected ? AppColors.blue : AppColors.border,
              ),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w800,
                color: level == selected ? Colors.white : AppColors.darkText,
              ),
            ),
          ),
      ],
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.test, required this.onTap});

  final ExamSummary test;
  final VoidCallback onTap;

  IconData get _icon {
    switch (test.type) {
      case ExamType.vocabulary:
        return Icons.translate;
      case ExamType.grammar:
        return Icons.rule;
      case ExamType.jlpt:
        return Icons.assignment_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = test.attempts > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon, color: AppColors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.title,
                        style: const TextStyle(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${test.totalQuestions} câu · ${test.durationMinutes} phút'
                        '${done ? ' · đã làm ${test.attempts} lần' : ''}',
                        style: const TextStyle(
                          color: AppColors.placeholder,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (done)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Cao nhất ${test.bestPercent}%',
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.chevron_right, color: AppColors.placeholder),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Không tải được đề thi',
          message: message,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại'),
        ),
      ],
    );
  }
}
