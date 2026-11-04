class AnalysisResult {
  final String detectedLanguage;
  final String originalText;
  final String fullTranslation;
  final List<GrammarPoint> grammarList;
  final List<VocabularyItem> vocabularyList;

  const AnalysisResult({
    required this.detectedLanguage,
    required this.originalText,
    required this.fullTranslation,
    required this.grammarList,
    required this.vocabularyList,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      detectedLanguage: json['detected_language'] as String? ?? 'ja',
      originalText: json['original_text'] as String? ?? '',
      fullTranslation: json['full_translation'] as String? ?? '',
      grammarList: (json['grammar_list'] as List<dynamic>?)
              ?.map((item) => GrammarPoint.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      vocabularyList: (json['vocabulary_list'] as List<dynamic>?)
              ?.map((item) => VocabularyItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detected_language': detectedLanguage,
      'original_text': originalText,
      'full_translation': fullTranslation,
      'grammar_list': grammarList.map((e) => e.toJson()).toList(),
      'vocabulary_list': vocabularyList.map((e) => e.toJson()).toList(),
    };
  }
}

class GrammarPoint {
  final String structure;
  final String romaji;
  final String level;
  final String meaning;
  final String exampleJa;
  final String exampleVi;

  const GrammarPoint({
    required this.structure,
    required this.romaji,
    required this.level,
    required this.meaning,
    required this.exampleJa,
    required this.exampleVi,
  });

  factory GrammarPoint.fromJson(Map<String, dynamic> json) {
    return GrammarPoint(
      structure: json['structure'] as String? ?? '',
      romaji: json['romaji'] as String? ?? '',
      level: json['level'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      exampleJa: json['example_ja'] as String? ?? '',
      exampleVi: json['example_vi'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'structure': structure,
      'romaji': romaji,
      'level': level,
      'meaning': meaning,
      'example_ja': exampleJa,
      'example_vi': exampleVi,
    };
  }
}

class VocabularyItem {
  final String word;
  final String romaji;
  final String partOfSpeech;
  final String level;
  final String meaning;
  final String exampleJa;
  final String exampleVi;

  const VocabularyItem({
    required this.word,
    required this.romaji,
    required this.partOfSpeech,
    required this.level,
    required this.meaning,
    required this.exampleJa,
    required this.exampleVi,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      word: json['word'] as String? ?? '',
      romaji: json['romaji'] as String? ?? '',
      partOfSpeech: json['part_of_speech'] as String? ?? '',
      level: json['level'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      exampleJa: json['example_ja'] as String? ?? '',
      exampleVi: json['example_vi'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'romaji': romaji,
      'part_of_speech': partOfSpeech,
      'level': level,
      'meaning': meaning,
      'example_ja': exampleJa,
      'example_vi': exampleVi,
    };
  }
}

