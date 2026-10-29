import 'package:flutter/material.dart';
import '../../../../../../shared/ui.dart';

/// Hộp thoại tạo hoặc đổi tên sổ tay
class CreateNotebookDialog extends StatefulWidget {
  const CreateNotebookDialog({
    super.key,
    this.initialTitle = '',
    this.initialDescription = '',
    this.isEditing = false,
  });

  final String initialTitle;
  final String initialDescription;
  final bool isEditing;

  static Future<Map<String, String>?> show(
    BuildContext context, {
    String initialTitle = '',
    String initialDescription = '',
    bool isEditing = false,
  }) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => CreateNotebookDialog(
        initialTitle: initialTitle,
        initialDescription: initialDescription,
        isEditing: isEditing,
      ),
    );
  }

  @override
  State<CreateNotebookDialog> createState() => _CreateNotebookDialogState();
}

class _CreateNotebookDialogState extends State<CreateNotebookDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = 'Vui lòng nhập tên sổ tay');
      return;
    }
    Navigator.of(context).pop({
      'title': title,
      'description': _descController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing ? 'Đổi tên sổ tay' : 'Tạo sổ tay mới',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E242B),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Tên sổ tay',
                hintText: 'Ví dụ: Từ vựng N5, Kanji cơ bản...',
                errorText: _errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(widget.isEditing ? 'Lưu' : 'Tạo sổ tay'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

