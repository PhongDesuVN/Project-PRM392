import 'package:flutter/material.dart';

import '../../../../shared/ui.dart';
import '../models/ocr_scan_result.dart';

/// Card hiển thị nội dung nhận diện từ AI kèm các từ khóa bóc tách được
class OcrResultCard extends StatelessWidget {
  const OcrResultCard({
    super.key,
    required this.scanResult,
    required this.textController,
    required this.selectedWord,
    required this.onSelectWord,
    required this.onCopyText,
  });

  final OcrScanResult scanResult;
  final TextEditingController textController;
  final String? selectedWord;
  final ValueChanged<String> onSelectWord;
  final VoidCallback onCopyText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.text_fields_rounded, color: AppColors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Nội dung nhận diện',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E242B),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18, color: Colors.grey),
                tooltip: 'Sao chép văn bản',
                onPressed: onCopyText,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Khung văn bản cho phép người dùng xem và chỉnh sửa nếu AI nhận diện nhầm ký tự
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: textController,
              maxLines: 4,
              minLines: 2,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Color(0xFF2D3436),
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Chưa nhận diện được nội dung...',
              ),
            ),
          ),
          if (scanResult.detectedWords.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Từ vựng & Kanji bóc tách được:',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: scanResult.detectedWords.map((word) {
                final isSelected = selectedWord == word.text;
                Color bgColor;
                Color borderColor;
                Color textColor;

                if (isSelected) {
                  bgColor = AppColors.blue;
                  borderColor = AppColors.blue;
                  textColor = Colors.white;
                } else {
                  switch (word.scriptType) {
                    case JapaneseScriptType.katakana:
                      bgColor = const Color(0xFFFFF7ED);
                      borderColor = const Color(0xFFFED7AA);
                      textColor = const Color(0xFFC2410C);
                      break;
                    case JapaneseScriptType.hiragana:
                      bgColor = const Color(0xFFF0FDF4);
                      borderColor = const Color(0xFFBBF7D0);
                      textColor = const Color(0xFF15803D);
                      break;
                    case JapaneseScriptType.kanji:
                    case JapaneseScriptType.mixedKanjiKana:
                      bgColor = const Color(0xFFEFF6FF);
                      borderColor = const Color(0xFFBFDBFE);
                      textColor = const Color(0xFF1D4ED8);
                      break;
                    case JapaneseScriptType.other:
                      bgColor = const Color(0xFFF1F5F9);
                      borderColor = const Color(0xFFE2E8F0);
                      textColor = const Color(0xFF334155);
                      break;
                  }
                }

                return Tooltip(
                  message: word.scriptLabel,
                  child: InkWell(
                    onTap: () => onSelectWord(word.text),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        word.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

