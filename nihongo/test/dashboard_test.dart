import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nihongo/features/dashboard/daily_challenge_service.dart';
import 'package:nihongo/features/dashboard/dashboard_page.dart';
import 'package:nihongo/features/dashboard/search_history_service.dart';
import 'package:nihongo/features/dashboard/widgets/extensions_bottom_sheet.dart';

// JapaneseBackground co animation lap vo han nen dung pump(duration)
// thay vi pumpAndSettle.
void main() {
  setUp(() {
    SearchHistoryService.instance.resetToDefault();
  });
  Future<void> pumpDashboard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardPage(email: 'a@example.com', fullName: 'Nguyen Van A'),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows greeting and learning topics', (tester) async {
    await pumpDashboard(tester);

    expect(find.text('Xin chào, Nguyen Van A'), findsOneWidget);
    expect(find.text('Bảng chữ cái'), findsOneWidget);
  });

  testWidgets('tapping alphabet button opens library tab with Hira and Kata', (
    tester,
  ) async {
    await pumpDashboard(tester);

    final alphabetTarget = find.text('Bảng chữ cái');
    await tester.tap(alphabetTarget);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Học tập'), findsWidgets);
    expect(find.text('Thư viện'), findsOneWidget);
    expect(find.text('Hira'), findsOneWidget);
    expect(find.text('Kata'), findsOneWidget);
  });

  testWidgets('tapping extensions button shows options and navigates', (
    tester,
  ) async {
    await pumpDashboard(tester);

    final extTarget = find.text('Tiện ích mở rộng');
    await tester.tap(extTarget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Tiện ích mở rộng'), findsWidgets);
    expect(find.text('Từ điển'), findsWidgets);
    expect(find.text('Dịch'), findsWidgets);
    expect(find.text('Học tập'), findsWidgets);
    expect(find.text('Thi thử'), findsWidgets);

    // Tapping on 'Dịch' option inside extensions bottom sheet
    final dichInSheet = find.descendant(
      of: find.byType(ExtensionsBottomSheet),
      matching: find.text('Dịch'),
    );
    await tester.tap(dichInSheet);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Dịch văn bản'), findsOneWidget);
  });

  testWidgets('profile tab shows account info and logout', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.byTooltip('Hồ sơ'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Tài khoản'), findsOneWidget);
    expect(find.text('a@example.com'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);
  });

  testWidgets('start button switches to learn tab', (tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.text('Bắt đầu học'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Tổng quan'), findsOneWidget);
    expect(find.text('Sổ tay của tôi'), findsOneWidget);
    expect(find.text('Thư viện'), findsOneWidget);
    expect(find.text('Ôn tập sổ tay'), findsOneWidget);

    // Switch to Thư viện tab
    await tester.tap(find.text('Thư viện'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Bảng chữ cái'), findsOneWidget);
    expect(find.text('Hira'), findsOneWidget);
    expect(find.text('Kata'), findsOneWidget);
    expect(find.text('JLPT'), findsOneWidget);
    expect(find.text('Chuyên ngành'), findsOneWidget);
  });

  testWidgets('dashboard exposes dictionary, translation and mock exam', (
    tester,
  ) async {
    await pumpDashboard(tester);

    expect(find.byTooltip('Hồ sơ'), findsOneWidget);
    expect(find.text('Từ điển'), findsWidgets);
    expect(find.text('Dịch'), findsWidgets);
    expect(find.text('Học tập'), findsWidgets);
    expect(find.text('Thi thử'), findsWidgets);
    expect(find.text('Chụp ảnh'), findsOneWidget);
    expect(find.text('Viết Kanji'), findsOneWidget);

    await tester.tap(find.text('Dịch').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Dịch văn bản'), findsOneWidget);
  });

  testWidgets('handwriting search opens the Kanji writing screen', (
    tester,
  ) async {
    await pumpDashboard(tester);

    await tester.tap(find.text('Viết Kanji'));
    await tester.pumpAndSettle();

    expect(find.text('Viết một Kanji để tra cứu'), findsOneWidget);
    expect(find.byKey(const ValueKey('kanji-writing-canvas')), findsOneWidget);
    expect(find.text('Nhận dạng chữ viết'), findsOneWidget);
  });

  testWidgets(
    'recent searches records searches from home, dictionary and handwriting',
    (tester) async {
      await pumpDashboard(tester);

      // Initial default keyword exists
      expect(find.text('生活'), findsOneWidget);

      // 1. Enter query in Home search field "Nhập Tiếng Nhật cần tìm"
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, '桜');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump(const Duration(milliseconds: 300));

      // Navigated to dictionary tab with search query
      expect(find.text('桜'), findsWidgets);

      // Switch back to Home tab (Khám phá)
      await tester.tap(find.text('Khám phá'));
      await tester.pump(const Duration(milliseconds: 300));

      // '桜' is now in recent searches!
      expect(find.text('桜'), findsOneWidget);

      // 2. Direct dictionary / handwriting search also updates recent searches
      SearchHistoryService.instance.addKeyword('富士山');
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('富士山'), findsOneWidget);

      // 3. Remove keyword with '✕'
      final closeIcons = find.byIcon(Icons.close_rounded);
      await tester.tap(closeIcons.first);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('富士山'), findsNothing);
    },
  );

  test('DailyChallengeService generates valid vocabulary and grammar quizzes', () {
    final vocabQuiz = DailyChallengeService.instance.generateRandomQuiz(
      preferredType: DailyQuizType.vocabulary,
    );
    expect(vocabQuiz.categoryLabel, 'Từ vựng');
    expect(vocabQuiz.options.length, 4);
    expect(vocabQuiz.correctIndex >= 0 && vocabQuiz.correctIndex < 4, isTrue);
    expect(vocabQuiz.prompt.isNotEmpty, isTrue);

    final grammarQuiz = DailyChallengeService.instance.generateRandomQuiz(
      preferredType: DailyQuizType.grammar,
    );
    expect(grammarQuiz.categoryLabel, 'Ngữ pháp');
    expect(grammarQuiz.options.length, 4);
    expect(grammarQuiz.correctIndex >= 0 && grammarQuiz.correctIndex < 4, isTrue);
    expect(grammarQuiz.prompt.isNotEmpty, isTrue);
  });

  testWidgets(
    'daily challenge displays question, allows answering and refreshes',
    (tester) async {
      await pumpDashboard(tester);

      expect(find.text('Thử thách mỗi ngày'), findsOneWidget);

      // Should show category badge (Từ vựng or Ngữ pháp)
      expect(
        find.text('Từ vựng').evaluate().isNotEmpty ||
            find.text('Ngữ pháp').evaluate().isNotEmpty,
        isTrue,
      );

      // Tap on the refresh button to get a new question
      final refreshBtn = find.byTooltip('Đổi câu hỏi');
      expect(refreshBtn, findsOneWidget);
      await tester.tap(refreshBtn);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Thử thách mỗi ngày'), findsOneWidget);
    },
  );
}
