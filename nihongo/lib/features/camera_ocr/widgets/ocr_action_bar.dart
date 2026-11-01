import 'package:flutter/material.dart';

import '../../../../shared/ui.dart';

/// Thanh công cụ hành động: Tra từ điển, Dịch, Sao chép
class OcrActionBar extends StatelessWidget {
  const OcrActionBar({
    super.key,
    required this.hasContent,
    required this.onSearchDictionary,
    required this.onTranslate,
    required this.onCopy,
  });

  final bool hasContent;
  final VoidCallback onSearchDictionary;
  final VoidCallback onTranslate;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: hasContent ? onSearchDictionary : null,
                icon: const Icon(Icons.search_rounded, size: 20),
                label: const Text(
                  'Tra từ điển',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E242B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: hasContent ? onTranslate : null,
                icon: const Icon(Icons.translate_rounded, size: 18, color: AppColors.blue),
                label: const Text(
                  'Dịch',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
