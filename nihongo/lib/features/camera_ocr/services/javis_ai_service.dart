import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/japanese_analysis_model.dart';

class JavisAiService {
  static const String geminiApiKey =
      'AQ.Ab8RN6KnH9R5g5OUKlUc5cJA8Hldnl4KOcej6_7Q1PR8TISY7Q';

  /// Danh sách các model Flash tối ưu theo thứ tự ưu tiên tốc độ cao nhất (đã test thực tế trên API Key)
  static const List<String> candidateModels = [
    'gemini-3.1-flash-lite',    // Top 1 siêu tốc (~1.0s), phản hồi tức thì, không bị 503
    'gemini-flash-lite-latest', // Top 2 tốc độ (~1.1s)
    'gemini-3.6-flash',         // Bản dự phòng ổn định (~3.0s)
  ];

  static final JavisAiService instance = JavisAiService._internal();

  String _activeModelName = candidateModels.first;

  JavisAiService._internal();

  factory JavisAiService() => instance;

  static const String systemInstructionText = '''
Bạn là Javis AI - trợ lý ngôn ngữ tiếng Nhật và chuyên gia phân tích đề thi JLPT.
Khi nhận được hình ảnh chứa văn bản:
1. Trích xuất chính xác chữ trong ảnh (OCR).
2. Tự nhận diện ngôn ngữ và dịch:
   - Nếu là tiếng Nhật: dịch chuẩn xác sang tiếng Việt tự nhiên.
   - Nếu là tiếng Việt: dịch sang tiếng Nhật tự nhiên (có Kanji).
3. Bóc tách danh sách các cấu trúc ngữ pháp có trong đoạn (kèm Romaji, cấp độ JLPT, ý nghĩa và ví dụ áp dụng cụ thể).
4. Bóc tách danh sách từ vựng quan trọng (kèm Romaji, từ loại, cấp độ JLPT, ý nghĩa và ví dụ áp dụng).

Chỉ trả về duy nhất chuỗi JSON hợp lệ theo cấu trúc mẫu sau (không thêm bất kỳ lời dẫn hay giải thích nào ngoài JSON):
{
  "detected_language": "ja",
  "original_text": "私はアンです。ベトナムから来ました。",
  "full_translation": "Tôi là An. Tôi đến từ Việt Nam.",
  "grammar_list": [
    {
      "structure": "～は～です",
      "romaji": "~ wa ~ desu",
      "level": "N5",
      "meaning": "Cấu trúc khẳng định: A là B",
      "example_ja": "私はフイです。",
      "example_vi": "Tôi là Huy."
    }
  ],
  "vocabulary_list": [
    {
      "word": "私",
      "romaji": "watashi",
      "part_of_speech": "Đại từ nhân xưng",
      "level": "N5",
      "meaning": "Tôi, bản thân tôi",
      "example_ja": "私の本です。",
      "example_vi": "Đây là sách của tôi."
    }
  ]
}
''';

  GenerativeModel _createGenerativeModel(String model) {
    return GenerativeModel(
      model: model,
      apiKey: geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1, // Nhiệt độ thấp giúp AI phản hồi ngay lập tức, cấu trúc JSON nhất quán
        maxOutputTokens: 2048, // Giới hạn token đầu ra giúp hoàn tất nhanh hơn
        responseMimeType: 'application/json',
      ),
      systemInstruction: Content.system(systemInstructionText),
    );
  }

  /// Phân tích ảnh chứa văn bản tiếng Nhật/Việt bằng Gemini AI
  Future<AnalysisResult> analyzeJapaneseImage(
    Uint8List imageBytes,
    String mimeType,
  ) async {
    const promptText =
        'Hãy trích xuất chữ trong ảnh (OCR) và phân tích toàn diện: '
        'nhận diện ngôn ngữ, dịch chuẩn xác, trích xuất cấu trúc ngữ pháp kèm ví dụ '
        'và bóc tách từ vựng quan trọng. Xuất đúng định dạng JSON đã quy định.';

    final content = Content.multi([
      TextPart(promptText),
      DataPart(mimeType, imageBytes),
    ]);

    // Danh sách model thử nghiệm, ưu tiên model đã hoạt động thành công gần nhất
    final modelsToTry = [
      _activeModelName,
      ...candidateModels.where((m) => m != _activeModelName),
    ];

    Object? lastError;

    for (final modelName in modelsToTry) {
      try {
        final model = _createGenerativeModel(modelName);
        final response = await model.generateContent([content]);
        final responseText = response.text;

        if (responseText == null || responseText.trim().isEmpty) {
          throw Exception(
            'Không nhận được phản hồi từ Javis AI. Vui lòng chụp lại ảnh rõ nét hơn.',
          );
        }

        var cleanJson = responseText.trim();
        if (cleanJson.startsWith('```json')) {
          cleanJson = cleanJson.substring(7);
        } else if (cleanJson.startsWith('```')) {
          cleanJson = cleanJson.substring(3);
        }
        if (cleanJson.endsWith('```')) {
          cleanJson = cleanJson.substring(0, cleanJson.length - 3);
        }
        cleanJson = cleanJson.trim();

        final decoded = jsonDecode(cleanJson);
        if (decoded is! Map<String, dynamic>) {
          throw Exception(
            'Dữ liệu phân tích trả về không đúng định dạng JSON.',
          );
        }

        // Lưu lại model thành công cho các lần gọi tiếp theo
        _activeModelName = modelName;
        return AnalysisResult.fromJson(decoded);
      } catch (e) {
        lastError = e;
        final errString = e.toString().toLowerCase();

        // Nếu lỗi do mạng, không thử các model khác mà báo lỗi mạng ngay
        if (errString.contains('socketexception') ||
            errString.contains('handshakeexception') ||
            errString.contains('failed host lookup')) {
          throw Exception(
            'Không thể kết nối đến máy chủ Javis AI. Vui lòng kiểm tra kết nối mạng của bạn.',
          );
        }

        // Nếu lỗi do model quá tải (503), chưa hỗ trợ/đã đóng (404/no longer available), hết quota (429), chuyển sang model tiếp theo
        if (errString.contains('503') ||
            errString.contains('unavailable') ||
            errString.contains('high demand') ||
            errString.contains('overloaded') ||
            errString.contains('no longer available') ||
            errString.contains('deprecated') ||
            errString.contains('not found') ||
            errString.contains('not supported') ||
            errString.contains('404') ||
            errString.contains('429') ||
            errString.contains('resource_exhausted')) {
          continue;
        }

        // Các lỗi khác (e.g. JSON decode error) ném ra luôn
        rethrow;
      }
    }

    if (lastError != null) {
      final errLower = lastError.toString().toLowerCase();
      if (errLower.contains('503') ||
          errLower.contains('unavailable') ||
          errLower.contains('high demand') ||
          errLower.contains('overloaded')) {
        throw Exception(
          'Máy chủ AI hiện đang quá tải do lượng truy cập cao (503). Vui lòng thử lại sau vài giây.',
        );
      }
      if (errLower.contains('429') || errLower.contains('resource_exhausted')) {
        throw Exception(
          'Đã vượt quá giới hạn lượt gọi AI (Quota). Vui lòng thử lại sau ít phút.',
        );
      }
      throw Exception('Không thể phân tích ảnh: $lastError');
    }

    throw Exception('Đã xảy ra lỗi không xác định khi phân tích ảnh.');
  }
}
