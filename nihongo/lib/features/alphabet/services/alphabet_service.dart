import '../../../core/api.dart';
import '../data/alphabet_local_data.dart';
import '../models/alphabet_models.dart';

/// Service quản lý tải bảng chữ cái từ Backend Spring Boot
/// và tự động chuyển về dữ liệu offline khi không có kết nối mạng.
class AlphabetService {
  AlphabetService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AlphabetResponse> fetchAlphabet(AlphabetScript script) async {
    try {
      final endpoint = '${ApiConfig.alphabet}/${script.key}';
      final response = await _apiClient.get(endpoint);
      return AlphabetResponse.fromJson(response);
    } catch (_) {
      // Khi không có kết nối tới server (hoặc chưa chạy backend), dùng dữ liệu local
      return AlphabetLocalData.getAlphabet(script);
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}
