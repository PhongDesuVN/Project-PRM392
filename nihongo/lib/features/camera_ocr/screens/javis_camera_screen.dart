import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/ui.dart';
import '../../dashboard/dictionary/dictionary_tab.dart';
import '../../dashboard/learn/notebook/models/notebook_item.dart';
import '../../dashboard/learn/notebook/services/notebook_service.dart';
import '../../dashboard/translation/translation_tab.dart';
import '../models/japanese_analysis_model.dart';
import '../services/javis_ai_service.dart';

/// Kết quả trả về khi kết thúc màn hình Javis AI
class CameraOcrResultData {
  const CameraOcrResultData({
    required this.query,
    this.targetAction = 'dictionary',
  });

  final String query;
  final String targetAction;
}

/// Màn hình Javis AI - Trợ Lý Tiếng Nhật & Phân tích Đề thi JLPT
class JavisCameraScreen extends StatefulWidget {
  const JavisCameraScreen({
    super.key,
    this.autoLaunchCamera = false,
    this.onAddToNotebook,
    this.onSearchKeyword,
  });

  final bool autoLaunchCamera;

  /// Callback mở rộng khi bấm nút "Thêm vào sổ tay"
  final void Function(String title, String meaning)? onAddToNotebook;

  /// Callback mở rộng khi bấm nút "Tìm kiếm"
  final void Function(String keyword)? onSearchKeyword;

  @override
  State<JavisCameraScreen> createState() => _JavisCameraScreenState();
}

