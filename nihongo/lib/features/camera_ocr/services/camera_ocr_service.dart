import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../models/ocr_scan_result.dart';

/// Dịch vụ xử lý máy ảnh và nhận diện văn bản tiếng Nhật
/// Chạy mô hình AI 100% trên Frontend thiết bị (Google ML Kit on-device Vision)
class CameraOcrService {
  CameraOcrService({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;
  TextRecognizer? _textRecognizer;

  /// Khởi tạo model AI nhận diện tiếng Nhật
  TextRecognizer get _recognizer {
    return _textRecognizer ??= TextRecognizer(
      script: TextRecognitionScript.japanese,
    );
  }

  /// Chụp ảnh từ Camera thiết bị
  Future<String?> capturePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 92,
      );
      return photo?.path;
    } catch (e) {
      debugPrint('Lỗi khi mở camera: $e');
      return null;
    }
  }

  /// Chọn ảnh có sẵn từ Thư viện (Gallery)
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      return photo?.path;
    } catch (e) {
      debugPrint('Lỗi khi chọn ảnh từ thư viện: $e');
      return null;
    }
  }

  /// Phân tích văn bản trong ảnh bằng mô hình AI On-Device
  Future<OcrScanResult> recognizeTextFromImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      return OcrScanResult.empty(imagePath);
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      RecognizedText recognizedText;
      try {
        recognizedText = await _recognizer.processImage(inputImage);
      } catch (e) {
        debugPrint('Lỗi với Japanese TextRecognizer: $e, thử lại với Latin fallback');
        final fallbackRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        try {
          recognizedText = await fallbackRecognizer.processImage(inputImage);
        } finally {
          await fallbackRecognizer.close();
        }
      }

      final fullText = recognizedText.text.trim();
      final lines = <String>[];
      final detectedWords = <OcrWordCandidate>[];
      final seenWords = <String>{};

      // Tách theo từng dòng nhận diện
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final lineText = line.text.trim();
          if (lineText.isNotEmpty && !lines.contains(lineText)) {
            lines.add(lineText);
          }

          // Bóc tách các từ/cụm từ tiếng Nhật (Hiragana, Katakana, Kanji)
          _extractJapaneseTokens(lineText, detectedWords, seenWords);
        }
      }

      // Nếu không tách được theo dòng, thử tách từ fullText
      if (detectedWords.isEmpty && fullText.isNotEmpty) {
        _extractJapaneseTokens(fullText, detectedWords, seenWords);
      }

      return OcrScanResult(
        imagePath: imagePath,
        fullText: fullText,
        lines: lines,
        detectedWords: detectedWords,
        scannedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Lỗi AI nhận diện văn bản: $e');
      return OcrScanResult.empty(imagePath);
    }
  }

  /// Bóc tách từ tiếng Nhật và phân loại theo bảng chữ cái
  void _extractJapaneseTokens(
    String rawText,
    List<OcrWordCandidate> detectedWords,
    Set<String> seenWords,
  ) {
    // Regex bắt các cụm ký tự tiếng Nhật (Hiragana, Katakana, Kanji)
    final japaneseRegex = RegExp(
      r'[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9faf]+',
    );

    for (final match in japaneseRegex.allMatches(rawText)) {
      final token = match.group(0)?.trim() ?? '';
      if (token.isNotEmpty && seenWords.add(token)) {
        detectedWords.add(OcrWordCandidate.analyze(token));
      }
    }
  }

  /// Giải phóng tài nguyên model AI khi đóng màn hình
  Future<void> dispose() async {
    await _textRecognizer?.close();
    _textRecognizer = null;
  }
}

