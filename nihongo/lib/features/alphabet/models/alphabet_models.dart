/// Models cho Bảng chữ cái tiếng Nhật (Hiragana / Katakana)
enum AlphabetScript {
  hiragana,
  katakana;

  String get key => name;
  String get displayName => this == AlphabetScript.hiragana ? 'Hira' : 'Kata';
  String get fullTitle => 'Bảng chữ cái $displayName';
}

/// Một ô ký tự trong bảng chữ cái
class AlphabetItem {
  const AlphabetItem({
    required this.character,
    required this.romaji,
  });

  final String character;
  final String romaji;

  factory AlphabetItem.fromJson(Map<String, dynamic> json) {
    return AlphabetItem(
      character: json['character'] as String? ?? '',
      romaji: json['romaji'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'character': character,
        'romaji': romaji,
      };
}

/// Một phần phân loại của bảng chữ cái (Gojuuon, Dakuon & Handakuon, Youon)
class AlphabetSection {
  const AlphabetSection({
    required this.type,
    required this.title,
    required this.columns,
    required this.grid,
  });

  final String type;
  final String title;
  final int columns;
  final List<List<AlphabetItem?>> grid;

  factory AlphabetSection.fromJson(Map<String, dynamic> json) {
    final rawGrid = json['grid'] as List? ?? const [];
    final parsedGrid = <List<AlphabetItem?>>[];

    for (final row in rawGrid) {
      if (row is List) {
        final parsedRow = <AlphabetItem?>[];
        for (final cell in row) {
          if (cell != null && cell is Map<String, dynamic>) {
            parsedRow.add(AlphabetItem.fromJson(cell));
          } else if (cell != null && cell is Map) {
            parsedRow.add(AlphabetItem.fromJson(Map<String, dynamic>.from(cell)));
          } else {
            parsedRow.add(null);
          }
        }
        parsedGrid.add(parsedRow);
      }
    }

    return AlphabetSection(
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      columns: json['columns'] as int? ?? 5,
      grid: parsedGrid,
    );
  }
}

/// Kết quả đầy đủ của bảng chữ cái từ Backend hoặc Local Data
class AlphabetResponse {
  const AlphabetResponse({
    required this.script,
    required this.title,
    required this.sections,
  });

  final String script;
  final String title;
  final List<AlphabetSection> sections;

  factory AlphabetResponse.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'] as List? ?? const [];
    final sectionsList = <AlphabetSection>[];

    for (final sec in rawSections) {
      if (sec is Map<String, dynamic>) {
        sectionsList.add(AlphabetSection.fromJson(sec));
      } else if (sec is Map) {
        sectionsList.add(AlphabetSection.fromJson(Map<String, dynamic>.from(sec)));
      }
    }

    return AlphabetResponse(
      script: json['script'] as String? ?? '',
      title: json['title'] as String? ?? '',
      sections: sectionsList,
    );
  }
}
