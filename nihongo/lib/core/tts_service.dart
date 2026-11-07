import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Dịch vụ phát âm giọng đọc (Text-to-Speech) dùng chung cho toàn ứng dụng.
class AppTtsService {
  AppTtsService._internal();

  static final AppTtsService instance = AppTtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  static final RegExp _japaneseRegex = RegExp(
    r'[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff\uff66-\uff9f]',
  );

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.48);
      _initialized = true;
    } catch (_) {}
  }

  /// Tự động nhận diện ngôn ngữ (Nhật / Việt) hoặc dùng [lang] truyền vào và phát giọng đọc.
  Future<void> speak(
    String text, {
    String? lang,
    BuildContext? context,
  }) async {
    final cleaned = text
        .replaceAll('「', '')
        .replaceAll('」', '')
        .replaceAll('～', '')
        .replaceAll('~', '')
        .trim();

    if (cleaned.isEmpty) return;

    try {
      await _ensureInitialized();

      // Tự động ưu tiên giọng Nhật nếu chuỗi chứa ký tự Hiragana/Katakana/Kanji
      final bool hasJapanese = _japaneseRegex.hasMatch(cleaned);
      final String targetLang = hasJapanese
          ? 'ja-JP'
          : (lang == 'ja' ? 'ja-JP' : (lang == 'vi' ? 'vi-VN' : 'ja-JP'));

      await _tts.setLanguage(targetLang);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(targetLang == 'ja-JP' ? 0.45 : 0.5);
      await _tts.speak(cleaned);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
