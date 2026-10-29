import 'dart:math';

import '../learn/topic_words/data/topic_local_data.dart';
import '../learn/topic_words/models/topic_word_model.dart';

/// Phân loại câu hỏi trong Thử thách mỗi ngày
enum DailyQuizType {
  vocabulary('Từ vựng'),
  grammar('Ngữ pháp');

  const DailyQuizType(this.label);
  final String label;
}

/// Dữ liệu một câu hỏi trong Thử thách mỗi ngày
class DailyChallengeQuiz {
  const DailyChallengeQuiz({
    required this.prompt,
    required this.subtitle,
    required this.categoryLabel,
    required this.type,
    required this.options,
    required this.correctIndex,
  });

  /// Chữ Hán, từ vựng hoặc cấu trúc ngữ pháp cần hỏi
  final String prompt;

  /// Cách đọc, Furigana hoặc cấu trúc sử dụng
  final String subtitle;

  /// Nhãn phân loại: "Từ vựng" hoặc "Ngữ pháp"
  final String categoryLabel;

  final DailyQuizType type;

  /// 4 phương án lựa chọn (đã được random vị trí)
  final List<String> options;

  /// Vị trí đáp án đúng trong [options] (0..3)
  final int correctIndex;
}

/// Service tạo câu hỏi và câu trả lời ngẫu nhiên từ kho dữ liệu Từ vựng và Ngữ pháp
class DailyChallengeService {
  DailyChallengeService._();
  static final DailyChallengeService instance = DailyChallengeService._();

  final Random _random = Random();

  /// Sinh một câu hỏi thử thách ngẫu nhiên
  DailyChallengeQuiz generateRandomQuiz({DailyQuizType? preferredType}) {
    final vocabPool = _getVocabularyPool();
    final grammarPool = _getGrammarPool();

    // Random loại câu hỏi (Từ vựng hoặc Ngữ pháp)
    final type = preferredType ??
        (_random.nextBool() ? DailyQuizType.vocabulary : DailyQuizType.grammar);

    final targetPool = type == DailyQuizType.grammar ? grammarPool : vocabPool;
    final otherPool = type == DailyQuizType.grammar ? vocabPool : grammarPool;

    // Chọn ngẫu nhiên 1 mục làm câu hỏi chính
    final target = targetPool[_random.nextInt(targetPool.length)];
    final correctAnswer = _cleanMeaning(target.meaning);

    // Thu thập 3 đáp án sai gây nhiễu (distractors)
    final distractorSet = <String>{};

    // 1. Ưu tiên lấy từ cùng thể loại để tăng tính thử thách
    final shuffledTarget = List<TopicWord>.from(targetPool)..shuffle(_random);
    for (final item in shuffledTarget) {
      if (item.id != target.id && item.word != target.word) {
        final meaning = _cleanMeaning(item.meaning);
        if (meaning.isNotEmpty && meaning != correctAnswer) {
          distractorSet.add(meaning);
          if (distractorSet.length >= 3) break;
        }
      }
    }

    // 2. Nếu chưa đủ 3 đáp án nhiễu, bổ sung từ thể loại còn lại
    if (distractorSet.length < 3) {
      final shuffledOther = List<TopicWord>.from(otherPool)..shuffle(_random);
      for (final item in shuffledOther) {
        final meaning = _cleanMeaning(item.meaning);
        if (meaning.isNotEmpty && meaning != correctAnswer) {
          distractorSet.add(meaning);
          if (distractorSet.length >= 3) break;
        }
      }
    }

    // Tạo danh sách 4 lựa chọn và xáo trộn ngẫu nhiên
    final options = [correctAnswer, ...distractorSet.take(3)]..shuffle(_random);
    final correctIndex = options.indexOf(correctAnswer);

    // Chuẩn hóa phụ đề (reading hoặc cách dùng)
    var subtitle = target.reading.trim();
    if (subtitle.isEmpty) {
      if (target.romaji != null && target.romaji!.isNotEmpty) {
        subtitle = '「 ${target.romaji} 」';
      } else {
        subtitle = '「 ${type.label} 」';
      }
    } else if (!subtitle.startsWith('「')) {
      subtitle = '「 $subtitle 」';
    }

    return DailyChallengeQuiz(
      prompt: target.word,
      subtitle: subtitle,
      categoryLabel: type.label,
      type: type,
      options: options,
      correctIndex: correctIndex,
    );
  }

  List<TopicWord> _getVocabularyPool() {
    final list = <TopicWord>[];
    list.addAll(TopicLocalData.getWords('tu_vung_n4'));
    list.addAll(TopicLocalData.getWords('tu_vung_n5'));
    list.addAll(TopicLocalData.getWords('giao_tiep_hang_ngay'));
    list.addAll(TopicLocalData.getWords('loi_song'));
    return list;
  }

  List<TopicWord> _getGrammarPool() {
    return TopicLocalData.getWords('ngu_phap_n4');
  }

  String _cleanMeaning(String raw) {
    var cleaned = raw.trim();

    // Nếu có phần giải thích dài trong dấu ngoặc đơn, rút gọn cho vừa vặn ô thẻ
    if (cleaned.length > 30 && cleaned.contains('(')) {
      final beforeParen = cleaned.split('(').first.trim();
      if (beforeParen.isNotEmpty) {
        cleaned = beforeParen;
      }
    }

    // Nếu vẫn quá dài, cắt ngắn và thêm dấu chấm lửng
    if (cleaned.length > 36) {
      cleaned = '${cleaned.substring(0, 33)}...';
    }

    return cleaned;
  }
}

