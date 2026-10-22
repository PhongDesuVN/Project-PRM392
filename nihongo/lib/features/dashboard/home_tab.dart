import 'package:flutter/material.dart';

import '../../shared/nihon_logo.dart';
import '../../shared/ui.dart';
import 'learning_topic.dart';

/// Dữ liệu câu hỏi cho phần Thử thách mỗi ngày
class _DailyQuizItem {
  const _DailyQuizItem({
    required this.kanji,
    required this.sino,
    required this.options,
    required this.correctIndex,
  });

  final String kanji;
  final String sino;
  final List<String> options;
  final int correctIndex;
}

const _kDailyQuizzes = <_DailyQuizItem>[
  _DailyQuizItem(
    kanji: '写',
    sino: 'TẢ',
    options: ['việc đặt hàng', 'sự lái (xe)', 'à à...', '1. sao chép'],
    correctIndex: 3,
  ),
  _DailyQuizItem(
    kanji: '学',
    sino: 'HỌC',
    options: ['học tập', 'ngôi trường', 'bắt đầu', 'mùa hè'],
    correctIndex: 0,
  ),
  _DailyQuizItem(
    kanji: '生',
    sino: 'SINH',
    options: ['con đường', 'mặt trời', 'cuộc sống', 'ngôi sao'],
    correctIndex: 2,
  ),
  _DailyQuizItem(
    kanji: '行',
    sino: 'HÀNH',
    options: ['đi, tiến hành', 'dừng lại', 'nghỉ ngơi', 'nấu ăn'],
    correctIndex: 0,
  ),
];

