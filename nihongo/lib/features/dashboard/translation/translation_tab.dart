import 'package:flutter/material.dart';

import '../../../shared/ui.dart';
import '../shared/dashboard_tool_widgets.dart';

class TranslationTab extends StatefulWidget {
  const TranslationTab({super.key});

  @override
  State<TranslationTab> createState() => _TranslationTabState();
}

class _TranslationTabState extends State<TranslationTab> {
  final _textController = TextEditingController();
  bool _japaneseToVietnamese = true;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showTranslateMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dịch vụ dịch sẽ được kết nối trong bước tiếp theo.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sourceLanguage = _japaneseToVietnamese ? 'Tiếng Nhật' : 'Tiếng Việt';
    final targetLanguage = _japaneseToVietnamese ? 'Tiếng Việt' : 'Tiếng Nhật';

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: [
        const DashboardToolHeading(
          eyebrow: 'CÔNG CỤ',
          title: 'Dịch văn bản',
          subtitle: 'Chuyển đổi nhanh giữa tiếng Nhật và tiếng Việt.',
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: _LanguageLabel(sourceLanguage)),
            IconButton.filledTonal(
              tooltip: 'Đổi chiều dịch',
              onPressed: () => setState(
                () => _japaneseToVietnamese = !_japaneseToVietnamese,
              ),
              icon: const Icon(Icons.swap_horiz_rounded),
            ),
            Expanded(child: _LanguageLabel(targetLanguage)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textController,
          minLines: 5,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Nhập nội dung cần dịch',
            filled: true,
            fillColor: Colors.white,
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: FilledButton.icon(
            onPressed: _showTranslateMessage,
            icon: const Icon(Icons.translate_rounded),
            label: const Text('Dịch'),
          ),
        ),
        const SizedBox(height: 16),
        const DashboardEmptyState(
          icon: Icons.forum_outlined,
          title: 'Bản dịch sẽ hiển thị tại đây',
          message: 'Nhập văn bản ở trên để bắt đầu.',
        ),
      ],
    );
  }
}

class _LanguageLabel extends StatelessWidget {
  const _LanguageLabel(this.language);

  final String language;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        language,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}