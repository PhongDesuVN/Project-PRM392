import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/features/camera_ocr/models/japanese_analysis_model.dart';

void main() {
  group('Javis AI Analysis Model Tests', () {
    test('AnalysisResult decodes JSON properly', () {
      final jsonMap = {
        'detected_language': 'ja',
        'original_text': '私はアンです。ベトナムから来ました。',
        'full_translation': 'Tôi là An. Tôi đến từ Việt Nam.',
        'grammar_list': [
          {
            'structure': '～は～です',
            'romaji': '~ wa ~ desu',
            'level': 'N5',
            'meaning': 'Cấu trúc khẳng định: A là B',
            'example_ja': '私はフイです。',
            'example_vi': 'Tôi là Huy.',
          },
        ],
        'vocabulary_list': [
          {
            'word': '私',
            'romaji': 'watashi',
            'part_of_speech': 'Đại từ nhân xưng',
            'level': 'N5',
            'meaning': 'Tôi, bản thân tôi',
            'example_ja': '私の本です。',
            'example_vi': 'Đây là sách của tôi.',
          },
        ],
      };

      final result = AnalysisResult.fromJson(jsonMap);

      expect(result.detectedLanguage, 'ja');
      expect(result.originalText, '私はアンです。ベトナムから来ました。');
      expect(result.fullTranslation, 'Tôi là An. Tôi đến từ Việt Nam.');
      expect(result.grammarList.length, 1);
      expect(result.grammarList.first.structure, '～は～です');
      expect(result.grammarList.first.level, 'N5');
      expect(result.vocabularyList.length, 1);
      expect(result.vocabularyList.first.word, '私');
      expect(result.vocabularyList.first.partOfSpeech, 'Đại từ nhân xưng');

      final encoded = result.toJson();
      expect(encoded['detected_language'], 'ja');
      expect((encoded['grammar_list'] as List).length, 1);
      expect((encoded['vocabulary_list'] as List).length, 1);
    });

    test('AnalysisResult handles null and missing fields gracefully', () {
      final result = AnalysisResult.fromJson({});
      expect(result.detectedLanguage, 'ja');
      expect(result.originalText, isEmpty);
      expect(result.fullTranslation, isEmpty);
      expect(result.grammarList, isEmpty);
      expect(result.vocabularyList, isEmpty);
    });
  });
}

