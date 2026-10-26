import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/features/alphabet/alphabet_page.dart';
import 'package:nihongo/features/alphabet/data/alphabet_local_data.dart';
import 'package:nihongo/features/alphabet/models/alphabet_models.dart';
import 'package:nihongo/features/dashboard/learn/library/library_view.dart';

void main() {
  group('Alphabet Local Data Tests', () {
    test('Hiragana contains 3 sections with correct column counts', () {
      final hira = AlphabetLocalData.getHiraganaAlphabet();
      expect(hira.script, 'hiragana');
      expect(hira.sections.length, 3);

      final gojuuon = hira.sections[0];
      expect(gojuuon.title, 'Gojuuon');
      expect(gojuuon.columns, 5);
      expect(gojuuon.grid.first.first?.character, 'あ');

      final dakuon = hira.sections[1];
      expect(dakuon.title, 'Dakuon & Handakuon');
      expect(dakuon.columns, 5);
      expect(dakuon.grid.first.first?.character, 'が');

      final youon = hira.sections[2];
      expect(youon.title, 'Youon');
      expect(youon.columns, 3);
      expect(youon.grid.first.first?.character, 'きゃ');
    });

    test('Katakana contains 3 sections with correct column counts', () {
      final kata = AlphabetLocalData.getKatakanaAlphabet();
      expect(kata.script, 'katakana');
      expect(kata.sections.length, 3);

      final gojuuon = kata.sections[0];
      expect(gojuuon.title, 'Gojuuon');
      expect(gojuuon.columns, 5);
      expect(gojuuon.grid.first.first?.character, 'ア');

      final dakuon = kata.sections[1];
      expect(dakuon.title, 'Dakuon & Handakuon');
      expect(dakuon.columns, 5);
      expect(dakuon.grid.first.first?.character, 'ガ');

      final youon = kata.sections[2];
      expect(youon.title, 'Youon');
      expect(youon.columns, 3);
      expect(youon.grid.first.first?.character, 'キャ');
    });
  });

  group('AlphabetPage Widget Tests', () {
    testWidgets('renders tabs and Gojuuon characters for Hiragana', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AlphabetPage(script: AlphabetScript.hiragana),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and tabs
      expect(find.text('Bảng chữ cái Hira'), findsOneWidget);
      expect(find.text('Gojuuon'), findsOneWidget);
      expect(find.text('Dakuon & Handakuon'), findsOneWidget);
      expect(find.text('Youon'), findsOneWidget);

      // Verify no "Phát tất cả" button exists
      expect(find.text('Phát tất cả'), findsNothing);

      // Verify character "あ"
      expect(find.text('あ'), findsOneWidget);

      // Switch to Dakuon tab
      await tester.tap(find.text('Dakuon & Handakuon'));
      await tester.pumpAndSettle();
      expect(find.text('が'), findsOneWidget);

      // Switch to Youon tab
      await tester.tap(find.text('Youon'));
      await tester.pumpAndSettle();
      expect(find.text('きゃ'), findsOneWidget);
    });

    testWidgets('LibraryView navigates to AlphabetPage on Hira tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LibraryView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Hira card
      final hiraCard = find.text('Hira');
      expect(hiraCard, findsOneWidget);
      await tester.tap(hiraCard);
      await tester.pumpAndSettle();

      // Verify opened AlphabetPage
      expect(find.text('Bảng chữ cái Hira'), findsOneWidget);
      expect(find.text('あ'), findsOneWidget);
    });

    testWidgets('LibraryView navigates to AlphabetPage on Kata tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LibraryView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Kata card
      final kataCard = find.text('Kata');
      expect(kataCard, findsOneWidget);
      await tester.tap(kataCard);
      await tester.pumpAndSettle();

      // Verify opened AlphabetPage
      expect(find.text('Bảng chữ cái Kata'), findsOneWidget);
      expect(find.text('ア'), findsOneWidget);
    });
  });
}
