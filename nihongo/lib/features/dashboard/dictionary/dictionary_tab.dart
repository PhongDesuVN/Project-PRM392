import 'package:flutter/material.dart';

import '../../../shared/ui.dart';
import '../shared/dashboard_tool_widgets.dart';

class DictionaryTab extends StatefulWidget {
  const DictionaryTab({
    super.key,
    required this.initialQuery,
    required this.onCameraSearch,
    required this.onHandwritingSearch,
  });

  final String initialQuery;
  final VoidCallback onCameraSearch;
  final VoidCallback onHandwritingSearch;

  @override
  State<DictionaryTab> createState() => _DictionaryTabState();
}

class _DictionaryTabState extends State<DictionaryTab> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _showSearchMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Nguồn dữ liệu từ điển sẽ được kết nối trong bước tiếp theo.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: [
        const DashboardToolHeading(
          eyebrow: 'TRA CỨU',
          title: 'Từ điển Nhật - Việt',
          subtitle: 'Tìm từ vựng và cách đọc nhanh chóng.',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _queryController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _showSearchMessage(),
          decoration: InputDecoration(
            hintText: 'Nhập từ tiếng Nhật hoặc tiếng Việt',
            prefixIcon: const Icon(Icons.search, color: AppColors.blue),
            suffixIcon: IconButton(
              tooltip: 'Tra từ',
              onPressed: _showSearchMessage,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DictionaryAction(
                icon: Icons.camera_alt_outlined,
                label: 'Chụp ảnh',
                onTap: widget.onCameraSearch,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DictionaryAction(
                icon: Icons.gesture_rounded,
                label: 'Viết Kanji',
                onTap: widget.onHandwritingSearch,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          'Tra cứu tiếng Nhật',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        const DashboardEmptyState(
          icon: Icons.menu_book_outlined,
          title: 'Sẵn sàng tra cứu',
          message: 'Nhập từ ở phía trên hoặc dùng ảnh và nét viết để tìm Kanji.',
        ),
      ],
    );
  }
}

class _DictionaryAction extends StatelessWidget {
  const _DictionaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkText,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
    );
  }
}