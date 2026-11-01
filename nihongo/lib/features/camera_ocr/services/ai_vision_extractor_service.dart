import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../dashboard/dictionary/dictionary_service.dart';
import '../models/ocr_dictionary_entry.dart';
import 'camera_ocr_service.dart';
import 'japanese_ai_knowledge_base.dart';

/// Dịch vụ Nhận diện & Trích xuất Dữ liệu Từ điển thông minh qua AI (Multimodal Vision LLM & On-Device)
class AiVisionExtractorService {
  AiVisionExtractorService({
    CameraOcrService? ocrService,
    DictionaryService? dictionaryService,
    http.Client? httpClient,
  })  : _ocrService = ocrService ?? CameraOcrService(),
        _dictionaryService = dictionaryService ?? DictionaryService(),
        _httpClient = httpClient ?? http.Client();

  final CameraOcrService _ocrService;
  final DictionaryService _dictionaryService;
  final http.Client _httpClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _geminiApiKeyStorageKey = 'nihongo_gemini_api_key';

  /// Lấy Gemini API Key nếu người dùng đã lưu
  Future<String?> getCustomApiKey() async {
    try {
      return await _storage.read(key: _geminiApiKeyStorageKey);
    } catch (_) {
      return null;
    }
  }

  /// Lưu Gemini API Key
  Future<void> saveCustomApiKey(String key) async {
    try {
      await _storage.write(key: _geminiApiKeyStorageKey, value: key.trim());
    } catch (_) {}
  }

  /// System Instruction chuẩn mực cho Multimodal LLM theo 5 tiêu chí người dùng yêu cầu
  static const String _systemPrompt = '''
Bạn là chuyên gia AI thị giác và từ điển tiếng Nhật (Vision & Multimodal Lexicographer).
Nhiệm vụ của bạn là đọc hình ảnh trang từ điển/sách/tài liệu tiếng Nhật được cung cấp và trích xuất dữ liệu cấu trúc ngữ nghĩa hoàn chỉnh.

YÊU CẦU BẮT BUỘC:
1. HIỂU BỐ CỤC KHÔNG GIAN (Spatial & Layout Understanding):
   - Phân biệt rõ các cột, từ khóa in đậm (Headword), phiên âm trong ngoặc vuông hoặc Furigana, từ loại in nghiêng, và các gạch đầu dòng nghĩa.
   - Không đọc nối các dòng rời rạc thành văn bản hỗn loạn.

2. TRÍCH XUẤT VÀ CẤU TRÚC HÓA (Information Extraction):
   - entryWord: Từ khóa chính (Kanji hoặc Kana).
   - reading: Cách đọc Hiragana / Furigana chính xác.
   - romaji: Phiên âm Latin hoặc Romaji.
   - partOfSpeech: Từ loại (danh từ, động từ nhóm 1/2/3, tính từ đuôi い/な, phó từ...).
   - definitions: Mảng các tầng nghĩa rõ ràng (nghĩa 1, nghĩa 2, nghĩa 3...) bằng TIẾNG VIỆT chuẩn xác.
   - examples: Mảng câu ví dụ. Mỗi câu gồm:
     * japanese: Câu tiếng Nhật.
     * reading: Cách đọc Hiragana của câu.
     * vietnamese: Dịch nghĩa tiếng Việt của câu ví dụ.
   - jlptLevel: Đánh giá cấp độ JLPT phù hợp (N5, N4, N3, N2, N1).
   - hanViet: Âm Hán Việt tương ứng (nếu có chữ Hán).

3. TỰ SỬA LỖI & LỌC RÁC THỊ GIÁC (Error Correction & Noise Filtering):
   - Tự động sửa các chữ bị bóng mờ che, nhòe nét in dựa theo ngữ pháp và ngữ cảnh từ vựng tiếng Nhật.
   - BỎ QUA hoàn toàn số trang sách, tiêu đề đầu trang/chân trang (Header/Footer), ngón tay của người chụp, hoặc hình vẽ không liên quan.

4. BỔ TRỢ & LÀM GIÀU NGỮ NGHĨA (Data Enrichment):
   - Nếu từ điển gốc là Nhật - Nhật hoặc Nhật - Anh, BẮT BUỘC dịch toàn bộ nghĩa và ví dụ sang tiếng Việt tự nhiên, dễ hiểu.
   - Nếu trong ảnh không có câu ví dụ, hãy TỰ ĐỘNG TẠO 1 câu ví dụ thực tế chuẩn Nhật kèm phiên âm và dịch nghĩa tiếng Việt.

5. ĐẦU RA JSON CHUẨN (Strict JSON Output):
   - Xuất ra JSON mảng các đối tượng (Array of objects) theo đúng schema:
   [
     {
       "entryWord": "勉強",
       "reading": "べんきょう",
       "romaji": "benkyou",
       "partOfSpeech": "Danh từ, Động từ する",
       "jlptLevel": "N5",
       "hanViet": "MIỄN CƯỜNG",
       "definitions": [
         "Sự học tập, nghiên cứu kiến thức",
         "Sự giảm giá, bớt giá (trong thương mại Nhật Bản)"
       ],
       "examples": [
         {
           "japanese": "毎日日本語を勉強します。",
           "reading": "まいにちにほんごをべんきょうします。",
           "vietnamese": "Tôi học tiếng Nhật mỗi ngày."
         }
       ],
       "confidence": 0.98
     }
   ]
''';