/// Tab Khám phá: tìm kiếm nhanh phong cách Mazii, phím tắt bảng chữ cái,
/// từ khóa gần đây, thử thách mỗi ngày và chủ đề học.
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

  // Danh sách từ khóa tìm kiếm gần đây giống giao diện mẫu
  final List<String> _recentKeywords = [
    'セ',
    '出し',
    '貸し',
    '多く',
    '生活',
    '商協',
    '協',
    '小さい',
    '火',
  ];

  // Thử thách mỗi ngày
  int _quizIndex = 0;
  int? _selectedAnswerIndex;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch([String? text]) {
    final query = (text ?? _searchController.text).trim();
    if (query.isNotEmpty) {
      if (!_recentKeywords.contains(query)) {
        setState(() {
          _recentKeywords.insert(0, query);
          if (_recentKeywords.length > 12) _recentKeywords.removeLast();
        });
      }
      widget.onSearch(query);
    } else {
      widget.onOpenDictionary();
    }
  }

  void _removeKeyword(String word) {
    setState(() => _recentKeywords.remove(word));
  }

  void _nextQuiz() {
    setState(() {
      _quizIndex = (_quizIndex + 1) % _kDailyQuizzes.length;
      _selectedAnswerIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.fullName?.trim();
    final greeting =
        name != null && name.isNotEmpty ? 'Xin chào, $name' : 'Xin chào';
    final initial = name != null && name.isNotEmpty ? name[0].toUpperCase() : 'N';
    final quiz = _kDailyQuizzes[_quizIndex];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // ===================================================================
        // 1. TOP BAR: [TRÌNH ĐỘ ↕] --------- [✨ 100%] [AVATAR HỒ SƠ]
        // (Đã bỏ bánh răng cài đặt theo yêu cầu)
        // ===================================================================
        Row(
          children: [
            // Logo Nihon
            SizedBox(
              width: 125,
              height: 40,
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.contain,
                child: const NihonLogo(),
              ),
            ),
            const Spacer(),

            // Badge tiến độ 100%
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Color(0xFF8E44AD),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '100%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Nút Hồ sơ cá nhân
            IconButton(
              tooltip: 'Hồ sơ',
              onPressed: widget.onOpenProfile,
              icon: CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.blue.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Lời chào hiển thị thân thiện (giúp test check được greeting)
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tra cứu, luyện tập và tiến bộ mỗi ngày.',
                    style: TextStyle(
                      color: AppColors.placeholder,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ===================================================================
        // 2. KHUNG TÌM KIẾM MAZII STYLE:
        // Input [🔍 Nhập Tiếng Nhật cần tìm] [JA  VI]
        // Công cụ [📷 Chụp ảnh]  [夂 Tra bộ thủ]  [✏️ Viết Kanji]
        // (Đã bỏ micro nói theo yêu cầu)
        // ===================================================================
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Ô nhập từ khoá
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF6C5CE7),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _submitSearch,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Nhập Tiếng Nhật cần tìm',
                          hintStyle: TextStyle(
                            color: AppColors.placeholder,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 0.8),
              // Hàng công cụ tìm kiếm: Chụp ảnh | Tra bộ thủ | Viết Kanji
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _SearchToolSquareButton(
                        icon: Icons.camera_alt_outlined,
                        iconColor: const Color(0xFF0984E3),
                        label: 'Chụp ảnh',
                        onTap: widget.onCameraSearch,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SearchToolSquareButton(
                        customIcon: const Text(
                          '夂',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00B894),
                          ),
                        ),
                        label: 'Tra bộ thủ',
                        onTap: widget.onOpenDictionary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SearchToolSquareButton(
                        icon: Icons.edit_note_rounded,
                        iconColor: const Color(0xFFE17055),
                        label: 'Viết Kanji',
                        onTap: widget.onHandwritingSearch,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ===================================================================
        // 3. SHORTCUTS: [ Bảng chữ cái あ ] & [ Tiện ích mở rộng ⊞ ]
        // ===================================================================
        Row(
          children: [
            Expanded(
              child: _QuickPillButton(
                title: 'Bảng chữ cái',
                trailingWidget: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE23832).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'あ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE23832),
                    ),
                  ),
                ),
                onTap: () => widget.onTopicTap(learningTopics[0]),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickPillButton(
                title: 'Tiện ích mở rộng',
                trailingWidget: const Icon(
                  Icons.grid_view_rounded,
                  size: 19,
                  color: AppColors.darkText,
                ),
                onTap: widget.onOpenMockExam,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ===================================================================
        // 4. PHẦN: TÌM KIẾM GẦN ĐÂY (Với các tag có nút xoá '✕')
        // ===================================================================
        _buildSectionHeader(
          title: 'Tìm kiếm gần đây',
          onTap: widget.onOpenDictionary,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: _recentKeywords.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Text(
                      'Chưa có từ khoá tìm kiếm nào',
                      style: TextStyle(color: AppColors.placeholder, fontSize: 13),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recentKeywords.map((word) {
                    return InkWell(
                      onTap: () => _submitSearch(word),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              word,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _removeKeyword(word),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: AppColors.placeholder,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 20),

        // ===================================================================
        // 5. PHẦN: THỬ THÁCH MỖI NGÀY (Quiz Kanji tương tác với 4 đáp án)
        // ===================================================================
        _buildSectionHeader(
          title: 'Thử thách mỗi ngày',
          onTap: _nextQuiz,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dòng Kanji câu hỏi & nút đổi từ khác
              Row(
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
                      quiz.kanji,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '「${quiz.sino}」',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Đổi câu hỏi',
                    onPressed: _nextQuiz,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.placeholder,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 4 ô đáp án lựa chọn (2x2 grid)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quiz.options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.3,
                ),
                itemBuilder: (context, index) {
                  final optionText = quiz.options[index];
                  final isSelected = _selectedAnswerIndex == index;
                  final isCorrect = index == quiz.correctIndex;

                  Color bgColor = const Color(0xFFF8FAFC);
                  Color borderColor = AppColors.border;
                  Color textColor = AppColors.darkText;

                  if (_selectedAnswerIndex != null) {
                    if (isCorrect) {
                      bgColor = const Color(0xFFE8F8F5);
                      borderColor = const Color(0xFF00B894);
                      textColor = const Color(0xFF00B894);
                    } else if (isSelected) {
                      bgColor = const Color(0xFFFDEDEC);
                      borderColor = const Color(0xFFE74C3C);
                      textColor = const Color(0xFFE74C3C);
                    }
                  }

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedAnswerIndex = index);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        optionText,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ===================================================================
        // 6. PHẦN: KHÁM PHÁ NIHONGO / BẮT ĐẦU HỌC
        // ===================================================================
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFEBF4FF), Color(0xFFF5F9FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cách học cùng Nihongo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bốn việc nên biết để học hiệu quả trong 2 phút',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.placeholder,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: widget.onOpenLearning,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Bắt đầu học',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.blue,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.darkText,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (trailingText != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              trailingText,
              style: const TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          IconButton(
            onPressed: onTap,
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.placeholder,
            ),
          ),
      ],
    );
  }
}

/// Nút vuông trong hàng công cụ tìm kiếm: Chụp ảnh, Tra bộ thủ, Viết Kanji
class _SearchToolSquareButton extends StatelessWidget {
  const _SearchToolSquareButton({
    this.icon,
    this.customIcon,
    this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData? icon;
  final Widget? customIcon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (customIcon != null)
                customIcon!
              else if (icon != null)
                Icon(icon, size: 21, color: iconColor ?? AppColors.blue),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút dạng viên thuốc rộng (Bảng chữ cái, Tiện ích mở rộng)
class _QuickPillButton extends StatelessWidget {
  const _QuickPillButton({
    required this.title,
    required this.trailingWidget,
    required this.onTap,
  });

  final String title;
  final Widget trailingWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}
