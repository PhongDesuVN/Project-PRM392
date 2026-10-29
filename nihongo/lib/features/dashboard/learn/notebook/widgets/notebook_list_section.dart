import 'package:flutter/material.dart';
import '../../../../../../shared/ui.dart';
import '../models/notebook_item.dart';
import '../services/notebook_service.dart';
import 'create_notebook_dialog.dart';
import 'notebook_card.dart';

enum NotebookSortType {
  newest('Mới nhất'),
  oldest('Cũ nhất'),
  nameAZ('Tên A - Z'),
  mostWords('Nhiều từ nhất');

  const NotebookSortType(this.label);
  final String label;
}

/// Phần hiển thị "Danh sách sổ tay" khớp với thiết kế trong ảnh
class NotebookListSection extends StatefulWidget {
  const NotebookListSection({
    super.key,
    required this.onReviewNotebook,
    required this.onViewNotebookWords,
  });

  final ValueChanged<NotebookItem> onReviewNotebook;
  final ValueChanged<NotebookItem> onViewNotebookWords;

  @override
  State<NotebookListSection> createState() => _NotebookListSectionState();
}

class _NotebookListSectionState extends State<NotebookListSection> {
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  NotebookSortType _sortType = NotebookSortType.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
      if (!_isSearchOpen) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  Future<void> _createNewNotebook() async {
    final result = await CreateNotebookDialog.show(context);
    if (result != null && mounted) {
      final title = result['title'] ?? '';
      final desc = result['description'] ?? '';
      await NotebookService.instance.createNotebook(title, description: desc);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Đã tạo sổ tay "$title" thành công!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  Future<void> _renameNotebook(NotebookItem item) async {
    final result = await CreateNotebookDialog.show(
      context,
      initialTitle: item.title,
      initialDescription: item.description,
      isEditing: true,
    );
    if (result != null && mounted) {
      final title = result['title'] ?? '';
      final desc = result['description'] ?? '';
      await NotebookService.instance.updateNotebook(item.id, title, description: desc);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Đã cập nhật tên sổ tay thành "$title"!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  Future<void> _confirmDelete(NotebookItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sổ tay "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await NotebookService.instance.deleteNotebook(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Đã xóa sổ tay "${item.title}"'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  List<NotebookItem> _getFilteredAndSortedNotebooks(List<NotebookItem> raw) {
    var list = raw.toList();
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((n) => n.title.toLowerCase().contains(q)).toList();
    }

    switch (_sortType) {
      case NotebookSortType.newest:
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
      case NotebookSortType.oldest:
        list.sort((a, b) => a.id.compareTo(b.id));
        break;
      case NotebookSortType.nameAZ:
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case NotebookSortType.mostWords:
        list.sort((a, b) => b.wordCount.compareTo(a.wordCount));
        break;
    }
    return list;
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: 20, color: const Color(0xFF4A5568)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NotebookService.instance,
      builder: (context, _) {
        final service = NotebookService.instance;
        final displayedList = _getFilteredAndSortedNotebooks(service.notebooks);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề: Danh sách sổ tay + Reload icon + 3 nút thao tác góc phải
            Row(
              children: [
                const Text(
                  'Danh sách sổ tay',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E242B),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => service.fetchNotebooks(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: service.isLoadingNotebooks
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.refresh_rounded,
                            size: 20,
                            color: Color(0xFF718096),
                          ),
                  ),
                ),
                const Spacer(),

                // Nút tìm kiếm
                _buildIconButton(
                  icon: _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
                  onTap: _toggleSearch,
                  tooltip: 'Tìm kiếm sổ tay',
                ),
                const SizedBox(width: 8),

                // Nút thêm mới sổ tay (+)
                _buildIconButton(
                  icon: Icons.add_rounded,
                  onTap: _createNewNotebook,
                  tooltip: 'Tạo sổ tay mới',
                ),
                const SizedBox(width: 8),

                // Nút lọc / sắp xếp
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: PopupMenuButton<NotebookSortType>(
                    icon: const Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: Color(0xFF4A5568),
                    ),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (val) => setState(() => _sortType = val),
                    itemBuilder: (context) => [
                      for (final sort in NotebookSortType.values)
                        PopupMenuItem(
                          value: sort,
                          child: Row(
                            children: [
                              if (_sortType == sort)
                                const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.blue,
                                  size: 18,
                                )
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 8),
                              Text(sort.label),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Thanh tìm kiếm mở rộng nếu bấm nút search
            if (_isSearchOpen) ...[
              Container(
                height: 42,
                margin: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sổ tay...',
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    filled: true,
                    fillColor: const Color(0xFFF1F3F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ],

            // Danh sách các thẻ sổ tay
            if (displayedList.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.collections_bookmark_outlined,
                      size: 40,
                      color: Color(0xFFA0AEC0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Không tìm thấy sổ tay khớp với "$_searchQuery"'
                          : 'Chưa có sổ tay nào. Hãy tạo sổ tay đầu tiên!',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _createNewNotebook,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tạo sổ tay mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              for (final item in displayedList)
                NotebookCard(
                  key: ValueKey('notebook_${item.id}'),
                  notebook: item,
                  isSelected: service.selectedNotebook?.id == item.id,
                  onTap: () {
                    // Chuyển đổi chọn sổ tay
                    if (service.selectedNotebook?.id == item.id) {
                      service.selectNotebook(null);
                    } else {
                      service.selectNotebook(item);
                    }
                  },
                  onReview: () => widget.onReviewNotebook(item),
                  onViewWords: () => widget.onViewNotebookWords(item),
                  onRename: () => _renameNotebook(item),
                  onDelete: () => _confirmDelete(item),
                ),
            ],
          ],
        );
      },
    );
  }
}

