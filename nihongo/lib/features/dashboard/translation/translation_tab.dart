import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/ui.dart';
import '../shared/dashboard_tool_widgets.dart';
import 'translation_service.dart';

class TranslationTab extends StatefulWidget {
  const TranslationTab({super.key});

  @override
  State<TranslationTab> createState() => _TranslationTabState();
}

class _TranslationTabState extends State<TranslationTab> {
  final _textController = TextEditingController();
  final _translationService = TranslationService();
  bool _japaneseToVietnamese = true;
  bool _isTranslating = false;
  String _translationStatus = 'Đang chuẩn bị dịch...';
  String? _translatedText;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showMessage('Vui lòng nhập nội dung cần dịch.');
      return;
    }

    setState(() {
      _isTranslating = true;
      _translatedText = null;
      _translationStatus = 'Đang chuẩn bị dịch...';
    });

    try {
      final result = await _translationService.translate(
        text: text,
        sourceLanguage: _japaneseToVietnamese ? 'ja' : 'vi',
        targetLanguage: _japaneseToVietnamese ? 'vi' : 'ja',
        onStatus: (message) {
          if (mounted) setState(() => _translationStatus = message);
        },
      );
      if (mounted) {
        setState(() => _translatedText = result);
      }
    } on TranslationException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _isTranslating = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _swapLanguages() {
    setState(() {
      _japaneseToVietnamese = !_japaneseToVietnamese;
      _translatedText = null;
    });
  }

  Future<void> _copyTranslation() async {
    final text = _translatedText;
    if (text == null) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) _showMessage('Đã sao chép bản dịch.');
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
          subtitle: 'Dịch trên thiết bị; cần mạng để tải mô hình lần đầu.',
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: _LanguageLabel(sourceLanguage)),
            IconButton.filledTonal(
              tooltip: 'Đổi chiều dịch',
              onPressed: _isTranslating ? null : _swapLanguages,
              icon: const Icon(Icons.swap_horiz_rounded),
            ),
            Expanded(child: _LanguageLabel(targetLanguage)),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textController,
          enabled: !_isTranslating,
          minLines: 5,
          maxLines: 8,
          maxLength: 5000,
          onChanged: (_) {
            if (_translatedText != null) {
              setState(() => _translatedText = null);
            }
          },
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
            onPressed: _isTranslating ? null : _translate,
            icon: _isTranslating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.translate_rounded),
            label: Text(_isTranslating ? _translationStatus : 'Dịch'),
          ),
        ),
        const SizedBox(height: 16),
        if (_translatedText == null)
          const DashboardEmptyState(
            icon: Icons.forum_outlined,
            title: 'Bản dịch sẽ hiển thị tại đây',
            message: 'Nhập văn bản ở trên để bắt đầu.',
          )
        else
          _TranslationResult(text: _translatedText!, onCopy: _copyTranslation),
      ],
    );
  }
}

class _TranslationResult extends StatelessWidget {
  const _TranslationResult({required this.text, required this.onCopy});

  final String text;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Bản dịch',
                style: TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Sao chép bản dịch',
              onPressed: onCopy,
              icon: const Icon(Icons.copy_rounded),
            ),
          ],
        ),
        SelectableText(text),
      ],
    ),
  );
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
