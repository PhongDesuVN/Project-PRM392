import '../../../core/api.dart';
import '../../auth/auth_service.dart';

class DictionaryMeaning {
  const DictionaryMeaning({
    required this.text,
    this.languageCode,
    this.partOfSpeech,
  });

  final String text;
  final String? languageCode;
  final String? partOfSpeech;

  factory DictionaryMeaning.fromJson(Map<String, dynamic> json) =>
      DictionaryMeaning(
        text: json['text'] as String? ?? '',
        languageCode: json['languageCode'] as String?,
        partOfSpeech: json['partOfSpeech'] as String?,
      );
}

class DictionaryKanji {
  const DictionaryKanji({
    required this.character,
    this.hanViet,
    this.strokeCount,
    this.meaning,
  });

  final String character;
  final String? hanViet;
  final int? strokeCount;
  final String? meaning;

  factory DictionaryKanji.fromJson(Map<String, dynamic> json) =>
      DictionaryKanji(
        character: json['character'] as String? ?? '',
        hanViet: json['hanViet'] as String?,
        strokeCount: json['strokeCount'] as int?,
        meaning: json['meaning'] as String?,
      );
}

class DictionaryEntry {
  const DictionaryEntry({
    required this.word,
    required this.reading,
    required this.meanings,
    required this.kanjis,
    this.romaji,
    this.jlptLevel,
  });

  final String word;
  final String reading;
  final String? romaji;
  final String? jlptLevel;
  final List<DictionaryMeaning> meanings;
  final List<DictionaryKanji> kanjis;

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) =>
      DictionaryEntry(
        word: json['word'] as String? ?? '',
        reading: json['reading'] as String? ?? '',
        romaji: json['romaji'] as String?,
        jlptLevel: json['jlptLevel'] as String?,
        meanings: _jsonObjects(json['meanings'])
            .map(DictionaryMeaning.fromJson)
            .toList(),
        kanjis: _jsonObjects(json['kanjis'])
            .map(DictionaryKanji.fromJson)
            .toList(),
      );
}

List<Map<String, dynamic>> _jsonObjects(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

class DictionaryService {
  DictionaryService({ApiClient? apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<List<DictionaryEntry>> search(String query) async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.trim().isEmpty) {
      throw ApiException('Bạn cần đăng nhập lại để tra cứu từ.');
    }

    final response = await _apiClient.get(
      ApiConfig.dictionarySearch,
      queryParameters: {'q': query.trim(), 'lang': 'vi', 'limit': '20'},
      bearerToken: token,
    );
    final results = response['results'];
    if (results is! List) {
      throw ApiException('Dữ liệu từ điển trả về không hợp lệ.');
    }
    return _jsonObjects(results).map(DictionaryEntry.fromJson).toList();
  }

  void dispose() => _apiClient.dispose();
}
