import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/features/dashboard/learn/notebook/my_notebook_view.dart';
import 'package:nihongo/features/dashboard/learn/notebook/services/notebook_service.dart';
import 'package:nihongo/features/learn/topic_words/models/topic_word_model.dart';

void main() {
  setUp(() {
    NotebookService.instance.clearForTesting();
  });

  test(
    'NotebookService updates stats when learning results are saved',
    () async {
      final service = NotebookService.instance;
      expect(service.stats.chuaThuoc, 0);
      expect(service.stats.thuocLoMo, 0);
      expect(service.stats.thuocLauLau, 0);

      final word1 = TopicWord(
        id: 1,
        topicCode: 'N5',
        word: '猫',
        reading: 'ねこ',
        romaji: 'neko',
        meaning: 'Con mèo',
      );
      final word2 = TopicWord(
        id: 2,
        topicCode: 'N5',
        word: '犬',
        reading: 'いぬ',
        romaji: 'inu',
        meaning: 'Con chó',
      );
      final word3 = TopicWord(
        id: 3,
        topicCode: 'N5',
        word: '鳥',
        reading: 'とり',
        romaji: 'tori',
        meaning: 'Con chim',
      );

      await service.saveStudyResult(
        masteredWords: [word1],
        hardWords: [word2],
        unknownWords: [word3],
      );

      expect(service.stats.chuaThuoc, 1);
      expect(service.stats.thuocLoMo, 1);
      expect(service.stats.thuocLauLau, 1);
      expect(service.stats.total, 3);
    },
  );

  testWidgets('MyNotebookView displays numbers after saving progress', (
    tester,
  ) async {
    final service = NotebookService.instance;
    final word = TopicWord(
      id: 1,
      topicCode: 'N5',
      word: '本',
      reading: 'ほん',
      romaji: 'hon',
      meaning: 'Sách',
    );
    await service.saveStudyResult(
      masteredWords: [word],
      hardWords: [],
      unknownWords: [],
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MyNotebookView())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tổng quan'), findsOneWidget);
    expect(find.text('Danh sách sổ tay'), findsOneWidget);
    expect(find.text('--'), findsNWidgets(3));
    expect(find.text('Ôn tập sổ tay (1 từ)'), findsOneWidget);
  });
}
