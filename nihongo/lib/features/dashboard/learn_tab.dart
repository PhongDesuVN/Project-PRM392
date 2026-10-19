import 'package:flutter/material.dart';

import '../../shared/ui.dart';
import 'learning_topic.dart';

/// Tab Hoc: danh sach day du cac chu de. Moi chu de se mo man hinh
/// bai hoc rieng khi chuc nang duoc lam.
class LearnTab extends StatelessWidget {
  const LearnTab({super.key, required this.onTopicTap});

  final ValueChanged<LearningTopic> onTopicTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text(
          'Học',
          style: TextStyle(
            color: AppColors.blue,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Bài học Hiragana, Katakana, Kanji và từ vựng sẽ có ở đây.',
          style: TextStyle(color: AppColors.darkText, fontSize: 15),
        ),
        const SizedBox(height: 16),
        for (final topic in learningTopics)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                onTap: () => onTopicTap(topic),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: TopicSymbol(topic: topic),
                title: Text(
                  topic.title,
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  topic.subtitle,
                  style: const TextStyle(color: AppColors.placeholder),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.placeholder,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
