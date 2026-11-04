import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TranslationService {
  TranslationService({http.Client? client}) : _client = client ?? http.Client();

  static const _geminiModel = 'gemini-3.5-flash-lite';
  static const _apiKeyStorageKey = 'nihongo_gemini_api_key';
  static const _storage = FlutterSecureStorage();

  final http.Client _client;

  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    void Function(String partialResult)? onChunk,
    void Function(String message)? onStatus,
  }) async {
    String? apiKey;
    try {
      apiKey = await _storage.read(key: _apiKeyStorageKey);
    } on PlatformException {
      throw const TranslationException(
        'Không đọc được Gemini API key đã lưu. Hãy kiểm tra cấu hình AI trong phần OCR.',
      );
    }
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const TranslationException(
        'Hãy nhập Gemini API key trong phần cấu hình AI của OCR trước khi dịch.',
      );
    }

    onStatus?.call('Đang chờ Gemini...');
    final prompt =
        '''
Translate from ${_languageNameForCode(sourceLanguage)} to ${_languageNameForCode(targetLanguage)}.
Return only the translation.

$text''';

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_geminiModel:streamGenerateContent',
      {'alt': 'sse', 'key': apiKey.trim()},
    );

    try {
      final outputTokenLimit = (text.runes.length * 2).clamp(256, 10240);
      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'maxOutputTokens': outputTokenLimit},
      });

      final stopwatch = Stopwatch()..start();
      final response = await _client
          .send(request)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 429) {
        throw const TranslationException(
          'Đã vượt giới hạn Gemini. Hãy thử lại sau.',
        );
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const TranslationException('Gemini từ chối API key.');
      }
      if (response.statusCode == 404) {
        throw TranslationException(
          'Không tìm thấy model Gemini $_geminiModel (HTTP 404). '
          'Hãy kiểm tra API key và model trong cấu hình ứng dụng.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw TranslationException('Gemini lỗi (HTTP ${response.statusCode})');
      }

      onStatus?.call('Gemini đang dịch...');
      final fullText = StringBuffer();
      var firstChunkReceived = false;
      var lastChunkUpdate = Duration.zero;
      await for (final line
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .timeout(const Duration(seconds: 30))) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6);
        if (data == '[DONE]') continue;

        final payload = jsonDecode(data);
        if (payload is! Map<String, dynamic>) continue;
        final candidates = payload['candidates'];
        if (candidates is! List || candidates.isEmpty) continue;
        final candidate = candidates.first;
        if (candidate is! Map<String, dynamic>) continue;
        final content = candidate['content'];
        if (content is! Map<String, dynamic>) continue;
        final parts = content['parts'];
        if (parts is! List) continue;

        for (final part in parts) {
          if (part is! Map<String, dynamic>) continue;
          final translatedChunk = part['text'];
          if (translatedChunk is String) {
            fullText.write(translatedChunk);
            final elapsed = stopwatch.elapsed;
            if (!firstChunkReceived) {
              firstChunkReceived = true;
              onStatus?.call(
                'Gemini phản hồi sau ${elapsed.inSeconds} giây...',
              );
              onChunk?.call(fullText.toString());
              lastChunkUpdate = elapsed;
            } else if (elapsed - lastChunkUpdate >=
                const Duration(milliseconds: 100)) {
              onChunk?.call(fullText.toString());
              lastChunkUpdate = elapsed;
            }
          }
        }
      }

      final result = fullText.toString().trim();
      if (result.isEmpty) {
        throw const TranslationException('Gemini không trả về bản dịch.');
      }
      onChunk?.call(result);
      return result;
    } on TimeoutException {
      throw const TranslationException(
        'Gemini phản hồi quá lâu hoặc bị ngắt kết nối. Hãy thử lại.',
      );
    } on SocketException {
      throw const TranslationException(
        'Không kết nối được Gemini. Kiểm tra Internet.',
      );
    } on http.ClientException {
      throw const TranslationException(
        'Không kết nối được Gemini. Kiểm tra Internet.',
      );
    } on FormatException {
      throw const TranslationException(
        'Gemini trả về dữ liệu không hợp lệ. Hãy thử lại.',
      );
    }
  }

  String _languageNameForCode(String code) => switch (code) {
    'ja' => 'Japanese',
    'vi' => 'Vietnamese',
    _ => throw ArgumentError.value(code, 'code', 'Ngôn ngữ không được hỗ trợ'),
  };

  void dispose() => _client.close();
}

class TranslationException implements Exception {
  const TranslationException(this.message);

  final String message;

  @override
  String toString() => message;
}
