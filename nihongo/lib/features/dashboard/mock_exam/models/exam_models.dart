/// Loại đề: test nhanh từ vựng / ngữ pháp, hoặc đề thi thử theo cấu trúc JLPT.
enum ExamType {
  vocabulary('vocabulary'),
  grammar('grammar'),
  jlpt('jlpt');

  const ExamType(this.code);
  final String code;

  static ExamType fromCode(String? code) {
    for (final t in values) {
      if (t.code == code) return t;
    }
    return ExamType.jlpt;
  }
}

/// Phần thi trong đề JLPT. Phần nghe (聴解) chưa có vì app chưa có audio.
String examSectionLabel(String section) {
  switch (section) {
    case 'vocabulary':
      return '文字・語彙 · Từ vựng';
    case 'grammar':
      return '文法 · Ngữ pháp';
    case 'reading':
      return '読解 · Đọc hiểu';
    case 'listening':
      return '聴解 · Nghe hiểu';
    default:
      return section;
  }
}

class ExamSummary {
  const ExamSummary({
    required this.id,
    required this.title,
    required this.level,
    required this.type,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.attempts,
    required this.bestPercent,
  });

  final int id;
  final String title;
  final String level;
  final ExamType type;
  final int durationMinutes;
  final int totalQuestions;
  final int attempts;
  final int bestPercent;

  factory ExamSummary.fromJson(Map<String, dynamic> json) {
    return ExamSummary(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      level: json['level'] as String? ?? '',
      type: ExamType.fromCode(json['type'] as String?),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      bestPercent: (json['bestPercent'] as num?)?.toInt() ?? 0,
    );
  }
}

class ExamOption {
  const ExamOption({required this.id, required this.text});

  final int id;
  final String text;

  factory ExamOption.fromJson(Map<String, dynamic> json) {
    return ExamOption(
      id: (json['id'] as num).toInt(),
      text: json['text'] as String? ?? '',
    );
  }
}

class ExamQuestion {
  const ExamQuestion({
    required this.id,
    required this.section,
    required this.text,
    required this.options,
    this.passage,
  });

  final int id;
  final String section;
  final String text;
  final String? passage;
  final List<ExamOption> options;

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? const [];
    return ExamQuestion(
      id: (json['id'] as num).toInt(),
      section: json['section'] as String? ?? '',
      text: json['text'] as String? ?? '',
      passage: json['passage'] as String?,
      options: rawOptions
          .whereType<Map<String, dynamic>>()
          .map(ExamOption.fromJson)
          .toList(),
    );
  }
}

class ExamDetail {
  const ExamDetail({
    required this.id,
    required this.title,
    required this.level,
    required this.type,
    required this.durationMinutes,
    required this.questions,
  });

  final int id;
  final String title;
  final String level;
  final ExamType type;
  final int durationMinutes;
  final List<ExamQuestion> questions;

  factory ExamDetail.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? const [];
    return ExamDetail(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      level: json['level'] as String? ?? '',
      type: ExamType.fromCode(json['type'] as String?),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      questions: rawQuestions
          .whereType<Map<String, dynamic>>()
          .map(ExamQuestion.fromJson)
          .toList(),
    );
  }
}

class SectionResult {
  const SectionResult({
    required this.section,
    required this.correct,
    required this.total,
  });

  final String section;
  final int correct;
  final int total;

  factory SectionResult.fromJson(Map<String, dynamic> json) {
    return SectionResult(
      section: json['section'] as String? ?? '',
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class ReviewItem {
  const ReviewItem({
    required this.questionId,
    required this.correct,
    this.selectedOptionId,
    this.correctOptionId,
    this.explanation,
  });

  final int questionId;
  final int? selectedOptionId;
  final int? correctOptionId;
  final bool correct;
  final String? explanation;

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      questionId: (json['questionId'] as num).toInt(),
      selectedOptionId: (json['selectedOptionId'] as num?)?.toInt(),
      correctOptionId: (json['correctOptionId'] as num?)?.toInt(),
      correct: json['correct'] as bool? ?? false,
      explanation: json['explanation'] as String?,
    );
  }
}

class ExamResult {
  const ExamResult({
    required this.correct,
    required this.total,
    required this.percent,
    required this.sections,
    required this.review,
  });

  final int correct;
  final int total;
  final int percent;
  final List<SectionResult> sections;
  final List<ReviewItem> review;

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'] as List<dynamic>? ?? const [];
    final rawReview = json['review'] as List<dynamic>? ?? const [];
    return ExamResult(
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      sections: rawSections
          .whereType<Map<String, dynamic>>()
          .map(SectionResult.fromJson)
          .toList(),
      review: rawReview
          .whereType<Map<String, dynamic>>()
          .map(ReviewItem.fromJson)
          .toList(),
    );
  }
}