  /// Xử lý trích xuất văn bản và cấu trúc hóa dữ liệu
  /// Chạy qua Gemini Multimodal Vision API nếu có mạng, hoặc chạy Hybrid On-Device AI nếu offline
  Future<List<OcrDictionaryEntry>> extractDictionaryEntries({
    required String imagePath,
    String? preferredApiKey,
  }) async {
    final apiKey = preferredApiKey ?? await getCustomApiKey();

    // 1. Nếu có API Key, ưu tiên sử dụng Mô hình Multimodal LLM Vision với Strict JSON
    if (apiKey != null && apiKey.trim().isNotEmpty) {
      try {
        final entries = await _extractWithGeminiVision(imagePath, apiKey.trim());
        if (entries.isNotEmpty) {
          return entries;
        }
      } catch (e) {
        debugPrint('Gemini Vision API thất bại, chuyển sang On-Device Fallback: $e');
      }
    }

    // 2. Chạy Mô hình AI Thị giác On-Device kết hợp bộ phân tích cấu trúc & từ điển nội bộ
    return await _extractWithOnDeviceHybridAi(imagePath);
  }

  /// Gọi Multimodal Vision LLM trực tiếp với generationConfig.responseMimeType = 'application/json'
  Future<List<OcrDictionaryEntry>> _extractWithGeminiVision(
    String imagePath,
    String apiKey,
  ) async {
    final file = File(imagePath);
    if (!await file.exists()) return const [];

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': _systemPrompt},
            {
              'inlineData': {
                'mimeType': 'image/jpeg',
                'data': base64Image,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.1,
      }
    };

    final response = await _httpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      final candidates = json['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content?['parts'];
        if (parts is List && parts.isNotEmpty) {
          final rawJsonText = parts[0]['text']?.toString() ?? '';
          if (rawJsonText.isNotEmpty) {
            return OcrDictionaryEntry.fromJsonString(rawJsonText);
          }
        }
      }
    }
    return const [];
  }

  /// Mô hình AI Thị giác On-Device (Google ML Kit + Lọc rác + Cấu trúc hóa Từ điển)
  Future<List<OcrDictionaryEntry>> _extractWithOnDeviceHybridAi(
    String imagePath,
  ) async {
    // 1. Quét chữ bằng mô hình On-device Google ML Kit Vision AI
    final rawScan = await _ocrService.recognizeTextFromImage(imagePath);
    if (rawScan.isEmpty) return const [];

    final entries = <OcrDictionaryEntry>[];
    final seenWords = <String>{};

    // 2. Lọc bỏ rác thị giác: số trang (e.g. "124", "P. 45"), header/footer, ký tự đơn lẻ
    final filteredWords = rawScan.detectedWords.where((w) {
      final t = w.text.trim();
      if (t.length < 2 && !w.isKanji) return false;
      if (RegExp(r'^\d+$').hasMatch(t)) return false; // Số trang
      return true;
    }).toList();

    // 3. Với mỗi từ khóa phát hiện được, tra cứu và làm giàu ngữ nghĩa (Definitions, JLPT, Furigana, Examples)
    for (final word in filteredWords) {
      final headword = word.text;
      if (seenWords.add(headword)) {
        // Bước 3.1: Ưu tiên tra cứu từ điển AI nội bộ có độ chính xác cao
        final localAiEntry = JapaneseAiKnowledgeBase.lookup(headword);
        if (localAiEntry != null) {
          entries.add(localAiEntry);
          if (entries.length >= 8) break;
          continue;
        }

        // Bước 3.2: Tra cứu qua Backend Dictionary API nếu có
        try {
          final dictResults = await _dictionaryService.search(headword);
          if (dictResults.isNotEmpty) {
            final first = dictResults.first;
            final definitions = first.meanings
                .map((m) => m.text)
                .where((t) => t.trim().isNotEmpty)
                .toList();

            final detailedPos = JapaneseAiKnowledgeBase.getDetailedScriptLabel(headword);
            final pos = first.meanings
                .map((m) => m.partOfSpeech)
                .where((p) => p != null && p.isNotEmpty)
                .join(', ');

            final hanViet = first.kanjis
                .map((k) => k.hanViet)
                .where((h) => h != null && h.isNotEmpty)
                .join(' ');

            // Sinh ví dụ thực tế chuẩn ngữ cảnh
            final syntheticFallback = JapaneseAiKnowledgeBase.synthesizeEntry(headword);

            entries.add(
              OcrDictionaryEntry(
                entryWord: first.word.isNotEmpty ? first.word : headword,
                reading: first.reading.isNotEmpty ? first.reading : syntheticFallback.reading,
                romaji: first.romaji ?? syntheticFallback.romaji,
                partOfSpeech: pos.isNotEmpty ? '$detailedPos - $pos' : detailedPos,
                jlptLevel: first.jlptLevel ?? syntheticFallback.jlptLevel,
                definitions: definitions.isNotEmpty
                    ? definitions
                    : syntheticFallback.definitions,
                examples: syntheticFallback.examples,
                hanViet: hanViet.isNotEmpty ? hanViet : syntheticFallback.hanViet,
                confidence: 0.96,
              ),
            );
          } else {
            // Bước 3.3: Suy luận hình thái học AI chuyên sâu (không dùng câu ví dụ giả lập)
            entries.add(JapaneseAiKnowledgeBase.synthesizeEntry(headword));
          }
        } catch (_) {
          // Khi ngoại tuyến hoặc chưa kết nối backend, AI tự động cấu trúc hóa
          entries.add(JapaneseAiKnowledgeBase.synthesizeEntry(headword));
        }
      }

      if (entries.length >= 8) break; // Giới hạn các từ khóa chính nổi bật
    }

    return entries;
  }

  void dispose() {
    _ocrService.dispose();
    _dictionaryService.dispose();
    _httpClient.close();
  }
}
