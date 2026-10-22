import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/features/dashboard/learn_tab.dart';

void main() {
  testWidgets('LearnTab renders according to specifications', (tester) async {
    tester.view.physicalSize = const Size(1280, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LearnTab(
            onTopicTap: (_) {},
          ),
        ),
      ),
    );

    // 1. Header & Top Bar
    expect(find.text('Học tập'), findsOneWidget);
    expect(find.text('Nâng cấp'), findsNothing);

    // 2. Only 2 tabs
    expect(find.text('Sổ tay của tôi'), findsOneWidget);
    expect(find.text('Thư viện'), findsOneWidget);
    expect(find.text('Khám phá'), findsNothing);
    expect(find.text('Thi thử'), findsNothing);

    // 3. Tab "Sổ tay của tôi"
    expect(find.text('Tổng quan'), findsOneWidget);
    expect(find.text('Chưa thuộc'), findsOneWidget);
    expect(find.text('Thuộc lơ mơ'), findsOneWidget);
    expect(find.text('Thuộc kha khá'), findsOneWidget);
    expect(find.text('Thuộc làu làu'), findsOneWidget);
    expect(find.text('Ôn tập sổ tay'), findsOneWidget);

    // Đã bỏ "Học lặp lại ngắt quãng" và "Danh sách sổ tay"
    expect(find.text('Học lặp lại ngắt quãng'), findsNothing);
    expect(find.text('Danh sách sổ tay'), findsNothing);

    // 4. Chuyển sang tab "Thư viện"
    await tester.tap(find.text('Thư viện'));
    await tester.pumpAndSettle();

    // Bảng chữ cái
    expect(find.text('Bảng chữ cái'), findsOneWidget);
    expect(find.text('Hira'), findsOneWidget);
    expect(find.text('Kata'), findsOneWidget);
    expect(find.text('あ'), findsOneWidget);
    expect(find.text('ア'), findsOneWidget);

    // JLPT
    expect(find.text('JLPT'), findsOneWidget);
    expect(find.text('Từ vựng N4'), findsOneWidget);
    expect(find.text('523 từ'), findsOneWidget);
    expect(find.text('Ngữ pháp N4'), findsOneWidget);
    expect(find.text('436 từ'), findsOneWidget);
    expect(find.text('Hán tự N4'), findsOneWidget);
    expect(find.text('167 từ'), findsOneWidget);
    expect(find.text('Từ vựng N5'), findsOneWidget);
    expect(find.text('571 từ'), findsOneWidget);

    // Chuyên ngành
    expect(find.text('Chuyên ngành'), findsOneWidget);
    expect(find.text('Xem thêm'), findsOneWidget);
    expect(find.text('Xe cộ'), findsOneWidget);
    expect(find.text('4 mục'), findsOneWidget);
    expect(find.text('Vật liệu điện và nước'), findsOneWidget);
    expect(find.text('6 mục'), findsOneWidget);
    expect(find.text('Thợ cơ khí'), findsOneWidget);
    expect(find.text('7 mục'), findsOneWidget);
    expect(find.text('Lối sống'), findsOneWidget);
    expect(find.text('12 mục'), findsOneWidget);

    // Khác
    expect(find.text('Khác'), findsOneWidget);
  });
}
