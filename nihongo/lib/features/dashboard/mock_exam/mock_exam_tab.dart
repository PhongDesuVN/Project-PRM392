import 'package:flutter/material.dart';

import '../../../core/api.dart';
import '../../../shared/ui.dart';
import '../shared/dashboard_tool_widgets.dart';
import 'exam_page.dart';
import 'models/exam_models.dart';
import 'services/mock_exam_service.dart';

/// Tab "Thi thử": Giao diện chính thi thử tiếng Nhật
/// - Header: "Thi thử" & nút "Bảng xếp hạng"
/// - Thanh ngang danh mục: "Ngữ pháp", "Từ vựng", "JLPT"
/// - Cấp độ: N5, N4, N3, N2, N1
/// - Danh sách đề thi & Bộ lọc trạng thái (Tất cả, Chưa làm, Đang làm, Đã làm)
class MockExamTab extends StatefulWidget {
  const MockExamTab({super.key, this.service});

  final MockExamService? service;

  @override
  State<MockExamTab> createState() => _MockExamTabState();
}

class _MockExamTabState extends State<MockExamTab> {
  static const _categories = ['Ngữ pháp', 'Từ vựng', 'JLPT'];
  static const _levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
  static const _statuses = ['Tất cả', 'Chưa làm', 'Đang làm', 'Đã làm'];

  late final MockExamService _service = widget.service ?? MockExamService();

  int _selectedCategoryIndex = 0; // 0: Ngữ pháp, 1: Từ vựng, 2: JLPT
  String _level = _levels.first;
  int _selectedStatusIndex = 0; // 0: Tất cả, 1: Chưa làm, 2: Đang làm, 3: Đã làm

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

  void _selectCategory(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
  }

  void _selectLevel(String level) {
    if (level == _level) return;
    setState(() => _level = level);
    _load();
  }

  void _selectStatus(int index) {
    if (_selectedStatusIndex == index) return;
    setState(() => _selectedStatusIndex = index);
  }

  Future<void> _openExam(ExamSummary test) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExamPage(test: test, service: _service),
      ),
    );
    if (mounted) _load();
  }

  void _showLeaderboard() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Tính năng Bảng xếp hạng đang được hoàn thiện!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _requestMoreTests() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Cảm ơn bạn! Yêu cầu thêm đề thi đã được ghi nhận.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  List<ExamSummary> _getDisplayedTests() {
    // 1. Lọc theo danh mục trên thanh ngang
    final categoryTests = _tests.where((t) {
      switch (_selectedCategoryIndex) {
        case 0:
          return t.type == ExamType.grammar;
        case 1:
          return t.type == ExamType.vocabulary;
        case 2:
          return t.type == ExamType.jlpt;
        default:
          return true;
      }
    }).toList();

    // 2. Lọc theo trạng thái làm bài
    return categoryTests.where((t) {
      switch (_selectedStatusIndex) {
        case 1: // Chưa làm
          return t.attempts == 0;
        case 2: // Đang làm
          return t.attempts > 0 && t.bestPercent < 100;
        case 3: // Đã làm
          return t.attempts > 0;
        default: // Tất cả
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedTests = _getDisplayedTests();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // 1. Header: Tiêu đề "Thi thử" & Nút "Bảng xếp hạng"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thi thử',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E242B),
                ),
              ),
              InkWell(
                onTap: _showLeaderboard,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Bảng xếp hạng',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Thanh ngang danh mục: "Ngữ pháp", "Từ vựng", "JLPT"
          _CategorySegmentedBar(
            categories: _categories,
            selectedIndex: _selectedCategoryIndex,
            onSelected: _selectCategory,
          ),
          const SizedBox(height: 14),

          // 3. Cấp độ JLPT: N5, N4, N3, N2, N1
          _LevelSelector(
            levels: _levels,
            selected: _level,
            onSelected: _selectLevel,
          ),
          const SizedBox(height: 20),

          // 4. Tiêu đề phần danh sách đề thi & "Yêu cầu thêm"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh sách đề thi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E242B),
                ),
              ),
              InkWell(
                onTap: _requestMoreTests,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Text(
                    'Yêu cầu thêm',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 5. Card chứa bộ lọc trạng thái và danh sách các đề thi
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bộ lọc trạng thái: Tất cả, Chưa làm, Đang làm, Đã làm
                _StatusFilterBar(
                  statuses: _statuses,
                  selectedIndex: _selectedStatusIndex,
                  onSelected: _selectStatus,
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F3F6)),

                // Trạng thái đang tải / lỗi / rỗng / danh sách
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  _ErrorState(message: _error!, onRetry: _load)
                else if (displayedTests.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_late_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Chưa có đề cho mục "${_categories[_selectedCategoryIndex]}" cấp độ $_level',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vui lòng chọn cấp độ khác hoặc danh mục khác nhé.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedTests.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    itemBuilder: (context, index) {
                      final test = displayedTests[index];
                      // Đánh dấu VIP/Vương miện cho các đề sau để giống hình mẫu
                      final hasCrown = index >= 3 || test.id % 2 == 0;
                      return _ExamListItem(
                        test: test,
                        hasCrown: hasCrown,
                        onTap: () => _openExam(test),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thanh ngang danh mục: "Ngữ pháp", "Từ vựng", "JLPT"
class _CategorySegmentedBar extends StatelessWidget {
  const _CategorySegmentedBar({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (int i = 0; i < categories.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedIndex == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: selectedIndex == i
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    categories[i],
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: selectedIndex == i
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selectedIndex == i
                          ? const Color(0xFF1E242B)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Thanh chọn cấp độ: N5, N4, N3, N2, N1
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
        for (final lvl in levels)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => onSelected(lvl),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: lvl == selected
                        ? Colors.white
                        : const Color(0xFFEDF0F4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: lvl == selected
                          ? AppColors.blue
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: lvl == selected
                        ? [
                            BoxShadow(
                              color: AppColors.blue.withValues(alpha: 0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    lvl,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: lvl == selected
                          ? AppColors.blue
                          : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bộ lọc trạng thái đề thi: Tất cả, Chưa làm, Đang làm, Đã làm
class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({
    required this.statuses,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> statuses;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (int i = 0; i < statuses.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => onSelected(i),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? const Color(0xFFE8F1FF)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statuses[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selectedIndex == i
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selectedIndex == i
                          ? AppColors.blue
                          : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Một hàng hiển thị đề thi trong danh sách
class _ExamListItem extends StatelessWidget {
  const _ExamListItem({
    required this.test,
    required this.hasCrown,
    required this.onTap,
  });

  final ExamSummary test;
  final bool hasCrown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = test.attempts > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Tiêu đề & thông tin số câu, thời gian
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test.title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242B),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${test.totalQuestions} câu  |  ${test.durationMinutes} phút'
                    '${done ? '  |  Đã làm ${test.attempts} lần' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Icon Vương miện VIP nếu có
            if (hasCrown)
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Color(0xFF0284C7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

            // Điểm cao nhất nếu đã làm
            if (done)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${test.bestPercent}%',
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            // Mũi tên chuyển trang
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 22,
            ),
          ],
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
