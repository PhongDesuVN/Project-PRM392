import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/features/camera_ocr/camera_ocr_page.dart';
import 'package:nihongo/features/camera_ocr/models/ocr_dictionary_entry.dart';
import 'package:nihongo/features/camera_ocr/models/ocr_scan_result.dart';
import 'package:nihongo/features/camera_ocr/services/japanese_ai_knowledge_base.dart';
import 'package:nihongo/features/camera_ocr/widgets/ocr_action_bar.dart';
import 'package:nihongo/features/camera_ocr/widgets/ocr_dictionary_card.dart';
import 'package:nihongo/features/camera_ocr/widgets/ocr_result_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Camera OCR Models & Logic', () {
    test('OcrWordCandidate analyze distinguishes Hiragana, Katakana and Kanji correctly', () {
      final hira = OcrWordCandidate.analyze('とける');
      expect(hira.scriptType, JapaneseScriptType.hiragana);
      expect(hira.scriptLabel, 'Hiragana (Chữ mềm)');

      final kata = OcrWordCandidate.analyze('カメラ');
      expect(kata.scriptType, JapaneseScriptType.katakana);
      expect(kata.scriptLabel, 'Katakana (Chữ cứng / Từ mượn)');

      final kanji = OcrWordCandidate.analyze('生活');
      expect(kanji.scriptType, JapaneseScriptType.kanji);
      expect(kanji.scriptLabel, 'Hán tự (Kanji)');

      final verbMixed = OcrWordCandidate.analyze('近づける');
      expect(verbMixed.scriptType, JapaneseScriptType.mixedKanjiKana);
      expect(verbMixed.scriptLabel, 'Động từ (Kanji + Okurigana)');
    });

    test('JapaneseAiKnowledgeBase resolves 近づける and とける accurately with real meanings and examples', () {
      final chikazukeru = JapaneseAiKnowledgeBase.lookup('近づける');
      expect(chikazukeru, isNotNull);
      expect(chikazukeru!.reading, 'ちかづける');
      expect(chikazukeru.hanViet, 'CẬN');
      expect(chikazukeru.partOfSpeech, contains('Động từ nhóm 2'));
      expect(chikazukeru.definitions.first, contains('Kéo lại gần'));
      expect(chikazukeru.examples.first.japanese, contains('車を壁に近づけて'));

      final tokeru = JapaneseAiKnowledgeBase.lookup('とける');
      expect(tokeru, isNotNull);
      expect(tokeru!.reading, 'とける');
      expect(tokeru.partOfSpeech, contains('Hiragana'));
      expect(tokeru.definitions.first, contains('Tan chảy'));
      expect(tokeru.examples.first.japanese, contains('春になって山の雪がとける'));
    });

    test('OcrWordCandidate equality and properties', () {
      const w1 = OcrWordCandidate(text: '日本語', isKanji: true);
      const w2 = OcrWordCandidate(text: '日本語', isKanji: false);
      const w3 = OcrWordCandidate(text: 'さくら', isKanji: false);

      expect(w1, equals(w2));
      expect(w1 == w3, isFalse);
    });

    test('OcrScanResult handles empty and populated states', () {
      final emptyResult = OcrScanResult.empty('test_path.jpg');
      expect(emptyResult.isEmpty, isTrue);
      expect(emptyResult.isNotEmpty, isFalse);

      final populated = OcrScanResult(
        imagePath: 'test.jpg',
        fullText: 'こんにちは 世界',
        lines: const ['こんにちは 世界'],
        detectedWords: const [
          OcrWordCandidate(text: 'こんにちは'),
          OcrWordCandidate(text: '世界', isKanji: true),
        ],
        scannedAt: DateTime.now(),
      );

      expect(populated.isNotEmpty, isTrue);
      expect(populated.detectedWords.length, 2);
      expect(populated.detectedWords[1].isKanji, isTrue);
    });

    test('OcrDictionaryEntry serializes and deserializes Strict JSON correctly', () {
      const jsonString = '''
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
            "Sự giảm giá"
          ],
          "examples": [
            {
              "japanese": "日本語を勉強する。",
              "reading": "にほんごをべんきょうする。",
              "vietnamese": "Học tiếng Nhật."
            }
          ],
          "confidence": 0.99
        }
      ]
      ''';

      final entries = OcrDictionaryEntry.fromJsonString(jsonString);
      expect(entries.length, 1);
      final entry = entries.first;

      expect(entry.entryWord, '勉強');
      expect(entry.reading, 'べんきょう');
      expect(entry.romaji, 'benkyou');
      expect(entry.jlptLevel, 'N5');
      expect(entry.hanViet, 'MIỄN CƯỜNG');
      expect(entry.definitions.length, 2);
      expect(entry.examples.length, 1);
      expect(entry.examples.first.japanese, '日本語を勉強する。');
      expect(entry.examples.first.vietnamese, 'Học tiếng Nhật.');
    });
  });

  group('Camera OCR Widgets', () {
    testWidgets('OcrActionBar responds to button actions', (tester) async {
      bool searched = false;
      bool translated = false;
      bool copied = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: OcrActionBar(
              hasContent: true,
              onSearchDictionary: () => searched = true,
              onTranslate: () => translated = true,
              onCopy: () => copied = true,
            ),
          ),
        ),
      );

      expect(find.text('Tra từ điển'), findsOneWidget);
      expect(find.text('Dịch'), findsOneWidget);

      await tester.tap(find.text('Tra từ điển'));
      await tester.pump();
      expect(searched, isTrue);

      await tester.tap(find.text('Dịch'));
      await tester.pump();
      expect(translated, isTrue);
      expect(copied, isFalse);
    });

    testWidgets('OcrDictionaryCard displays structured entries and triggers actions', (tester) async {
      bool searchedDetail = false;
      bool savedToNotebook = false;

      const entry = OcrDictionaryEntry(
        entryWord: '先生',
        reading: 'せんせい',
        romaji: 'sensei',
        partOfSpeech: 'Danh từ',
        jlptLevel: 'N5',
        hanViet: 'TIÊN SINH',
        definitions: ['Thầy giáo, cô giáo, người hướng dẫn'],
        examples: [
          OcrDictionaryExample(
            japanese: '田中先生は優しいです。',
            reading: 'たなかせんせいはやさしいです。',
            vietnamese: 'Thầy Tanaka rất hiền.',
          )
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OcrDictionaryCard(
              entry: entry,
              onSearchDetail: () => searchedDetail = true,
              onSaveToNotebook: () => savedToNotebook = true,
            ),
          ),
        ),
      );

      expect(find.text('先生'), findsOneWidget);
      expect(find.text('せんせい'), findsOneWidget);
      expect(find.text('N5'), findsOneWidget);
      expect(find.text('TIÊN SINH'), findsOneWidget);
      expect(find.text('Thầy giáo, cô giáo, người hướng dẫn'), findsOneWidget);
      expect(find.text('Tanaka', findRichText: true), findsNothing);
      expect(find.text('Thầy Tanaka rất hiền.'), findsOneWidget);

      await tester.tap(find.text('Tra từ điển'));
      await tester.pump();
      expect(searchedDetail, isTrue);

      await tester.tap(find.text('Lưu sổ tay'));
      await tester.pump();
      expect(savedToNotebook, isTrue);
    });

    testWidgets('OcrResultCard displays detected text and word chips', (tester) async {
      final controller = TextEditingController(text: '勉強');
      String? selectedWord;

      final scanResult = OcrScanResult(
        imagePath: 'dummy.jpg',
        fullText: '勉強',
        lines: const ['勉強'],
        detectedWords: const [
          OcrWordCandidate(text: '勉強', isKanji: true),
        ],
        scannedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OcrResultCard(
              scanResult: scanResult,
              textController: controller,
              selectedWord: '勉強',
              onSelectWord: (w) => selectedWord = w,
              onCopyText: () {},
            ),
          ),
        ),
      );

      expect(find.text('Nội dung nhận diện'), findsOneWidget);
      expect(find.text('勉強'), findsNWidgets(2)); // in TextField and in Chip

      await tester.tap(find.text('勉強').last);
      await tester.pump();
      expect(selectedWord, '勉強');
    });

    testWidgets('CameraOcrPage displays empty state when not auto-launching', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CameraOcrPage(autoLaunchCamera: false),
        ),
      );
      await tester.pump();

      expect(find.text('Nihon AI Camera'), findsNWidgets(2)); // in AppBar and empty state body
      expect(find.text('Mở máy ảnh chụp ngay'), findsOneWidget);
      expect(find.text('Chọn ảnh từ thư viện'), findsOneWidget);
    });
  });
}
