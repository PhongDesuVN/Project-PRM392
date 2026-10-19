import 'package:flutter/material.dart';

import '../../shared/ui.dart';
import 'learning_topic.dart';

/// Tab Trang chu: loi chao, the "tu cua ngay", tien do va luoi chu de.
class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.fullName,
    required this.onStartLearning,
    required this.onTopicTap,
  });

  final String? fullName;
  final VoidCallback onStartLearning;
  final ValueChanged<LearningTopic> onTopicTap;

  @override
  Widget build(BuildContext context) {
    final name = fullName?.trim();
    final greeting =
        name != null && name.isNotEmpty ? 'Xin chào, $name' : 'Xin chào';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          greeting,
          style: const TextStyle(
            color: AppColors.blue,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Hôm nay mình học gì nhỉ?',
          style: TextStyle(color: AppColors.darkText, fontSize: 15),
        ),
        const SizedBox(height: 20),
        _WordOfDayCard(onStartLearning: onStartLearning),
        const SizedBox(height: 16),
        const _ProgressRow(),
        const SizedBox(height: 24),
        const Text(
          'Chủ đề học',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: learningTopics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemBuilder: (context, index) {
            final topic = learningTopics[index];
            return TopicCard(topic: topic, onTap: () => onTopicTap(topic));
          },
        ),
      ],
    );
  }
}

/// The noi bat dau trang. Tu vung dang co dinh, sau nay lay tu API.
class _WordOfDayCard extends StatelessWidget {
  const _WordOfDayCard({required this.onStartLearning});

  final VoidCallback onStartLearning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F96E8), Color(0xFF1670D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Từ của ngày',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          const Text(
            '勉強',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'べんきょう · benkyou · học tập',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onStartLearning,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: const Text('Bắt đầu học'),
          ),
        ],
      ),
    );
  }
}

/// Hai o thong ke. Gia tri tam la 0 cho den khi co API tien do.
class _ProgressRow extends StatelessWidget {
  const _ProgressRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.local_fire_department_outlined,
            color: Color(0xFFE23832),
            value: '0 ngày',
            label: 'Chuỗi học',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.check_circle_outline,
            color: Color(0xFF2E9E6A),
            value: '0 từ',
            label: 'Đã học',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.placeholder,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
