import 'package:flutter/foundation.dart';

/// Phân loại bảng chữ cái / hình thái từ vựng tiếng Nhật
enum JapaneseScriptType {
  /// Chữ mềm Hiragana (あ, い, う, え, お...)
  hiragana,

  /// Chữ cứng Katakana / từ mượn ngoại lai (ア, イ, ウ, エ, オ...)
  katakana,

  /// Chữ Hán Kanji thuần (Kanji đơn lẻ hoặc từ ghép Hán tự: 勉強, 生活...)
  kanji,

  /// Hán tự kết hợp Kana / Okurigana (Động từ, tính từ: 近づける, 食べる, 小さい...)
  mixedKanjiKana,

  /// Ký tự Latin / Romaji / Khác
  other,
}

/// Đại diện cho một từ hoặc cụm từ tiếng Nhật được bóc tách từ ảnh
@immutable
class OcrWordCandidate {
  const OcrWordCandidate({
    required this.text,
    this.isKanji = false,
    this.scriptType = JapaneseScriptType.other,
  });

  final String text;
  final bool isKanji;
  final JapaneseScriptType scriptType;

  /// Phân tích và tạo ứng viên từ vựng với định danh bảng chữ cái chính xác
  factory OcrWordCandidate.analyze(String text) {
    final trimmed = text.trim();
    final hasKanji = RegExp(r'[\u4e00-\u9faf\u3400-\u4dbf]').hasMatch(trimmed);
    final hasHiragana = RegExp(r'[\u3040-\u309f]').hasMatch(trimmed);
    final hasKatakana = RegExp(r'[\u30a0-\u30ff\u31f0-\u31ff\uff65-\uff9f]').hasMatch(trimmed);

    JapaneseScriptType script;
    if (hasKanji && (hasHiragana || hasKatakana)) {
      script = JapaneseScriptType.mixedKanjiKana;
    } else if (hasKanji) {
      script = JapaneseScriptType.kanji;
    } else if (hasKatakana && !hasHiragana) {
      script = JapaneseScriptType.katakana;
    } else if (hasHiragana && !hasKatakana) {
      script = JapaneseScriptType.hiragana;
    } else {
      script = JapaneseScriptType.other;
    }

    return OcrWordCandidate(
      text: trimmed,
      isKanji: hasKanji,
      scriptType: script,
    );
  }

  /// Tên nhãn phân loại hiển thị trên giao diện người dùng
  String get scriptLabel {
    switch (scriptType) {
      case JapaneseScriptType.hiragana:
        return 'Hiragana (Chữ mềm)';
      case JapaneseScriptType.katakana:
        return 'Katakana (Chữ cứng / Từ mượn)';
      case JapaneseScriptType.kanji:
        return 'Hán tự (Kanji)';
      case JapaneseScriptType.mixedKanjiKana:
        if (text.endsWith('る') ||
            text.endsWith('く') ||
            text.endsWith('ぐ') ||
            text.endsWith('す') ||
            text.endsWith('つ') ||
            text.endsWith('ぬ') ||
            text.endsWith('ぶ') ||
            text.endsWith('む') ||
            text.endsWith('う')) {
          return 'Động từ (Kanji + Okurigana)';
        }
        if (text.endsWith('い')) {
          return 'Tính từ đuôi い (Kanji)';
        }
        return 'Từ ghép / Kanji';
      case JapaneseScriptType.other:
        return isKanji ? 'Hán tự' : 'Từ vựng tiếng Nhật';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrWordCandidate &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;
}

/// Kết quả phân tích văn bản từ hình ảnh chạy hoàn toàn trên On-Device AI
@immutable
class OcrScanResult {
  const OcrScanResult({
    required this.imagePath,
    required this.fullText,
    required this.lines,
    required this.detectedWords,
    required this.scannedAt,
  });

  /// Đường dẫn file ảnh đã chụp
  final String imagePath;

  /// Toàn bộ nội dung văn bản nhận diện được
  final String fullText;

  /// Từng dòng chữ nhận diện được
  final List<String> lines;

  /// Danh sách các từ vựng / Kanji tiếng Nhật được bóc tách riêng lẻ để người dùng chọn nhanh
  final List<OcrWordCandidate> detectedWords;

  /// Thời điểm quét
  final DateTime scannedAt;

  bool get isEmpty => fullText.trim().isEmpty;
  bool get isNotEmpty => !isEmpty;

  static OcrScanResult empty(String path) => OcrScanResult(
    imagePath: path,
    fullText: '',
    lines: const [],
    detectedWords: const [],
    scannedAt: DateTime.now(),
  );
}
