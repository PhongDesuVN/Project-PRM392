import 'package:flutter/material.dart';

import '../../shared/ui.dart';

/// Mot chu de hoc hien tren dashboard. Du lieu tam thoi la hang so,
/// sau nay se lay tu backend.
class LearningTopic {
  const LearningTopic({
    required this.title,
    required this.subtitle,
    required this.symbol,
    required this.color,
    this.description = '',
    this.lessonCount = 0,
  });

  final String title;
  final String subtitle;

  /// Ky tu tieng Nhat dai dien cho chu de, hien trong o vuong cua card.
  final String symbol;
  final Color color;
  final String description;
  final int lessonCount;
}

const learningTopics = <LearningTopic>[
  LearningTopic(
    title: 'Hiragana',
    subtitle: '46 chữ cái cơ bản',
    symbol: 'あ',
    color: Color(0xFFE23832),
    description: 'Học cách đọc và viết các chữ cái Hiragana cơ bản để bắt đầu tiếng Nhật.',
    lessonCount: 4,
  ),
  LearningTopic(
    title: 'Katakana',
    subtitle: 'Chữ cho từ mượn',
    symbol: 'ア',
    color: AppColors.blue,
    description: 'Luyện nhận diện và viết Katakana, đặc biệt cho tên riêng và từ mượn.',
    lessonCount: 4,
  ),
  LearningTopic(
    title: 'Kanji',
    subtitle: 'Hán tự N5 - N1',
    symbol: '漢',
    color: Color(0xFF7B5CD6),
    description: 'Hiểu ý nghĩa, cách đọc và cách dùng các Hán tự điển hình trong đời sống.',
    lessonCount: 6,
  ),
  LearningTopic(
    title: 'Từ vựng',
    subtitle: 'Theo chủ đề',
    symbol: '語',
    color: Color(0xFF2E9E6A),
    description: 'Mở rộng vốn từ vựng theo chủ đề như gia đình, trường học và du lịch.',
    lessonCount: 5,
  ),
  LearningTopic(
    title: 'Ngữ pháp',
    subtitle: 'Mẫu câu thông dụng',
    symbol: '文',
    color: Color(0xFFE08A1E),
    description: 'Nắm các mẫu câu căn bản để nói và viết tự tin hơn trong giao tiếp.',
    lessonCount: 5,
  ),
  LearningTopic(
    title: 'Luyện nghe',
    subtitle: 'Hội thoại ngắn',
    symbol: '聞',
    color: Color(0xFF1C9BB0),
    description: 'Nghe hội thoại và luyện phản xạ qua các bài nghe ngắn theo chủ đề.',
    lessonCount: 4,
  ),
];

/// Card vuong cho mot chu de, dung trong luoi o tab Trang chu.
class TopicCard extends StatelessWidget {
  const TopicCard({super.key, required this.topic, required this.onTap});

  final LearningTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey('topic_${topic.title}'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopicSymbol(topic: topic),
              const Spacer(),
              Text(
                topic.title,
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                topic.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.placeholder,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// O vuong mau chua ky tu tieng Nhat cua chu de.
class TopicSymbol extends StatelessWidget {
  const TopicSymbol({super.key, required this.topic, this.size = 44});

  final LearningTopic topic;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: topic.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          topic.symbol,
          style: TextStyle(
            color: topic.color,
            fontSize: size * 0.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