class _JavisCameraScreenState extends State<JavisCameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final JavisAiService _aiService = JavisAiService.instance;

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isLoading = false;
  String? _errorMessage;
  AnalysisResult? _analysisResult;

  @override
  void initState() {
    super.initState();
    // Tải sẵn danh sách sổ tay người dùng
    NotebookService.instance.fetchNotebooks();

    if (widget.autoLaunchCamera) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickAndAnalyze(ImageSource.camera);
      });
    }
  }

  /// Xác định MIME Type chuẩn từ tên file
  String _resolveMimeType(String path, String? reportedMime) {
    if (reportedMime != null && reportedMime.isNotEmpty) return reportedMime;
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  /// Chọn ảnh từ Camera hoặc Gallery và gọi Javis AI phân tích
  Future<void> _pickAndAnalyze(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Nén ảnh 80% theo yêu cầu
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();
      final mimeType = _resolveMimeType(file.path, file.mimeType);

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = file.name;
        _isLoading = true;
        _errorMessage = null;
        _analysisResult = null;
      });

      // Gọi Gemini API trực tiếp qua JavisAiService (100% Frontend)
      final result = await _aiService.analyzeJapaneseImage(bytes, mimeType);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _analysisResult = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _errorMessage ?? 'Đã xảy ra lỗi khi phân tích ảnh.',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // =========================================================================
  // YÊU CẦU 1: HIỂN THỊ CHỌN SỔ TAY KHI BẤM NÚT "THÊM VÀO SỔ TAY"
  // =========================================================================
  void _handleAddToNotebook({
    required String title,
    required String meaning,
    String? romaji,
    String? type,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final notebooks = NotebookService.instance.notebooks;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bookmark_add,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thêm vào Sổ tay ghi nhớ',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Chọn sổ tay để lưu "$title"',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.muted, size: 20),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.borderLight),
                    const SizedBox(height: 12),

                    // Nút tạo sổ tay mới
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        Navigator.pop(sheetCtx);
                        final newNotebookName = await _showCreateNotebookDialog();
                        if (!mounted || newNotebookName == null || newNotebookName.trim().isEmpty) {
                          return;
                        }
                        final created = await NotebookService.instance.createNotebook(newNotebookName.trim());
                        if (created != null && mounted) {
                          await _saveWordToSpecificNotebook(
                            notebook: created,
                            title: title,
                            meaning: meaning,
                            romaji: romaji,
                            type: type,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add_circle, color: AppColors.primary, size: 22),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tạo sổ tay mới',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  Text(
                                    'Tạo một danh mục sổ tay mới và lưu mục này',
                                    style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Sổ tay của bạn',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Danh sách sổ tay hiện có
                    Flexible(
                      child: notebooks.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.menu_book_outlined,
                                      size: 38,
                                      color: AppColors.muted.withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Bạn chưa có sổ tay nào.',
                                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Bấm "Tạo sổ tay mới" ở trên để lưu mục đầu tiên nhé!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: notebooks.length,
                              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
                              itemBuilder: (ctx, index) {
                                final nb = notebooks[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  leading: Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: AppColors.canvas,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.borderLight),
                                    ),
                                    child: const Icon(
                                      Icons.book_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    nb.title,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${nb.wordCount} mục ghi nhớ',
                                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Chọn',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if (Navigator.canPop(sheetCtx)) {
                                      Navigator.pop(sheetCtx);
                                    }
                                    _saveWordToSpecificNotebook(
                                      notebook: nb,
                                      title: title,
                                      meaning: meaning,
                                      romaji: romaji,
                                      type: type,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Thực hiện lưu từ vào sổ tay đã chọn
  Future<void> _saveWordToSpecificNotebook({
    required NotebookItem notebook,
    required String title,
    required String meaning,
    String? romaji,
    String? type,
  }) async {
    // 1. Kích hoạt callback nếu có
    if (widget.onAddToNotebook != null) {
      widget.onAddToNotebook!(title, meaning);
    }

    // 2. Lưu vào NotebookService
    try {
      await NotebookService.instance.addWordToNotebook(
        notebook.id,
        word: title,
        reading: title,
        meaning: meaning,
        romaji: romaji,
        wordType: type ?? 'Javis AI',
      );
    } catch (_) {}

    if (!mounted) return;

    // 3. Hiển thị thông báo
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bookmark_added, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã thêm $title vào sổ tay "${notebook.title}"',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Dialog nhập tên để tạo sổ tay mới nhanh
  Future<String?> _showCreateNotebookDialog() async {
    final textController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.create_new_folder_outlined, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              'Tạo sổ tay mới',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Ví dụ: Từ vựng N5 Javis, Ngữ pháp bài 1...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.placeholder),
            filled: true,
            fillColor: AppColors.canvas,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, null),
            child: const Text('Hủy', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(dialogCtx, text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tạo và Lưu'),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // YÊU CẦU 2: TRA CỨU TỪ ĐIỂN & DỊCH VĂN BẢN VỚI NÚT QUAY VỀ JAVIS AI
  // =========================================================================

  /// Mở Từ điển dạng trang mới có nút Trở về (←) góc trái quay về Javis AI
  void _openDictionaryWithBackButton(String keyword) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.ink, size: 20),
              tooltip: 'Quay lại Javis AI',
              onPressed: () => Navigator.pop(ctx),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.menu_book, color: AppColors.accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Từ điển tiếng Nhật',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Từ khóa: $keyword',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: DictionaryTab(
            initialQuery: keyword,
            onCameraSearch: () => Navigator.pop(ctx),
            onHandwritingSearch: () {},
          ),
        ),
      ),
    );
  }

  /// Mở Bộ dịch dạng trang mới có nút Trở về (←) góc trái quay về Javis AI
  void _openTranslationWithBackButton(String text) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.ink, size: 20),
              tooltip: 'Quay lại Javis AI',
              onPressed: () => Navigator.pop(ctx),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.translate, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Bộ dịch tiếng Nhật',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'Văn bản: $text',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TranslationTab(
            initialText: text,
          ),
        ),
      ),
    );
  }

  /// Xử lý bấm nút "Tìm kiếm" -> Mở Modal Bottom Sheet chi tiết
  void _handleSearchKeyword(String keyword, {String? meaning, String? level}) {
    if (widget.onSearchKeyword != null) {
      widget.onSearchKeyword!(keyword);
    }

    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _buildSearchDetailBottomSheet(
        sheetContext: sheetContext,
        keyword: trimmed,
        meaning: meaning,
        level: level,
      ),
    );
  }

  /// Modal Bottom Sheet hiển thị thông tin tra cứu và thao tác nhanh
  Widget _buildSearchDetailBottomSheet({
    required BuildContext sheetContext,
    required String keyword,
    String? meaning,
    String? level,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        keyword,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      if (level != null && level.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        _buildLevelBadge(level),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            if (meaning != null && meaning.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  meaning,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkText,
                    height: 1.4,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Text(
              'Thao tác tra cứu nhanh',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 10),

            // Tùy chọn 1: Tra cứu trong Từ điển (Có nút trở về Javis AI)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_book, color: AppColors.accent, size: 20),
              ),
              title: const Text(
                'Tra cứu trong Từ điển',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Xem Kanji, ví dụ câu (kèm nút quay lại Javis AI)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
              onTap: () {
                Navigator.pop(sheetContext);
                _openDictionaryWithBackButton(keyword);
              },
            ),

            // Tùy chọn 2: Dịch câu trong Bộ dịch (Có nút trở về Javis AI)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.translate, color: AppColors.primary, size: 20),
              ),
              title: const Text(
                'Chuyển sang Bộ dịch',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Dịch chi tiết với ngữ cảnh (kèm nút quay lại Javis AI)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.muted),
              onTap: () {
                Navigator.pop(sheetContext);
                _openTranslationWithBackButton(keyword);
              },
            ),

            // Tùy chọn 3: Sao chép từ khóa
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.copy, color: AppColors.darkText, size: 20),
              ),
              title: const Text(
                'Sao chép từ khóa',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: keyword));
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã sao chép "$keyword" vào bộ nhớ tạm'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Màu sắc huy hiệu JLPT
  Color _getLevelColor(String level) {
    final up = level.toUpperCase();
    if (up.contains('N1')) return const Color(0xFF7C3AED);
    if (up.contains('N2')) return const Color(0xFF2563EB);
    if (up.contains('N3')) return const Color(0xFF0D9488);
    if (up.contains('N4')) return const Color(0xFF16A34A);
    if (up.contains('N5')) return const Color(0xFFD97706);
    return AppColors.primary;
  }

  Widget _buildLevelBadge(String level) {
    if (level.trim().isEmpty) return const SizedBox.shrink();
    final color = _getLevelColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.ink, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Javis AI - Trợ Lý Tiếng Nhật',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  'Powered by Gemini Flash • JLPT Expert',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Thanh tác vụ chọn ảnh luôn sẵn sàng ở trên cùng
          _buildTopActionBar(),

          // Nội dung cuộn chính
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _analysisResult != null
                        ? _buildResultContent(_analysisResult!)
                        : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  /// Thanh thao tác nhanh Chụp ảnh & Chọn từ Gallery
  Widget _buildTopActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          // Nút Chụp ảnh (Camera)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _pickAndAnalyze(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text(
                'Chụp ảnh',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nút Chọn ảnh (Gallery)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () => _pickAndAnalyze(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text(
                'Thư viện ảnh',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Trạng thái đang tải sinh động
  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    backgroundColor: AppColors.primarySoft,
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Javis AI đang phân tích ngữ pháp & từ vựng...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Đang bóc tách văn bản OCR, tra cứu cấp độ JLPT và câu ví dụ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Trạng thái lỗi với gợi ý khắc phục
  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.errorSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không thể phân tích ảnh',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Ảnh mờ hoặc không nhận diện được văn bản tiếng Nhật.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _pickAndAnalyze(ImageSource.camera),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Chụp lại ảnh khác'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Trạng thái chào mừng khi chưa chọn ảnh
  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.document_scanner_outlined,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Khám phá tiếng Nhật với Javis AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chụp tài liệu, sách giáo khoa Minna, bài đọc hoặc đề thi JLPT. '
            'Javis AI sẽ giải mã toàn diện cho bạn trong chớp mắt.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 32),

          _buildFeatureTip(
            icon: Icons.translate,
            title: 'Dịch song ngữ thông minh',
            subtitle: 'Dịch chuẩn xác Nhật - Việt theo ngữ cảnh tự nhiên.',
          ),
          const SizedBox(height: 12),
          _buildFeatureTip(
            icon: Icons.menu_book,
            title: 'Bóc tách cấu trúc Ngữ pháp',
            subtitle: 'Phân loại cấp độ JLPT N5 đến N1 kèm câu ví dụ áp dụng.',
          ),
          const SizedBox(height: 12),
          _buildFeatureTip(
            icon: Icons.bookmark_border,
            title: 'Lưu từ vựng linh hoạt',
            subtitle: 'Lựa chọn lưu vào bất kỳ sổ tay nào hoặc tạo mới chỉ trong 1 chạm.',
          ),

          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _pickAndAnalyze(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                'Bắt đầu Chụp ảnh ngay',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTip({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Giao diện kết quả dạng thẻ cuộn (Scrollable Cards)
  Widget _buildResultContent(AnalysisResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedImageBytes != null) _buildImageThumbnail(),
          _buildCard1Translation(result),
          const SizedBox(height: 16),
          _buildCard2Grammar(result),
          const SizedBox(height: 16),
          _buildCard3Vocabulary(result),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Thumbnail ảnh thu gọn với tên file
  Widget _buildImageThumbnail() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              _selectedImageBytes!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hình ảnh phân tích',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  _selectedImageName ?? 'Ảnh chụp gần nhất',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _pickAndAnalyze(ImageSource.camera),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Đổi ảnh', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // CARD 1: BẢN DỊCH TOÀN VĂN
  // =========================================================================
  Widget _buildCard1Translation(AnalysisResult result) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.translate,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Bản dịch toàn văn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result.detectedLanguage.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 14),

          // Văn bản gốc (OCR)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Văn bản gốc (OCR)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.copy, size: 16, color: AppColors.muted),
                    tooltip: 'Sao chép văn bản gốc',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result.originalText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã sao chép văn bản gốc'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => _openTranslationWithBackButton(result.originalText),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.translate, size: 12, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'Dịch',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            result.originalText.isNotEmpty
                ? result.originalText
                : '(Không trích xuất được văn bản)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 14),

          // Bản dịch tiếng Việt
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bản dịch tiếng Việt',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.copy, size: 16, color: AppColors.muted),
                tooltip: 'Sao chép bản dịch',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result.fullTranslation));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã sao chép bản dịch'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            result.fullTranslation.isNotEmpty
                ? result.fullTranslation
                : '(Chưa có bản dịch)',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E3A8A),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // CARD 2: DANH SÁCH CẤU TRÚC NGỮ PHÁP (KÈM 2 NÚT THAO TÁC)
  // =========================================================================
  Widget _buildCard2Grammar(AnalysisResult result) {
    final list = result.grammarList;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Cấu trúc Ngữ pháp',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${list.length} điểm',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Không tìm thấy cấu trúc ngữ pháp đặc biệt.',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (ctx, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppColors.borderLight),
              ),
              itemBuilder: (context, index) {
                final item = list[index];
                return _buildGrammarItem(item);
              },
            ),
        ],
      ),
    );
  }

  /// Từng item Cấu trúc ngữ pháp kèm 2 nút Thao tác bắt buộc
  Widget _buildGrammarItem(GrammarPoint item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.structure,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      if (item.level.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildLevelBadge(item.level),
                      ],
                    ],
                  ),
                  if (item.romaji.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.romaji,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 2 NÚT THAO TÁC BẮT BUỘC CHO NGỮ PHÁP
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Nút "Thêm vào sổ tay" -> Hiện danh sách chọn sổ tay
                Tooltip(
                  message: 'Thêm vào sổ tay ghi nhớ',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _handleAddToNotebook(
                        title: item.structure,
                        meaning: item.meaning,
                        romaji: item.romaji,
                        type: 'Ngữ pháp ${item.level}',
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.bookmark_add_outlined,
                          size: 19,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // 2. Nút "Tìm kiếm" -> Mở Bottom sheet chi tiết (có nút trở về Javis AI)
                Tooltip(
                  message: 'Tìm kiếm chi tiết',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _handleSearchKeyword(
                        item.structure,
                        meaning: item.meaning,
                        level: item.level,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.search,
                          size: 19,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          item.meaning,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
            height: 1.4,
          ),
        ),

        if (item.exampleJa.isNotEmpty || item.exampleVi.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.exampleJa.isNotEmpty)
                  Text(
                    item.exampleJa,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                if (item.exampleVi.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.exampleVi,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  // =========================================================================
  // CARD 3: DANH SÁCH TỪ VỰNG QUAN TRỌNG (KÈM 2 NÚT THAO TÁC)
  // =========================================================================
  Widget _buildCard3Vocabulary(AnalysisResult result) {
    final list = result.vocabularyList;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.text_fields_outlined,
                  color: AppColors.gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Từ vựng quan trọng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${list.length} từ',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Không có từ vựng quan trọng nào được bóc tách.',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (ctx, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppColors.borderLight),
              ),
              itemBuilder: (context, index) {
                final item = list[index];
                return _buildVocabularyItem(item);
              },
            ),
        ],
      ),
    );
  }

  /// Từng item Từ vựng kèm 2 nút Thao tác bắt buộc
  Widget _buildVocabularyItem(VocabularyItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.word,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      if (item.level.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildLevelBadge(item.level),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      if (item.romaji.isNotEmpty)
                        Text(
                          item.romaji,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.muted,
                          ),
                        ),
                      if (item.romaji.isNotEmpty && item.partOfSpeech.isNotEmpty)
                        const Text(
                          ' • ',
                          style: TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      if (item.partOfSpeech.isNotEmpty)
                        Flexible(
                          child: Text(
                            item.partOfSpeech,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 2 NÚT THAO TÁC BẮT BUỘC CHO TỪ VỰNG
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Nút "Thêm vào sổ tay" -> Hiện danh sách chọn sổ tay
                Tooltip(
                  message: 'Thêm vào sổ tay ghi nhớ',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _handleAddToNotebook(
                        title: item.word,
                        meaning: item.meaning,
                        romaji: item.romaji,
                        type: item.partOfSpeech,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.bookmark_add_outlined,
                          size: 19,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // 2. Nút "Tìm kiếm" -> Mở Bottom sheet chi tiết (có nút trở về Javis AI)
                Tooltip(
                  message: 'Tìm kiếm chi tiết',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _handleSearchKeyword(
                        item.word,
                        meaning: item.meaning,
                        level: item.level,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.search,
                          size: 19,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          item.meaning,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
            height: 1.4,
          ),
        ),

        if (item.exampleJa.isNotEmpty || item.exampleVi.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.exampleJa.isNotEmpty)
                  Text(
                    item.exampleJa,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                if (item.exampleVi.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.exampleVi,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
