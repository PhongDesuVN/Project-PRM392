import '../../../../core/api.dart';
import '../models/exam_models.dart';

/// Gọi API thi thử (`/mock-exam`). Chấm điểm do backend thực hiện.
class MockExamService {
  MockExamService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<ExamSummary>> fetchTests({required String level}) async {
    final json = await _api.get(
      '${ApiConfig.mockExam}/tests',
      queryParameters: {'level': level},
    );
    final raw = json['tests'] as List<dynamic>? ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ExamSummary.fromJson)
        .toList();
  }

  Future<ExamDetail> fetchTest(int id) async {
    final json = await _api.get('${ApiConfig.mockExam}/tests/$id');
    return ExamDetail.fromJson(json);
  }

  /// [answers] là map câu hỏi → đáp án đã chọn; câu bỏ trống thì không có key.
  Future<ExamResult> submit(int id, Map<int, int> answers) async {
    final json = await _api.post('${ApiConfig.mockExam}/tests/$id/submit', {
      'answers': [
        for (final e in answers.entries)
          {'questionId': e.key, 'optionId': e.value},
      ],
    });
    return ExamResult.fromJson(json);
  }
}
