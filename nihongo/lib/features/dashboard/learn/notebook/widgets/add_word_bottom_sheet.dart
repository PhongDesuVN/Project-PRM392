import 'package:flutter/material.dart';

import '../../../../../../shared/ui.dart';

/// Modal bottom sheet thêm từ mới vào sổ tay khớp với thiết kế trong ảnh
class AddWordBottomSheet extends StatefulWidget {
  const AddWordBottomSheet({
    super.key,
    required this.notebookTitle,
    required this.onSubmit,
  });

  final String notebookTitle;
  final Future<bool> Function({
    required String word,
    required String reading,
    required String meaning,
    required String wordType,
  }) onSubmit;

  static Future<bool?> show({
    required BuildContext context,
    required String notebookTitle,
    required Future<bool> Function({
      required String word,
      required String reading,
      required String meaning,
      required String wordType,
    }) onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddWordBottomSheet(
        notebookTitle: notebookTitle,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<AddWordBottomSheet> createState() => _AddWordBottomSheetState();
}

class _AddWordBottomSheetState extends State<AddWordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _readingController = TextEditingController();
  final _meaningController = TextEditingController();

  String _selectedWordType = 'Từ vựng';
  final List<String> _wordTypes = ['Từ vựng', 'Ngữ pháp', 'Kanji'];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _wordController.dispose();
    _readingController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final success = await widget.onSubmit(
      word: _wordController.text.trim(),
      reading: _readingController.text.trim(),
      meaning: _meaningController.text.trim(),
      wordType: _selectedWordType,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh kéo drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tiêu đề
              const Center(
                child: Text(
                  'Thêm từ mới',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E242B),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Trường "Từ vựng *"
              _buildFieldLabel('Từ vựng *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _wordController,
                autofocus: true,
                decoration: _buildInputDecoration(hint: 'Ví dụ: 食べる, 日本, こんにちは'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập từ vựng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Trường "Phiên âm"
              _buildFieldLabel('Phiên âm'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _readingController,
                decoration: _buildInputDecoration(hint: 'Ví dụ: たべる, にほん'),
              ),
              const SizedBox(height: 14),

              // Trường "Nghĩa *"
              _buildFieldLabel('Nghĩa *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _meaningController,
                decoration: _buildInputDecoration(hint: 'Ví dụ: Ăn, Nhật Bản'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập nghĩa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Trường "Loại từ *"
              _buildFieldLabel('Loại từ *'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedWordType,
                decoration: _buildInputDecoration(),
                items: _wordTypes.map((t) {
                  return DropdownMenuItem<String>(
                    value: t,
                    child: Text(t),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedWordType = val);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Hàng nút Huỷ & Thêm
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Huỷ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Thêm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    final isRequired = label.contains('*');
    final text = label.replaceAll('*', '').trim();
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
        children: [
          TextSpan(text: text),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
      ),
    );
  }
}
