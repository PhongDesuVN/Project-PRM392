import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nihongo/features/dashboard/dashboard_page.dart';

// JapaneseBackground co animation lap vo han nen dung pump(duration)
// thay vi pumpAndSettle.
void main() {
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

  testWidgets('tapping a topic opens the lesson detail screen', (tester) async {
    await pumpDashboard(tester);

    final alphabetTarget = find.text('Bảng chữ cái');
    await tester.tap(alphabetTarget);
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
}
