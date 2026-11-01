import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nihongo/features/dashboard/mock_exam/mock_exam_tab.dart';
import 'package:nihongo/features/dashboard/mock_exam/models/exam_models.dart';
import 'package:nihongo/features/dashboard/mock_exam/services/mock_exam_service.dart';

/// Service giả: không gọi mạng, chấm điểm theo đáp án đúng là option id 2.
class _FakeMockExamService extends MockExamService {
  final List<String> requestedLevels = [];
  Map<int, int>? submitted;

  static const _summary = ExamSummary(
    id: 1,
    title: 'Test từ vựng N5 - Đề 1',
    level: 'N5',
    type: ExamType.vocabulary,
    durationMinutes: 10,
    totalQuestions: 2,
    attempts: 0,
    bestPercent: 0,
  );

  @override
  Future<List<ExamSummary>> fetchTests({required String level}) async {
    requestedLevels.add(level);
    return [
      _summary,
      const ExamSummary(
        id: 3,
        title: 'Thi thử JLPT N5 - Đề 1',
        level: 'N5',
        type: ExamType.jlpt,
        durationMinutes: 25,
        totalQuestions: 16,
        attempts: 2,
        bestPercent: 75,
      ),
    ];
  }

  @override
  Future<ExamDetail> fetchTest(int id) async {
    return const ExamDetail(
      id: 1,
      title: 'Test từ vựng N5 - Đề 1',
      level: 'N5',
      type: ExamType.vocabulary,
      durationMinutes: 10,
      questions: [
        ExamQuestion(
          id: 10,
          section: 'vocabulary',
          text: '【読み方】【今日】は天気がいいです。',
          options: [
            ExamOption(id: 1, text: 'こんにち'),
            ExamOption(id: 2, text: 'きょう'),
          ],
        ),
        ExamQuestion(
          id: 11,
          section: 'vocabulary',
          text: '【読み方】【学校】へ行きます。',
          options: [
            ExamOption(id: 3, text: 'がくこう'),
            ExamOption(id: 4, text: 'がっこう'),
          ],
        ),
      ],
    );
  }

  @override
  Future<ExamResult> submit(int id, Map<int, int> answers) async {
    submitted = Map.of(answers);
    return const ExamResult(
      correct: 1,
      total: 2,
      percent: 50,
      sections: [SectionResult(section: 'vocabulary', correct: 1, total: 2)],
      review: [
        ReviewItem(
          questionId: 10,
          selectedOptionId: 2,
          correctOptionId: 2,
          correct: true,
          explanation: '今日 đọc là きょう.',
        ),
        ReviewItem(
          questionId: 11,
          correct: false,
          correctOptionId: 4,
          explanation: '学校 đọc là がっこう.',
        ),
      ],
    );
  }
}

void main() {
  testWidgets('displays top bar categories, levels and filtered exam list', (
    tester,
  ) async {
    final service = _FakeMockExamService();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: MockExamTab(service: service))),
    );
    await tester.pumpAndSettle();

    expect(service.requestedLevels, ['N5']);
    expect(find.text('Thi thử'), findsOneWidget);
    expect(find.text('Bảng xếp hạng'), findsOneWidget);
    expect(find.text('Ngữ pháp'), findsOneWidget);
    expect(find.text('Từ vựng'), findsOneWidget);
    expect(find.text('JLPT'), findsOneWidget);
    expect(find.text('Danh sách đề thi'), findsOneWidget);

    // Chuyển sang tab "Từ vựng"
    await tester.tap(find.text('Từ vựng'));
    await tester.pumpAndSettle();
    expect(find.text('Test từ vựng N5 - Đề 1'), findsOneWidget);

    // Chuyển sang tab "JLPT"
    await tester.tap(find.text('JLPT'));
    await tester.pumpAndSettle();
    expect(find.text('Thi thử JLPT N5 - Đề 1'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);

    // Đổi sang level N4
    await tester.tap(find.text('N4'));
    await tester.pumpAndSettle();
    expect(service.requestedLevels, ['N5', 'N4']);
  });

  testWidgets('takes a test, submits and shows result with review', (
    tester,
  ) async {
    final service = _FakeMockExamService();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: MockExamTab(service: service))),
    );
    await tester.pumpAndSettle();

    // Chuyển sang tab Từ vựng để mở đề thi
    await tester.tap(find.text('Từ vựng'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test từ vựng N5 - Đề 1'));
    await tester.pumpAndSettle();

    expect(find.text('Câu 1/2'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);

    // Câu 1: chọn "きょう", sang câu 2 rồi bỏ trống và nộp.
    await tester.tap(find.text('きょう'));
    await tester.pump();
    await tester.tap(find.text('Câu sau'));
    await tester.pumpAndSettle();
    expect(find.text('Câu 2/2'), findsOneWidget);

    await tester.tap(find.text('Nộp bài'));
    await tester.pumpAndSettle();
    expect(find.textContaining('còn 1 câu chưa trả lời'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Nộp bài'));
    await tester.pumpAndSettle();

    expect(service.submitted, {10: 2});
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Đúng 1/2 câu'), findsOneWidget);
    expect(find.textContaining('Chưa trả lời'), findsOneWidget);
    expect(find.text('学校 đọc là がっこう.'), findsOneWidget);

    await tester.tap(find.text('Chỉ câu sai'));
    await tester.pumpAndSettle();
    expect(find.text('今日 đọc là きょう.'), findsNothing);
  });
}
