import 'package:flutter/material.dart';

import '../models/alphabet_models.dart';
import 'alphabet_cell.dart';

/// Widget hiển thị lưới ký tự cho một Section (Gojuuon, Dakuon & Handakuon, Youon)
class AlphabetSectionView extends StatelessWidget {
  const AlphabetSectionView({
    super.key,
    required this.section,
    this.onCharacterTap,
  });

  final AlphabetSection section;
  final ValueChanged<AlphabetItem>? onCharacterTap;

  @override
  Widget build(BuildContext context) {
    final rows = section.grid;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: rows.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, rowIndex) {
        final rowItems = rows[rowIndex];

        return SizedBox(
          height: 64,
          child: Row(
            children: [
              for (int colIndex = 0; colIndex < rowItems.length; colIndex++) ...[
                if (colIndex > 0) const SizedBox(width: 8),
                Expanded(
                  child: AlphabetCell(
                    item: rowItems[colIndex],
                    onTap: rowItems[colIndex] != null
                        ? () => onCharacterTap?.call(rowItems[colIndex]!)
                        : null,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
