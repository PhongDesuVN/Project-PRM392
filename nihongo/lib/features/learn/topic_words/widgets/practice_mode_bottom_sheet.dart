import 'package:flutter/material.dart';

/// Modal Bottom Sheet "Chọn chế độ luyện tập" theo đúng giao diện Ảnh 1.
/// Theo yêu cầu: Chỉ cho phép chọn Flashcard để luyện tập.
class PracticeModeBottomSheet extends StatefulWidget {
  const PracticeModeBottomSheet({super.key, required this.onSelectFlashcard});

  final VoidCallback onSelectFlashcard;

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onSelectFlashcard,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          PracticeModeBottomSheet(onSelectFlashcard: onSelectFlashcard),
    );
  }

  @override
  State<PracticeModeBottomSheet> createState() =>
      _PracticeModeBottomSheetState();
}

class _PracticeModeBottomSheetState extends State<PracticeModeBottomSheet> {
  bool _spacedRepetitionEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 18),

          // Title
          const Text(
            'Chọn chế độ luyện tập',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E242B),
            ),
          ),
          const SizedBox(height: 16),

          // Học lặp lại ngắt quãng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Học lặp lại ngắt quãng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              Switch.adaptive(
                value: _spacedRepetitionEnabled,
                activeTrackColor: const Color(0xFF1976D2),
                onChanged: (val) {
                  setState(() => _spacedRepetitionEnabled = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Chế độ Flashcard (KÍCH HOẠT ĐẦY ĐỦ)
          _PracticeModeItem(
            iconData: Icons.style_rounded,
            iconColor: const Color(0xFF1976D2),
            iconBgColor: const Color(0xFFE3F2FD),
            title: 'Flashcard',
            subtitle: 'Ôn lại từ vựng bằng flashcards',
            isEnabled: true,
            onTap: () {
              Navigator.pop(context);
              widget.onSelectFlashcard();
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PracticeModeItem extends StatelessWidget {
  const _PracticeModeItem({
    required this.iconData,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.onTap,
  });

  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isEnabled ? const Color(0xFFBBDEFB) : Colors.grey.shade200,
              width: isEnabled ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isEnabled ? iconColor : iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: isEnabled
                      ? Colors.white
                      : iconColor.withValues(alpha: 0.5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isEnabled
                                ? const Color(0xFF1E242B)
                                : Colors.grey.shade600,
                          ),
                        ),
                        if (!isEnabled) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Khóa',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
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
