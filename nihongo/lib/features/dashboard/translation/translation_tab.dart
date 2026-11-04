import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/ui.dart';
import '../shared/dashboard_tool_widgets.dart';
import 'translation_service.dart';

class TranslationTab extends StatefulWidget {
  const TranslationTab({super.key, this.initialText});

  final String? initialText;

  @override
  State<TranslationTab> createState() => _TranslationTabState();
}

class _TranslationTabState extends State<TranslationTab> {
  late final TextEditingController _textController;
  final _translationService = TranslationService();
  bool _japaneseToVietnamese = true;
  bool _isTranslating = false;
  String _translationStatus = 'Đang chuẩn bị dịch...';
  String? _translatedText;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
    if (widget.initialText != null && widget.initialText!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _translate();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _translationService.dispose();
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
        onChunk: (partial) {
          if (mounted) setState(() => _translatedText = partial);
        },
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _swapLanguages() {
    setState(() {
      _japaneseToVietnamese = !_japaneseToVietnamese;
      _translatedText = null;
    });
  }

  Future<void> _copyInput() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) _showMessage('Đã sao chép nội dung gốc.');
  }

  Future<void> _copyTranslation() async {
    final text = _translatedText;
    if (text == null || text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) _showMessage('Đã sao chép bản dịch.');
  }

  void _speakText(String text, String lang) {
    if (text.trim().isEmpty) return;
    _showMessage('Phát âm thanh: $text');
  }

  @override
  Widget build(BuildContext context) {
    final sourceName = _japaneseToVietnamese ? 'Japanese' : 'Vietnamese';
    final targetName = _japaneseToVietnamese ? 'Vietnamese' : 'Japanese';

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
      children: [
        const DashboardToolHeading(
          eyebrow: 'CÔNG CỤ',
          title: 'Dịch văn bản',
          subtitle: 'Dịch trực tuyến Nhật - Việt bằng Gemini AI.',
        ),
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- TOP SECTION (INPUT) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Language indicator
                    _buildLanguagePicker(
                      label: sourceName,
                      isTarget: false,
                      onSelected: (val) {
                        if ((val == 'Japanese' && !_japaneseToVietnamese) ||
                            (val == 'Vietnamese' && _japaneseToVietnamese)) {
                          _swapLanguages();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    // Multi-line Input
                    TextField(
                      controller: _textController,
                      enabled: !_isTranslating,
                      minLines: 3,
                      maxLines: 8,
                      maxLength: 5000,
                      onChanged: (_) {
                        if (_translatedText != null) {
                          setState(() => _translatedText = null);
                        }
                      },
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Nhập văn bản ...',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 16,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Input actions (Speaker, Copy, Clear)
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: 'Nghe nội dung',
                          icon: const Icon(
                            Icons.volume_up_outlined,
                            size: 22,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: () => _speakText(
                            _textController.text,
                            _japaneseToVietnamese ? 'ja' : 'vi',
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: 'Sao chép nội dung',
                          icon: const Icon(
                            Icons.copy_outlined,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: _copyInput,
                        ),
                        if (_textController.text.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            tooltip: 'Xóa',
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Color(0xFF94A3B8),
                            ),
                            onPressed: () {
                              setState(() {
                                _textController.clear();
                                _translatedText = null;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // --- CENTER DIVIDER WITH CIRCULAR SWAP BUTTON ---
              Stack(
                alignment: Alignment.center,
                children: [
                  const Divider(
                    height: 36,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                  ),
                  Material(
                    color: const Color(0xFFF8FAFC),
                    shape: const CircleBorder(
                      side: BorderSide(color: Color(0xFFE2E8F0), width: 1.1),
                    ),
                    elevation: 0,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _isTranslating ? null : _swapLanguages,
                      child: const Padding(
                        padding: EdgeInsets.all(7),
                        child: Icon(
                          Icons.swap_vert_rounded,
                          size: 20,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // --- BOTTOM SECTION (OUTPUT) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Target Language indicator
                    _buildLanguagePicker(
                      label: targetName,
                      isTarget: true,
                      onSelected: (val) {
                        if ((val == 'Vietnamese' && !_japaneseToVietnamese) ||
                            (val == 'Japanese' && _japaneseToVietnamese)) {
                          _swapLanguages();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Output content
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 70),
                      child: _buildOutputContent(),
                    ),
                    const SizedBox(height: 14),
                    // Bottom actions row
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: 'Nghe bản dịch',
                          icon: Icon(
                            Icons.volume_up_outlined,
                            size: 22,
                            color: _translatedText != null
                                ? const Color(0xFF64748B)
                                : const Color(0xFFCBD5E1),
                          ),
                          onPressed: _translatedText != null
                              ? () => _speakText(
                                  _translatedText!,
                                  _japaneseToVietnamese ? 'vi' : 'ja',
                                )
                              : null,
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: 'Sao chép bản dịch',
                          icon: Icon(
                            Icons.copy_outlined,
                            size: 20,
                            color: _translatedText != null
                                ? const Color(0xFF64748B)
                                : const Color(0xFFCBD5E1),
                          ),
                          onPressed: _translatedText != null
                              ? _copyTranslation
                              : null,
                        ),
                        const Spacer(),
                        // "Dịch nhanh" pill button
                        Material(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: _isTranslating ? null : _translate,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFDBEAFE),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isTranslating) ...[
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _translationStatus,
                                      style: const TextStyle(
                                        color: Color(0xFF2563EB),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ] else ...[
                                    const Icon(
                                      Icons.g_translate_rounded,
                                      color: Color(0xFF2563EB),
                                      size: 19,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Dịch nhanh',
                                      style: TextStyle(
                                        color: Color(0xFF2563EB),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.auto_awesome,
                                      color: Color(0xFF0F172A),
                                      size: 15,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguagePicker({
    required String label,
    required bool isTarget,
    required ValueChanged<String> onSelected,
  }) {
    final color = isTarget ? AppColors.primary : const Color(0xFF0F172A);

    return PopupMenuButton<String>(
      onSelected: onSelected,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'Japanese',
          child: Text('Japanese (Tiếng Nhật)'),
        ),
        const PopupMenuItem(
          value: 'Vietnamese',
          child: Text('Vietnamese (Tiếng Việt)'),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.arrow_drop_down_rounded, size: 24, color: color),
        ],
      ),
    );
  }

  Widget _buildOutputContent() {
    if (_isTranslating &&
        (_translatedText == null || _translatedText!.isEmpty)) {
      return Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _translationStatus,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      );
    }

    if (_translatedText == null || _translatedText!.trim().isEmpty) {
      return const Text(
        'Bản dịch',
        style: TextStyle(
          color: Color(0xFF93C5FD),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return SelectableText(
      _translatedText!,
      style: const TextStyle(
        fontSize: 16,
        height: 1.45,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
