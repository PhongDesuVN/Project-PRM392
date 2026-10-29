import 'package:flutter/material.dart';
import '../../../../../../shared/ui.dart';
import '../models/notebook_item.dart';

/// Thẻ hiển thị một sổ tay trong "Danh sách sổ tay"
class NotebookCard extends StatelessWidget {
  const NotebookCard({
    super.key,
    required this.notebook,
    this.isSelected = false,
    this.onTap,
    this.onReview,
    this.onViewWords,
    this.onRename,
    this.onDelete,
  });

  final NotebookItem notebook;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onReview;
  final VoidCallback? onViewWords;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.blue : const Color(0xFFE5E9F0),
          width: isSelected ? 1.8 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng trên: Biểu tượng sổ tay + Tiêu đề + Menu 3 chấm
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.collections_bookmark_rounded,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notebook.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E242B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Color(0xFF718096),
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'review':
                            onReview?.call();
                            break;
                          case 'words':
                            onViewWords?.call();
                            break;
                          case 'rename':
                            onRename?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'review',
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline_rounded,
                                color: AppColors.blue,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Text('Ôn tập sổ tay này'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'words',
                          child: Row(
                            children: [
                              Icon(
                                Icons.format_list_bulleted_rounded,
                                color: Color(0xFF4A5568),
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Text('Xem danh sách từ'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: Color(0xFF4A5568),
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Text('Đổi tên'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Xóa sổ tay',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Hàng dưới: Số lượng từ & Ngày tạo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${notebook.wordCount} từ',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5F6368),
                      ),
                    ),
                    Text(
                      notebook.createdAt,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5F6368),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

