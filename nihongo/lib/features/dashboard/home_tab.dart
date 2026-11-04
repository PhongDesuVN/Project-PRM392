import 'package:flutter/material.dart';

import '../../shared/nihon_logo.dart';
import '../../shared/ui.dart';
import 'daily_challenge_detail_page.dart';
import 'daily_challenge_service.dart';
import 'learning_topic.dart';
import 'search_history_service.dart';
import 'widgets/extensions_bottom_sheet.dart';

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
    this.onOpenAlphabetLibrary,
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
  final VoidCallback? onOpenAlphabetLibrary;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _searchController = TextEditingController();

  // Thử thách mỗi ngày (Bộ 5 câu hỏi)
  List<DailyChallengeQuiz> _dailyQuizzes = [];
  int _currentQuizIndex = 0;
  final Map<int, int> _userAnswers = {};

  DailyChallengeQuiz get _currentQuiz => _dailyQuizzes.isNotEmpty
      ? _dailyQuizzes[_currentQuizIndex]
      : DailyChallengeService.instance.generateRandomQuiz();

  int? get _selectedAnswerIndex => _userAnswers[_currentQuizIndex];

  @override
  void initState() {
    super.initState();
    _dailyQuizzes = DailyChallengeService.instance.generateDailySet(count: 5);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch([String? text]) {
    final query = (text ?? _searchController.text).trim();
    if (query.isNotEmpty) {
      SearchHistoryService.instance.addKeyword(query);
      widget.onSearch(query);
    } else {
      widget.onOpenDictionary();
    }
  }

  void _removeKeyword(String word) {
    SearchHistoryService.instance.removeKeyword(word);
  }

  void _nextQuiz() {
    setState(() {
      if (_dailyQuizzes.isEmpty) {
        _dailyQuizzes = DailyChallengeService.instance.generateDailySet(
          count: 5,
        );
        _currentQuizIndex = 0;
      } else {
        _currentQuizIndex = (_currentQuizIndex + 1) % _dailyQuizzes.length;
      }
    });
  }

  void _openDailyChallengeDetail() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DailyChallengeDetailPage(
          quizzes: _dailyQuizzes,
          userAnswers: _userAnswers,
          onSelectAnswer: (quizIdx, optIdx) {
            setState(() {
              _userAnswers[quizIdx] = optIdx;
            });
          },
        ),
      ),
    );
  }

  void _onAnswerSelected(int index) {
    if (_userAnswers.containsKey(_currentQuizIndex)) return;

    final quiz = _currentQuiz;
    final isCorrect = index == quiz.correctIndex;

    setState(() {
      _userAnswers[_currentQuizIndex] = index;
    });

    if (isCorrect) {
      // Khi chọn đáp án đúng thì tự động next câu khác sau 600ms
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        if (_currentQuizIndex < _dailyQuizzes.length - 1) {
          setState(() {
            _currentQuizIndex++;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.fullName?.trim();
    final greeting = name != null && name.isNotEmpty
        ? 'Xin chào, $name'
        : 'Xin chào';
    final initial = name != null && name.isNotEmpty
        ? name[0].toUpperCase()
        : 'N';
    final quiz = _currentQuiz;

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
                  Icon(Icons.auto_awesome, size: 16, color: AppColors.gold),
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
                  const Text(
                    '今日の学び  ·  NIHONGO',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 5),
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
                      color: AppColors.primary,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SearchToolSquareButton(
                        icon: Icons.camera_alt_outlined,
                        iconColor: AppColors.primary,
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
                            color: AppColors.accent,
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
                        iconColor: AppColors.gold,
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
                onTap: () {
                  if (widget.onOpenAlphabetLibrary != null) {
                    widget.onOpenAlphabetLibrary!();
                  } else {
                    widget.onTopicTap(learningTopics[0]);
                  }
                },
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
                onTap: () {
                  ExtensionsBottomSheet.show(
                    context: context,
                    onOpenDictionary: widget.onOpenDictionary,
                    onOpenTranslation: widget.onOpenTranslation,
                    onOpenLearning: widget.onOpenLearning,
                    onOpenMockExam: widget.onOpenMockExam,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ===================================================================
        // 4. PHẦN: TÌM KIẾM GẦN ĐÂY (Với các tag có nút xoá '✕')
        // Chỉ hiển thị khi người dùng hoặc khách đã thực hiện tìm kiếm
        // Sử dụng ListenableBuilder để tự động render an toàn, không gọi setState during build
        // ===================================================================
        ListenableBuilder(
          listenable: SearchHistoryService.instance,
          builder: (context, _) {
            final keywords = SearchHistoryService.instance.recentKeywords;
            if (keywords.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: keywords.map((word) {
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
              ],
            );
          },
        ),

        // ===================================================================
        // 5. PHẦN: THỬ THÁCH MỖI NGÀY (Quiz Kanji tương tác với 4 đáp án)
        // ===================================================================
        _buildSectionHeader(
          title: 'Thử thách mỗi ngày',
          onTap: _openDailyChallengeDetail,
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
              // Dòng câu hỏi Từ vựng / Ngữ pháp & nút đổi câu hỏi khác
              Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 46,
                      minHeight: 46,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          (quiz.type == DailyQuizType.grammar
                                  ? AppColors.accent
                                  : AppColors.primary)
                              .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      quiz.prompt,
                      style: TextStyle(
                        fontSize: quiz.prompt.length > 5
                            ? 15
                            : (quiz.prompt.length > 2 ? 18 : 22),
                        fontWeight: FontWeight.w900,
                        color: quiz.type == DailyQuizType.grammar
                            ? AppColors.accent
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: quiz.type == DailyQuizType.grammar
                                    ? AppColors.accent.withValues(alpha: 0.1)
                                    : AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                quiz.categoryLabel,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: quiz.type == DailyQuizType.grammar
                                      ? AppColors.accent
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${_currentQuizIndex + 1}/5)',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          quiz.subtitle,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
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
                      bgColor = AppColors.primarySoft;
                      borderColor = AppColors.primary;
                      textColor = AppColors.primary;
                    } else if (isSelected) {
                      bgColor = AppColors.error.withValues(alpha: 0.1);
                      borderColor = AppColors.error;
                      textColor = AppColors.error;
                    }
                  }

                  return InkWell(
                    onTap: () => _onAnswerSelected(index),
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
              if (_selectedAnswerIndex != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      _selectedAnswerIndex == quiz.correctIndex
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 16,
                      color: _selectedAnswerIndex == quiz.correctIndex
                          ? AppColors.primary
                          : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _selectedAnswerIndex == quiz.correctIndex
                            ? 'Chính xác! Bạn làm rất tốt.'
                            : 'Chưa đúng. Đáp án: ${quiz.options[quiz.correctIndex]}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _selectedAnswerIndex == quiz.correctIndex
                              ? AppColors.primary
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
              colors: [AppColors.primarySoft, Color(0xFFF7FAF9)],
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
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
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
class _SearchToolSquareButton extends StatefulWidget {
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
  State<_SearchToolSquareButton> createState() =>
      _SearchToolSquareButtonState();
}

class _SearchToolSquareButtonState extends State<_SearchToolSquareButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _pressed ? AppColors.accent : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(
                    alpha: _pressed ? 0.04 : 0.015,
                  ),
                  blurRadius: _pressed ? 4 : 8,
                  offset: Offset(0, _pressed ? 1 : 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.customIcon != null)
                  widget.customIcon!
                else if (widget.icon != null)
                  Icon(
                    widget.icon,
                    size: 21,
                    color: widget.iconColor ?? AppColors.primary,
                  ),
                const SizedBox(height: 5),
                Text(
                  widget.label,
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
      ),
    );
  }
}

/// Nút dạng viên thuốc rộng (Bảng chữ cái, Tiện ích mở rộng)
class _QuickPillButton extends StatefulWidget {
  const _QuickPillButton({
    required this.title,
    required this.trailingWidget,
    required this.onTap,
  });

  final String title;
  final Widget trailingWidget;
  final VoidCallback onTap;

  @override
  State<_QuickPillButton> createState() => _QuickPillButtonState();
}

class _QuickPillButtonState extends State<_QuickPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _pressed ? AppColors.accent : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(
                    alpha: _pressed ? 0.03 : 0.06,
                  ),
                  blurRadius: _pressed ? 4 : 10,
                  offset: Offset(0, _pressed ? 1 : 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                widget.trailingWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
