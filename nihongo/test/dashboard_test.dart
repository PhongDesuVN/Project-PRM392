import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nihongo/features/dashboard/dashboard_page.dart';

// JapaneseBackground co animation lap vo han nen dung pump(duration)
// thay vi pumpAndSettle.
void main() {
  Future<void> pumpDashboard(WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1280, 2000);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

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
    expect(find.text('Hiragana'), findsOneWidget);
    expect(find.text('Katakana'), findsOneWidget);
    expect(find.text('Kanji'), findsOneWidget);
  });

  testWidgets('tapping a topic opens the lesson detail screen', (tester) async {
    await pumpDashboard(tester);

    final hiraganaTarget = find.byKey(const ValueKey('topic_Hiragana'));
    await tester.tap(hiraganaTarget);
    await tester.pumpAndSettle();

    expect(find.text('Hiragana'), findsWidgets);
    expect(find.text('Bắt đầu luyện tập'), findsOneWidget);
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

    expect(
      find.text('Bài học Hiragana, Katakana, Kanji và từ vựng sẽ có ở đây.'),
      findsOneWidget,
    );
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
}
