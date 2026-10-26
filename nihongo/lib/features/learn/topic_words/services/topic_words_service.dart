import '../../../../core/api.dart';
import '../data/topic_local_data.dart';
import '../models/topic_word_model.dart';

/// Service phụ trách tải danh sách từ vựng từ Backend Spring Boot / MySQL.
/// Nếu không có mạng hoặc server chưa bật, tự động fallback về dữ liệu local.
class TopicWordsService {
  TopicWordsService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Lấy danh sách từ vựng theo mã chủ đề (ví dụ: 'tu_vung_n4', 'xe_co',...)
  Future<List<TopicWord>> getWordsByTopic(String topicCode) async {
    try {
      final endpoint = '${ApiConfig.topics}/$topicCode/words';
      final response = await _apiClient.get(endpoint);
      final topicWordsResponse = TopicWordsResponse.fromJson(response);
      if (topicWordsResponse.words.isNotEmpty) {
        return topicWordsResponse.words;
      }
      return TopicLocalData.getWords(topicCode);
    } catch (_) {
      // Khi server offline hoặc gặp sự cố kết nối, dùng local database
      return TopicLocalData.getWords(topicCode);
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}
