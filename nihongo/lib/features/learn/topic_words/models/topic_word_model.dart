/// Model đại diện cho một từ vựng / mục học tập trong chủ đề
class TopicWord {
  const TopicWord({
    required this.id,
    required this.topicCode,
    required this.word,
    required this.reading,
    this.romaji,
    required this.meaning,
    this.exampleJp,
    this.exampleVi,
    this.displayOrder = 0,
  });

  final int id;
  final String topicCode;
  final String word;
  final String reading;
  final String? romaji;
  final String meaning;
  final String? exampleJp;
  final String? exampleVi;
  final int displayOrder;

  factory TopicWord.fromJson(Map<String, dynamic> json) {
    return TopicWord(
      id: json['id'] as int? ?? 0,
      topicCode: json['topicCode'] as String? ?? '',
      word: json['word'] as String? ?? '',
      reading: json['reading'] as String? ?? '',
      romaji: json['romaji'] as String?,
      meaning: json['meaning'] as String? ?? '',
      exampleJp: json['exampleJp'] as String?,
      exampleVi: json['exampleVi'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'topicCode': topicCode,
    'word': word,
    'reading': reading,
    'romaji': romaji,
    'meaning': meaning,
    'exampleJp': exampleJp,
    'exampleVi': exampleVi,
    'displayOrder': displayOrder,
  };
}

/// Model phản hồi khi lấy danh sách từ theo chủ đề
class TopicWordsResponse {
  const TopicWordsResponse({
    required this.topicCode,
    required this.title,
    required this.totalWords,
    required this.words,
  });

  final String topicCode;
  final String title;
  final int totalWords;
  final List<TopicWord> words;

  factory TopicWordsResponse.fromJson(Map<String, dynamic> json) {
    final rawWords = json['words'] as List<dynamic>? ?? [];
    return TopicWordsResponse(
      topicCode: json['topicCode'] as String? ?? '',
      title: json['title'] as String? ?? '',
      totalWords: json['totalWords'] as int? ?? rawWords.length,
      words: rawWords
          .whereType<Map<String, dynamic>>()
          .map(TopicWord.fromJson)
          .toList(),
    );
  }
}
