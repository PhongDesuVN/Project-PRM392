import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import '../../camera_ocr/services/javis_ai_service.dart';

class TranslationService {
  TranslationService({http.Client? client});

  static const _apiKeyStorageKey = 'nihongo_gemini_api_key';
  static const _storage = FlutterSecureStorage();

  static const List<String> _candidateModels = [
    'gemini-3.1-flash-lite',
    'gemini-flash-lite-latest',
    'gemini-3.6-flash',
  ];

  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    void Function(String partialResult)? onChunk,
    void Function(String message)? onStatus,
  }) async {
    // Luôn ưu tiên dùng key mới nhất từ JavisAiService
    final apiKey = JavisAiService.geminiApiKey;

    // Cập nhật đè vào storage để xóa bỏ bất kỳ key cũ nào bị kẹt trên máy
    try {
      unawaited(_storage.write(key: _apiKeyStorageKey, value: apiKey));
    } catch (_) {}

    onStatus?.call('Đang kết nối Gemini...');
    final prompt = '''
Bạn là chuyên gia dịch thuật chuyên nghiệp.
Hãy dịch chính xác đoạn văn sau từ ${_languageNameForCode(sourceLanguage)} sang ${_languageNameForCode(targetLanguage)}.
Chỉ trả về bản dịch duy nhất, không thêm giải thích hay ghi chú nào khác:

$text
''';

    Object? lastError;

    // Thử lần lượt các model tối ưu (gemini-flash-lite-latest -> gemini-flash-latest -> gemini-3.8-flash)
    for (final modelName in _candidateModels) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.1,
            maxOutputTokens: 2048,
          ),
        );

        onStatus?.call('Gemini đang dịch...');

        final responseStream = model.generateContentStream([
          Content.text(prompt),
        ]);

        final fullText = StringBuffer();

        await for (final chunk in responseStream) {
          final chunkText = chunk.text;
          if (chunkText != null && chunkText.isNotEmpty) {
            fullText.write(chunkText);
            onChunk?.call(fullText.toString());
          }
        }

        final result = fullText.toString().trim();
        if (result.isNotEmpty) {
          onChunk?.call(result);
          return result;
        }

        // Nếu stream không có text, thử generateContent thường
        final singleResponse = await model.generateContent([
          Content.text(prompt),
        ]);
        final singleText = singleResponse.text?.trim() ?? '';
        if (singleText.isNotEmpty) {
          onChunk?.call(singleText);
          return singleText;
        }
      } catch (e) {
        lastError = e;
        final errorStr = e.toString().toLowerCase();

        // Nếu lỗi 401/403 (từ chối API key)
        if (errorStr.contains('401') ||
            errorStr.contains('403') ||
            errorStr.contains('api_key_invalid') ||
            errorStr.contains('permission_denied')) {
          throw const TranslationException(
            'Gemini từ chối API key. Hãy kiểm tra lại API Key trong cài đặt.',
          );
        }

        // Nếu quá hạn mức Quota (429)
        if (errorStr.contains('429') ||
            errorStr.contains('resource_exhausted') ||
            errorStr.contains('quota')) {
          throw const TranslationException(
            'Đã vượt giới hạn lượt gọi Gemini (Quota). Hãy thử lại sau ít phút.',
          );
        }

        // Nếu model 503 (quá tải), no longer available, deprecated hoặc 404, tự động chuyển sang model tiếp theo
        continue;
      }
    }

    if (lastError != null) {
      final msg = lastError.toString();
      final errLower = msg.toLowerCase();
      if (errLower.contains('socketexception') || errLower.contains('failed host lookup')) {
        throw const TranslationException(
          'Không kết nối được Gemini. Vui lòng kiểm tra Internet.',
        );
      }
      if (errLower.contains('503') ||
          errLower.contains('unavailable') ||
          errLower.contains('high demand') ||
          errLower.contains('overloaded')) {
        throw const TranslationException(
          'Máy chủ Gemini đang quá tải (503). Vui lòng thử lại sau vài giây.',
        );
      }
      throw TranslationException('Lỗi dịch Gemini: $lastError');
    }

    throw const TranslationException('Gemini không trả về bản dịch.');
  }

  String _languageNameForCode(String code) => switch (code) {
    'ja' => 'Tiếng Nhật',
    'vi' => 'Tiếng Việt',
    _ => throw ArgumentError.value(code, 'code', 'Ngôn ngữ không được hỗ trợ'),
  };

  void dispose() {}
}

class TranslationException implements Exception {
  const TranslationException(this.message);

  final String message;

  @override
  String toString() => message;
}
