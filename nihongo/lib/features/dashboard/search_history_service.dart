import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/api.dart';

/// Dịch vụ quản lý lịch sử tìm kiếm gần đây.
/// Tự động đồng bộ 2 chiều giữa:
/// - Cơ sở dữ liệu MySQL thông qua API Spring Boot (`/search-history`)
/// - Bộ nhớ thiết bị `FlutterSecureStorage` (cache offline an toàn)
/// Đồng bộ từ 3 nguồn tìm kiếm:
/// 1. Tra cứu trực tiếp từ điển (DictionaryTab)
/// 2. Khung tìm kiếm trang chủ "Nhập Tiếng Nhật cần tìm" (HomeTab)
/// 3. Nhận dạng viết tay "Viết Kanji" (KanjiHandwritingPage)
class SearchHistoryService extends ChangeNotifier {
  SearchHistoryService._({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient() {
    _init();
  }

  static final SearchHistoryService instance = SearchHistoryService._();

  final ApiClient _apiClient;
  static const _storageKey = 'nihongo_recent_search_keywords';
  final _storage = const FlutterSecureStorage();

  // Danh sách từ khóa mẫu mặc định theo giao diện
  static const List<String> defaultKeywords = [
    'セ',
    '出し',
    '貸し',
    '多く',
    '生活',
    '商協',
    '協',
    '小さい',
    '火',
  ];

  late List<String> _recentKeywords = List<String>.from(defaultKeywords);

  List<String> get recentKeywords => List.unmodifiable(_recentKeywords);

  Future<void> _init() async {
    // 1. Tải nhanh từ Local Storage để hiển thị UI tức thì
    await _loadFromStorage();
    // 2. Đồng bộ 2 chiều với Database MySQL qua Backend API
    await _syncWithBackend();
  }

  Future<void> _loadFromStorage() async {
    try {
      final jsonStr = await _storage.read(key: _storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          final list = decoded
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList();
          if (list.isNotEmpty) {
            _recentKeywords = list;
            notifyListeners();
          }
        }
      }
    } catch (_) {
      // Bỏ qua lỗi lưu trữ trên môi trường test hoặc thiết bị không hỗ trợ
    }
  }

  Future<void> _syncWithBackend() async {
    try {
      final response = await _apiClient.get(ApiConfig.searchHistory);
      final rawList = response['keywords'];
      if (rawList is List && rawList.isNotEmpty) {
        final list = rawList
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (list.isNotEmpty) {
          _recentKeywords = list;
          notifyListeners();
          _saveToStorage();
          return;
        }
      }

      // Nếu database chưa có dữ liệu nào nhưng local có sẵn từ khóa,
      // đồng bộ danh sách từ khóa lên database
      for (final kw in _recentKeywords.reversed) {
        await _apiClient.post(
          ApiConfig.searchHistory,
          {'query': kw},
        );
      }
    } catch (_) {
      // Offline fallback: sử dụng local storage an toàn
    }
  }

  Future<void> _saveToStorage() async {
    try {
      await _storage.write(
        key: _storageKey,
        value: jsonEncode(_recentKeywords),
      );
    } catch (_) {}
  }

  /// Thêm từ khóa vào đầu danh sách lịch sử tìm kiếm và lưu vào Database.
  /// Nếu từ khóa đã có sẵn thì đưa lên vị trí đầu tiên.
  void addKeyword(String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) return;

    _recentKeywords.remove(query);
    _recentKeywords.insert(0, query);
    if (_recentKeywords.length > 20) {
      _recentKeywords.removeLast();
    }
    notifyListeners();
    _saveToStorage();

    // Đồng bộ lên MySQL Database thông qua Backend API
    _apiClient.post(
      ApiConfig.searchHistory,
      {'query': query},
    ).catchError((_) => <String, dynamic>{});
  }

  /// Xóa một từ khóa khỏi danh sách tìm kiếm và đồng bộ xóa trên Database.
  void removeKeyword(String rawQuery) {
    final query = rawQuery.trim();
    if (_recentKeywords.remove(query)) {
      notifyListeners();
      _saveToStorage();

      // Đồng bộ xóa trên Database
      _apiClient.delete(
        '${ApiConfig.searchHistory}?query=${Uri.encodeComponent(query)}',
      ).catchError((_) => <String, dynamic>{});
    }
  }

  /// Xóa toàn bộ lịch sử tìm kiếm trên cả App và Database.
  void clear() {
    _recentKeywords.clear();
    notifyListeners();
    _saveToStorage();

    _apiClient
        .delete('${ApiConfig.searchHistory}/clear')
        .catchError((_) => <String, dynamic>{});
  }

  /// Đặt lại danh sách mặc định (phục vụ test).
  void resetToDefault() {
    _recentKeywords = List<String>.from(defaultKeywords);
    notifyListeners();
  }
}
