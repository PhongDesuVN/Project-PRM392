import 'dart:convert';

/// Ví dụ câu minh họa đi kèm từ vựng
class OcrDictionaryExample {
  const OcrDictionaryExample({
    required this.japanese,
    this.reading = '',
    required this.vietnamese,
  });

  final String japanese;
  final String reading;
  final String vietnamese;

  factory OcrDictionaryExample.fromJson(Map<String, dynamic> json) {
    return OcrDictionaryExample(
      japanese: json['japanese']?.toString() ?? '',
      reading: json['reading']?.toString() ?? '',
      vietnamese: json['vietnamese']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'japanese': japanese,
        'reading': reading,
        'vietnamese': vietnamese,
      };
}

/// Mô hình cấu trúc hóa ngữ nghĩa từ điển hoàn chỉnh trích xuất từ AI Vision (Schema chuẩn)
class OcrDictionaryEntry {
  const OcrDictionaryEntry({
    required this.entryWord,
    required this.reading,
    this.romaji = '',
    this.partOfSpeech = '',
    this.jlptLevel = '',
    this.definitions = const [],
    this.examples = const [],
    this.hanViet = '',
    this.confidence = 1.0,
  });

  /// 1. Từ khóa chính (Entry Word / Headword)
  final String entryWord;

  /// 2. Phiên âm / Cách đọc Hiragana / Furigana
  final String reading;

  /// Romaji / Phiên âm chữ Latin
  final String romaji;

  /// 3. Phân loại từ loại (Danh từ, Động từ, Tính từ...)
  final String partOfSpeech;

  /// Cấp độ JLPT (N5, N4, N3, N2, N1)
  final String jlptLevel;

  /// 4. Các tầng nghĩa tiếng Việt (Được làm giàu và dịch thuật tự động)
  final List<String> definitions;

  /// 5. Danh sách câu ví dụ song ngữ Nhật - Việt
  final List<OcrDictionaryExample> examples;

  /// Âm Hán Việt nếu từ có chứa chữ Hán
  final String hanViet;

  /// Độ tin cậy của AI
  final double confidence;

  factory OcrDictionaryEntry.fromJson(Map<String, dynamic> json) {
    final rawDefinitions = json['definitions'];
    final definitionsList = <String>[];
    if (rawDefinitions is List) {
      for (final d in rawDefinitions) {
        if (d != null && d.toString().trim().isNotEmpty) {
          definitionsList.add(d.toString().trim());
        }
      }
    } else if (rawDefinitions is String && rawDefinitions.trim().isNotEmpty) {
      definitionsList.add(rawDefinitions.trim());
    }

    final rawExamples = json['examples'];
    final examplesList = <OcrDictionaryExample>[];
    if (rawExamples is List) {
      for (final ex in rawExamples) {
        if (ex is Map<String, dynamic>) {
          examplesList.add(OcrDictionaryExample.fromJson(ex));
        } else if (ex is Map) {
          examplesList.add(
            OcrDictionaryExample.fromJson(Map<String, dynamic>.from(ex)),
          );
        }
      }
    }

    return OcrDictionaryEntry(
      entryWord: json['entryWord']?.toString() ?? '',
      reading: json['reading']?.toString() ?? '',
      romaji: json['romaji']?.toString() ?? '',
      partOfSpeech: json['partOfSpeech']?.toString() ?? '',
      jlptLevel: json['jlptLevel']?.toString() ?? '',
      definitions: definitionsList,
      examples: examplesList,
      hanViet: json['hanViet']?.toString() ?? '',
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'entryWord': entryWord,
        'reading': reading,
        'romaji': romaji,
        'partOfSpeech': partOfSpeech,
        'jlptLevel': jlptLevel,
        'definitions': definitions,
        'examples': examples.map((e) => e.toJson()).toList(),
        'hanViet': hanViet,
        'confidence': confidence,
      };

  /// Chuyển đổi từ chuỗi JSON thô trực tiếp
  static List<OcrDictionaryEntry> fromJsonString(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => OcrDictionaryEntry.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (decoded is Map && decoded['entries'] is List) {
        final list = decoded['entries'] as List;
        return list
            .whereType<Map>()
            .map((item) => OcrDictionaryEntry.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {}
    return const [];
  }
}

