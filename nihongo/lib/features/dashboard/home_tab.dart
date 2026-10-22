import 'package:flutter/material.dart';

import '../../shared/nihon_logo.dart';
import '../../shared/ui.dart';
import 'learning_topic.dart';

/// Bang kham pha Nihon voi tim kiem nhanh va cac loi vao chinh.
class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.fullName,
    required this.onSearch,
    required this.onOpenDictionary,
    required this.onOpenTranslation,
    required this.onOpenLearning,
    required this.onOpenMockExam,
    required this.onOpenProfile,
    required this.onCameraSearch,
    required this.onHandwritingSearch,
    required this.onTopicTap,
  });

  final String? fullName;
  final ValueChanged<String> onSearch;
  final VoidCallback onOpenDictionary;
  final VoidCallback onOpenTranslation;
  final VoidCallback onOpenLearning;
  final VoidCallback onOpenMockExam;
  final VoidCallback onOpenProfile;
  final VoidCallback onCameraSearch;
  final VoidCallback onHandwritingSearch;
  final ValueChanged<LearningTopic> onTopicTap;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.fullName?.trim();
    final greeting =
        name != null && name.isNotEmpty ? 'Xin chào, $name' : 'Xin chào';
    final initial = name != null && name.isNotEmpty
        ? name[0].toUpperCase()
        : 'N';

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        Row(
          children: [
            SizedBox(
              width: 142,
              height: 44,
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.contain,
                child: const NihonLogo(),
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Hồ sơ',
              onPressed: widget.onOpenProfile,
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.blue.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          greeting,
          style: const TextStyle(
            color: AppColors.darkText,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tra cứu, luyện tập và tiến bộ mỗi ngày.',
          style: TextStyle(color: AppColors.placeholder, fontSize: 14),
        ),
        const SizedBox(height: 18),
        _QuickSearchPanel(
          controller: _searchController,
          onSearch: () => widget.onSearch(_searchController.text),
          onCameraSearch: widget.onCameraSearch,
          onHandwritingSearch: widget.onHandwritingSearch,
          onOpenDictionary: widget.onOpenDictionary,
        ),
        const SizedBox(height: 24),
        const _SectionHeading(
          title: 'Không gian học của bạn',
          subtitle: 'Chọn một hoạt động để bắt đầu',
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            _FeatureTile(
              title: 'Từ điển',
              subtitle: 'Tra từ Nhật - Việt',
              icon: Icons.menu_book_rounded,
              color: const Color(0xFF2879C8),
              onTap: widget.onOpenDictionary,
            ),
            _FeatureTile(
              title: 'Dịch',
              subtitle: 'Câu và đoạn văn',
              icon: Icons.g_translate_rounded,
              color: const Color(0xFF2F8B72),
              onTap: widget.onOpenTranslation,
            ),
            _FeatureTile(
              title: 'Học tập',
              subtitle: 'Bài học theo chủ đề',
              icon: Icons.auto_stories_rounded,
              color: const Color(0xFFD37736),
              onTap: widget.onOpenLearning,
            ),
            _FeatureTile(
              title: 'Thi thử',
              subtitle: 'Ôn luyện JLPT',
              icon: Icons.fact_check_rounded,
              color: const Color(0xFF7C63B8),
              onTap: widget.onOpenMockExam,
            ),
          ],
        ),
        const SizedBox(height: 22),
        _WordOfDayCard(onStartLearning: widget.onOpenLearning),
        const SizedBox(height: 24),
        _SectionHeading(
          title: 'Chủ đề học',
          subtitle: 'Lộ trình từ nền tảng đến JLPT',
          trailing: TextButton(
            onPressed: widget.onOpenLearning,
            child: const Text('Xem tất cả'),
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
            return TopicCard(
              topic: topic,
              onTap: () => widget.onTopicTap(topic),
            );
          },
        ),
      ],
    );
  }
}

class _QuickSearchPanel extends StatelessWidget {
  const _QuickSearchPanel({
    required this.controller,
    required this.onSearch,
    required this.onCameraSearch,
    required this.onHandwritingSearch,
    required this.onOpenDictionary,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onCameraSearch;
  final VoidCallback onHandwritingSearch;
  final VoidCallback onOpenDictionary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tìm nhanh',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              hintText: 'Nhập từ hoặc câu tiếng Nhật',
              prefixIcon: const Icon(Icons.search, color: AppColors.blue),
              suffixIcon: IconButton(
                tooltip: 'Mở từ điển',
                onPressed: onSearch,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SearchToolButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Chụp ảnh',
                  onPressed: onCameraSearch,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SearchToolButton(
                  icon: Icons.gesture_rounded,
                  label: 'Viết Kanji',
                  onPressed: onHandwritingSearch,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SearchToolButton(
                  icon: Icons.translate_rounded,
                  label: 'Dịch câu',
                  onPressed: onOpenDictionary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchToolButton extends StatelessWidget {
  const _SearchToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkText,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.placeholder,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.placeholder,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          FilledButton.icon(
            onPressed: onStartLearning,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Bắt đầu học'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
