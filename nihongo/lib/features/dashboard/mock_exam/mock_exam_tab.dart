import 'package:flutter/material.dart';

import '../../../shared/ui.dart';
import '../shared/dashboard_tool_widgets.dart';

class MockExamTab extends StatelessWidget {
  const MockExamTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: [
        const DashboardToolHeading(
          eyebrow: 'ÔN LUYỆN',
          title: 'Thi thử JLPT',
          subtitle: 'Làm quen cấu trúc đề và kiểm tra trình độ.',
        ),
        const SizedBox(height: 22),
        for (final level in const ['N5', 'N4', 'N3'])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ExamLevelTile(level: level),
          ),
        const SizedBox(height: 14),
        const DashboardEmptyState(
          icon: Icons.fact_check_outlined,
          title: 'Đề thi đang được chuẩn bị',
          message: 'Bộ câu hỏi và chấm điểm sẽ được bổ sung khi có dữ liệu thi thử.',
        ),
      ],
    );
  }
}

class _ExamLevelTile extends StatelessWidget {
  const _ExamLevelTile({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level,
              style: const TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Đề luyện tập $level',
              style: const TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.placeholder),
        ],
      ),
    );
  }
}