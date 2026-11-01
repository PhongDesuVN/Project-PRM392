import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/ui.dart';
import '../models/ocr_dictionary_entry.dart';

/// Thẻ hiển thị một mục từ điển được AI phân tích và cấu trúc hóa hoàn chỉnh
class OcrDictionaryCard extends StatefulWidget {
  const OcrDictionaryCard({
    super.key,
    required this.entry,
    required this.onSearchDetail,
    this.onSaveToNotebook,
  });

  final OcrDictionaryEntry entry;
  final VoidCallback onSearchDetail;
  final VoidCallback? onSaveToNotebook;

  @override
  State<OcrDictionaryCard> createState() => _OcrDictionaryCardState();
}

class _OcrDictionaryCardState extends State<OcrDictionaryCard> {
  bool _isExamplesExpanded = true;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Từ khóa chính, Phiên âm, Huy hiệu JLPT, Từ loại
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Từ khóa chính (Entry Word)
                          Text(
                            entry.entryWord,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E242B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Cách đọc Hiragana / Furigana
                          Row(
                            children: [
                              Text(
                                entry.reading,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blue,
                                ),
                              ),
                              if (entry.romaji.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '[${entry.romaji}]',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                              if (entry.hanViet.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: const Color(0xFFFDE68A),
                                    ),
                                  ),
                                  child: Text(
                                    entry.hanViet,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Huy hiệu JLPT
                    if (entry.jlptLevel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          entry.jlptLevel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                  ],
                ),
                if (entry.partOfSpeech.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: entry.partOfSpeech.contains('Hiragana')
                          ? const Color(0xFFEFF6FF)
                          : (entry.partOfSpeech.contains('Katakana')
                              ? const Color(0xFFFFF7ED)
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: entry.partOfSpeech.contains('Hiragana')
                            ? const Color(0xFFBFDBFE)
                            : (entry.partOfSpeech.contains('Katakana')
                                ? const Color(0xFFFED7AA)
                                : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Text(
                      entry.partOfSpeech,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: entry.partOfSpeech.contains('Hiragana')
                            ? const Color(0xFF1D4ED8)
                            : (entry.partOfSpeech.contains('Katakana')
                                ? const Color(0xFFC2410C)
                                : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Definitions (Các tầng nghĩa)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.menu_book_rounded, size: 16, color: AppColors.blue),
                    SizedBox(width: 6),
                    Text(
                      'Ý nghĩa ngữ cảnh',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...entry.definitions.asMap().entries.map((defEntry) {
                  final index = defEntry.key + 1;
                  final defText = defEntry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$index. ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            defText,
                            style: const TextStyle(
                              fontSize: 14.5,
                              color: Color(0xFF1E242B),
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Examples (Câu ví dụ song ngữ Nhật - Việt)
          if (entry.examples.isNotEmpty) ...[
            Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExamplesExpanded = !_isExamplesExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.format_quote_rounded,
                              size: 16,
                              color: Color(0xFF00B894),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Ví dụ minh họa (${entry.examples.length})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          _isExamplesExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  if (_isExamplesExpanded) ...[
                    const SizedBox(height: 8),
                    ...entry.examples.map((ex) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex.japanese,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E242B),
                              ),
                            ),
                            if (ex.reading.isNotEmpty && ex.reading != ex.japanese) ...[
                              const SizedBox(height: 2),
                              Text(
                                ex.reading,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              ex.vietnamese,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF00B894),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],

          // Footer action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: widget.onSearchDetail,
                    icon: const Icon(Icons.travel_explore_rounded, size: 16, color: AppColors.blue),
                    label: const Text(
                      'Tra từ điển',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                ),
                if (widget.onSaveToNotebook != null) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: widget.onSaveToNotebook,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 16, color: Color(0xFFD97706)),
                      label: const Text(
                        'Lưu sổ tay',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ),
                ],
                IconButton(
                  tooltip: 'Sao chép',
                  icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.grey),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: '${entry.entryWord} (${entry.reading})'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã sao chép "${entry.entryWord}"'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

