import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/ui.dart';
import '../dashboard/learn/notebook/services/notebook_service.dart';
import 'models/ocr_dictionary_entry.dart';
import 'models/ocr_scan_result.dart';
import 'services/ai_vision_extractor_service.dart';
import 'services/camera_ocr_service.dart';
import 'widgets/ocr_action_bar.dart';
import 'widgets/ocr_dictionary_card.dart';
import 'widgets/ocr_image_preview.dart';
import 'widgets/ocr_result_card.dart';

/// Kết quả trả về cho màn hình gọi Camera OCR
class CameraOcrResultData {
  const CameraOcrResultData({
    required this.query,
    this.targetAction = 'dictionary',
  });

  final String query;
  final String targetAction; // 'dictionary' hoặc 'translate'
}

/// Màn hình chụp ảnh và nhận diện văn bản tiếng Nhật bằng mô hình AI On-Device / Multimodal Vision LLM
class CameraOcrPage extends StatefulWidget {
  const CameraOcrPage({
    super.key,
    this.autoLaunchCamera = true,
  });

  final bool autoLaunchCamera;

  @override
  State<CameraOcrPage> createState() => _CameraOcrPageState();
}

class _CameraOcrPageState extends State<CameraOcrPage>
    with SingleTickerProviderStateMixin {
  final CameraOcrService _ocrService = CameraOcrService();
  late final AiVisionExtractorService _aiExtractor = AiVisionExtractorService(
    ocrService: _ocrService,
  );
  final TextEditingController _textController = TextEditingController();

  OcrScanResult? _scanResult;
  List<OcrDictionaryEntry> _dictionaryEntries = const [];
  String? _selectedWord;
  bool _isProcessing = false;
  String? _errorMessage;
  int _activeTabIndex = 0; // 0: Thẻ từ điển AI, 1: Văn bản gốc OCR

  @override
  void initState() {
    super.initState();
    if (widget.autoLaunchCamera) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _capturePhoto();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _aiExtractor.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  /// Mở camera để chụp ảnh và quét chữ
  Future<void> _capturePhoto() async {
    final imagePath = await _ocrService.capturePhoto();
    if (imagePath != null) {
      await _processImage(imagePath);
    }
  }

  /// Chọn ảnh từ thư viện
  Future<void> _pickFromGallery() async {
    final imagePath = await _ocrService.pickImageFromGallery();
    if (imagePath != null) {
      await _processImage(imagePath);
    }
  }

  /// Xử lý nhận dạng chữ và trích xuất ngữ nghĩa qua AI
  Future<void> _processImage(String imagePath) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _selectedWord = null;
      _dictionaryEntries = const [];
    });

    try {
      // 1. Quét văn bản từ Camera (On-Device Vision)
      final rawResult = await _ocrService.recognizeTextFromImage(imagePath);

      // 2. Trích xuất và cấu trúc hóa từ điển qua AI (Strict JSON Output + Enrichment)
      final entries = await _aiExtractor.extractDictionaryEntries(
        imagePath: imagePath,
      );

      if (!mounted) return;

      setState(() {
        _scanResult = rawResult;
        _dictionaryEntries = entries;
        _textController.text = rawResult.fullText;

        if (entries.isNotEmpty) {
          _selectedWord = entries.first.entryWord;
          _activeTabIndex = 0; // Mặc định mở tab Từ điển AI
        } else if (rawResult.detectedWords.isNotEmpty) {
          _selectedWord = rawResult.detectedWords.first.text;
          _activeTabIndex = 1;
        } else {
          _selectedWord = rawResult.fullText.trim();
          _activeTabIndex = 1;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể nhận diện văn bản. Vui lòng thử lại!';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _onSelectWord(String word) {
    setState(() {
      _selectedWord = word;
      _textController.text = word;
    });
  }

  void _copyToClipboard() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép vào bộ nhớ tạm'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onSearchDictionary([String? customWord]) {
    final query = customWord ??
        (_selectedWord?.isNotEmpty == true
            ? _selectedWord!
            : _textController.text.trim());
    if (query.isEmpty) return;

    Navigator.pop(
      context,
      CameraOcrResultData(query: query, targetAction: 'dictionary'),
    );
  }

  void _onTranslate() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    Navigator.pop(
      context,
      CameraOcrResultData(query: text, targetAction: 'translate'),
    );
  }

  /// Lưu từ vựng bóc tách được vào Sổ tay người dùng
  Future<void> _saveEntryToNotebook(OcrDictionaryEntry entry) async {
    final notebooks = NotebookService.instance.notebooks;
    if (notebooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa có danh sách sổ tay nào.')),
      );
      return;
    }

    final targetNotebook = notebooks.first;
    final meaningText = entry.definitions.isNotEmpty
        ? entry.definitions.join('; ')
        : entry.entryWord;

    final saved = await NotebookService.instance.addWordToNotebook(
      targetNotebook.id,
      word: entry.entryWord,
      reading: entry.reading,
      meaning: meaningText,
      romaji: entry.romaji,
      wordType: entry.partOfSpeech.isNotEmpty ? entry.partOfSpeech : 'Từ vựng',
    );

    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã lưu "${entry.entryWord}" vào "${targetNotebook.title}"!'),
          backgroundColor: const Color(0xFF00B894),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = _textController.text.trim().isNotEmpty ||
        _dictionaryEntries.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Nihon AI Camera',
          style: TextStyle(
            color: Color(0xFF1E242B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1E242B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.key_rounded, size: 20),
            tooltip: 'Cấu hình Gemini API Key',
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _scanResult != null && !_isProcessing
          ? OcrActionBar(
              hasContent: hasContent,
              onSearchDictionary: () => _onSearchDictionary(),
              onTranslate: _onTranslate,
              onCopy: _copyToClipboard,
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isProcessing) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.blue),
              const SizedBox(height: 20),
              const Text(
                'Mô hình AI đang quét văn bản tiếng Nhật...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E242B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Nhận diện chữ & bố cục cột\n'
                '2. Sửa lỗi mờ nét & lọc bỏ rác thị giác\n'
                '3. Cấu trúc hóa từ vựng & tầng nghĩa (Strict JSON)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_scanResult == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Xem trước ảnh chụp
          OcrImagePreview(
            imagePath: _scanResult!.imagePath,
            onRetake: _capturePhoto,
            onPickGallery: _pickFromGallery,
          ),
          const SizedBox(height: 16),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

          // Thanh chuyển Tab giữa "Từ điển AI trích xuất" và "Văn bản gốc"
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTabIndex = 0),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _activeTabIndex == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeTabIndex == 0
                            ? const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: _activeTabIndex == 0 ? AppColors.blue : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Từ điển AI (${_dictionaryEntries.length})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _activeTabIndex == 0 ? FontWeight.bold : FontWeight.w600,
                              color: _activeTabIndex == 0 ? AppColors.blue : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTabIndex = 1),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _activeTabIndex == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeTabIndex == 1
                            ? const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 16,
                            color: _activeTabIndex == 1 ? AppColors.blue : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Văn bản thô (OCR)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _activeTabIndex == 1 ? FontWeight.bold : FontWeight.w600,
                              color: _activeTabIndex == 1 ? AppColors.blue : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Nội dung tab tương ứng
          if (_activeTabIndex == 0) ...[
            if (_dictionaryEntries.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 40, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      'Chưa trích xuất được mục từ điển hoàn chỉnh.\nVui lòng bấm qua tab "Văn bản thô (OCR)" để xem nội dung quét được.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              ..._dictionaryEntries.map((entry) {
                return OcrDictionaryCard(
                  entry: entry,
                  onSearchDetail: () => _onSearchDictionary(entry.entryWord),
                  onSaveToNotebook: () => _saveEntryToNotebook(entry),
                );
              }),
          ] else ...[
            OcrResultCard(
              scanResult: _scanResult!,
              textController: _textController,
              selectedWord: _selectedWord,
              onSelectWord: _onSelectWord,
              onCopyText: _copyToClipboard,
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 56,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nihon AI Camera',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E242B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tự động bóc tách từ khóa chính, phiên âm, từ loại, các tầng nghĩa tiếng Việt và câu ví dụ từ trang sách hoặc từ điển.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.5, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text(
                'Mở máy ảnh chụp ngay',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E242B),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text(
                'Chọn ảnh từ thư viện',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApiKeyDialog() async {
    final currentKey = await _aiExtractor.getCustomApiKey() ?? '';
    final controller = TextEditingController(text: currentKey);

    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.blue),
            SizedBox(width: 8),
            Text(
              'Cấu hình Gemini Vision LLM',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập Google Gemini API Key để kích hoạt tính năng Multimodal Vision trích xuất Strict JSON nâng cao (hoặc để trống để sử dụng On-Device AI mặc định):',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await _aiExtractor.saveCustomApiKey(controller.text.trim());
              if (!ctx.mounted || !mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã lưu cấu hình AI Key!')),
              );
            },
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
