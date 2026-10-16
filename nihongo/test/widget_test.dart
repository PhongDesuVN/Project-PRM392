// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:nihongo/main.dart';

void main() {
  testWidgets('shows login and opens registration', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Đăng nhập với Apple'), findsNothing);
    expect(find.text('Đăng nhập với Google'), findsOneWidget);

    await tester.ensureVisible(find.text('Đăng kí'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng kí'));
    await tester.pumpAndSettle();

    expect(find.text('Tạo tài khoản'), findsOneWidget);
    expect(find.text('Nhập lại mật khẩu'), findsOneWidget);
  });

  testWidgets('opens forgot password dialog', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Quên mật khẩu?'));
    await tester.pumpAndSettle();

    expect(find.text('Nhập email tài khoản Mazii của bạn'), findsOneWidget);
    expect(find.text('Hủy'), findsOneWidget);
  });
}
