import 'package:flutter/services.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  final _modelManager = OnDeviceTranslatorModelManager();

  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    void Function(String message)? onStatus,
  }) async {
    final source = _languageForCode(sourceLanguage);
    final target = _languageForCode(targetLanguage);

    try {
      await _ensureModel(source, onStatus);
      await _ensureModel(target, onStatus);

      onStatus?.call('Đang dịch...');
      final translator = OnDeviceTranslator(
        sourceLanguage: source,
        targetLanguage: target,
      );
      try {
        return await translator.translateText(text.trim());
      } finally {
        await translator.close();
      }
    } on PlatformException {
      throw TranslationException(
        'Không thể tải hoặc chạy mô hình dịch. Hãy kiểm tra kết nối Internet, dung lượng trống và Google Play services trên Android.',
      );
    } on MissingPluginException {
      throw TranslationException(
        'Không tìm thấy ML Kit trên thiết bị này. Hãy chạy lại ứng dụng trên Android hoặc iOS.',
      );
    }
  }

  Future<void> _ensureModel(
    TranslateLanguage language,
    void Function(String message)? onStatus,
  ) async {
    if (await _modelManager.isModelDownloaded(language.bcpCode)) return;

    onStatus?.call('Đang tải mô hình ${_languageName(language)}...');
    final downloaded = await _modelManager.downloadModel(language.bcpCode);
    if (!downloaded) {
      throw TranslationException(
        'Chưa tải được mô hình ${_languageName(language)}. Hãy kết nối Wi-Fi rồi thử lại.',
      );
    }
  }

  TranslateLanguage _languageForCode(String code) => switch (code) {
    'ja' => TranslateLanguage.japanese,
    'vi' => TranslateLanguage.vietnamese,
    _ => throw ArgumentError.value(code, 'code', 'Ngôn ngữ không được hỗ trợ'),
  };

  String _languageName(TranslateLanguage language) => switch (language) {
    TranslateLanguage.japanese => 'tiếng Nhật',
    TranslateLanguage.vietnamese => 'tiếng Việt',
    _ => language.name,
  };
}

class TranslationException implements Exception {
  const TranslationException(this.message);

  final String message;

  @override
  String toString() => message;
}
