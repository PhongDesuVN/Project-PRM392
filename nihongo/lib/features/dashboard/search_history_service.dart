import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Dịch vụ quản lý lịch sử tìm kiếm gần đây.
/// Tự động đồng bộ giữa:
/// 1. Tra cứu trực tiếp từ điển (DictionaryTab)
/// 2. Khung tìm kiếm trang chủ "Nhập Tiếng Nhật cần tìm" (HomeTab)
/// 3. Nhận dạng viết tay "Viết Kanji" (KanjiHandwritingPage)
class SearchHistoryService extends ChangeNotifier {
  SearchHistoryService._() {
    _loadFromStorage();
  }

  static final SearchHistoryService instance = SearchHistoryService._();

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

  Future<void> _saveToStorage() async {
    try {
      await _storage.write(
        key: _storageKey,
        value: jsonEncode(_recentKeywords),
      );
    } catch (_) {}
  }

  /// Thêm từ khóa vào đầu danh sách lịch sử tìm kiếm.
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
  }

  /// Xóa một từ khóa khỏi danh sách tìm kiếm gần đây.
  void removeKeyword(String rawQuery) {
    final query = rawQuery.trim();
    if (_recentKeywords.remove(query)) {
      notifyListeners();
      _saveToStorage();
    }
  }

  /// Xóa toàn bộ lịch sử tìm kiếm.
  void clear() {
    _recentKeywords.clear();
    notifyListeners();
    _saveToStorage();
  }

  /// Đặt lại danh sách mặc định (phục vụ test).
  void resetToDefault() {
    _recentKeywords = List<String>.from(defaultKeywords);
    notifyListeners();
  }
}
