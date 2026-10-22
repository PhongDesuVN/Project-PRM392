import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/features/dashboard/dictionary/kanji_handwriting_page.dart';

void main() {
  testWidgets('drawing enables recognition and undo removes the last stroke', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: KanjiHandwritingPage()));

    final canvas = find.byKey(const ValueKey('kanji-writing-canvas'));
    await tester.dragFrom(
      tester.getTopLeft(canvas) + const Offset(80, 80),
      const Offset(0, 80),
    );
    await tester.pump();

    var recognizeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Nhận dạng chữ viết'),
    );
    expect(recognizeButton.onPressed, isNotNull);

    await tester.tap(find.byTooltip('Hoàn tác nét cuối'));
    await tester.pump();

    recognizeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Nhận dạng chữ viết'),
    );
    expect(recognizeButton.onPressed, isNull);
  });

  testWidgets('recognition presents candidates for dictionary lookup', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const channel = MethodChannel('google_mlkit_digital_ink_recognizer');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'vision#manageInkModels':
              return true;
            case 'vision#startDigitalInkRecognizer':
              return [
                {'text': '日', 'score': 0.0},
                {'text': '目', 'score': 0.1},
              ];
            default:
              return null;
          }
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    await tester.pumpWidget(const MaterialApp(home: KanjiHandwritingPage()));
    await tester.dragFrom(
      tester.getTopLeft(find.byKey(const ValueKey('kanji-writing-canvas'))) +
          const Offset(80, 80),
      const Offset(0, 80),
    );
    await tester.pump();

    await tester.tap(find.text('Nhận dạng chữ viết'));
    await tester.pumpAndSettle();

    expect(find.text('Chọn kết quả phù hợp'), findsOneWidget);
    expect(find.text('日'), findsOneWidget);
    expect(find.text('目'), findsOneWidget);
    expect(find.text('Tra cứu “日”'), findsOneWidget);
  });

  testWidgets('slow recognizer cleanup does not keep results loading', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const channel = MethodChannel('google_mlkit_digital_ink_recognizer');
    final pendingClose = Completer<Object?>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'vision#manageInkModels':
              return true;
            case 'vision#startDigitalInkRecognizer':
              return [
                {'text': '日', 'score': 0.0},
              ];
            case 'vision#closeDigitalInkRecognizer':
              return pendingClose.future;
            default:
              return null;
          }
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    await tester.pumpWidget(const MaterialApp(home: KanjiHandwritingPage()));
    await tester.dragFrom(
      tester.getTopLeft(find.byKey(const ValueKey('kanji-writing-canvas'))) +
          const Offset(80, 80),
      const Offset(0, 80),
    );
    await tester.pump();
    await tester.tap(find.text('Nhận dạng chữ viết'));
    await tester.pumpAndSettle();

    expect(find.text('Tra cứu “日”'), findsOneWidget);
    expect(find.text('Đang nhận dạng nét viết...'), findsNothing);
    final recognizeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Nhận dạng chữ viết'),
    );
    expect(recognizeButton.onPressed, isNotNull);

    await tester.pump(const Duration(seconds: 3));
    expect(
      find.text(
        'Đã nhận dạng xong, nhưng bộ nhận dạng phản hồi chậm khi đóng.',
      ),
      findsOneWidget,
    );
    pendingClose.complete(null);
  });

  testWidgets('recognition timeout shows an actionable error', (tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const channel = MethodChannel('google_mlkit_digital_ink_recognizer');
    final pendingRecognition = Completer<Object?>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          switch (call.method) {
            case 'vision#manageInkModels':
              return true;
            case 'vision#startDigitalInkRecognizer':
              return pendingRecognition.future;
            default:
              return null;
          }
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    await tester.pumpWidget(const MaterialApp(home: KanjiHandwritingPage()));
    await tester.dragFrom(
      tester.getTopLeft(find.byKey(const ValueKey('kanji-writing-canvas'))) +
          const Offset(80, 80),
      const Offset(0, 80),
    );
    await tester.pump();
    await tester.tap(find.text('Nhận dạng chữ viết'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 16));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(
      find.text(
        'Nhận dạng quá lâu. Hãy thử lại với ít nét hơn hoặc khởi động lại ứng dụng.',
      ),
      findsOneWidget,
    );
    final retryButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Nhận dạng chữ viết'),
    );
    expect(retryButton.onPressed, isNotNull);
  });
}
