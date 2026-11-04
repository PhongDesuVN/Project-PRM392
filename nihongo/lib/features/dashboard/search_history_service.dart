import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/api.dart';

/// Dịch vụ quản lý lịch sử tìm kiếm gần đây (giới hạn tối đa 10 tìm kiếm).
class SearchHistoryService extends ChangeNotifier {
  SearchHistoryService._({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient() {
    _init();
  }

  static final SearchHistoryService instance = SearchHistoryService._();
  static const int maxRecentKeywords = 10;

  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();
  String? _currentEmail;
  bool _isGuest = false;

  @override
  void notifyListeners() {
    final binding = WidgetsBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback((_) {
        super.notifyListeners();
      });
    } else {
      super.notifyListeners();
    }
  }

  String get _storageKey => _currentEmail != null && _currentEmail!.isNotEmpty
      ? 'nihongo_recent_search_keywords_${_currentEmail!}'
      : 'nihongo_recent_search_keywords_guest';

  static const List<String> defaultKeywords = [];
  static const Set<String> _sampleMockKeywords = {
    'hi',
    '出し',
    '日',
    'セ',
    '夊',
    '生活',
    '小さい',
    '貸し',
    '多く',
    '商協',
    '協',
  };

  late List<String> _recentKeywords = [];

  List<String> get recentKeywords => List.unmodifiable(_recentKeywords);

  void switchUser(String? email) {
    _currentEmail = email;
    _isGuest = email == null || email.isEmpty || email == 'Khách';
    _recentKeywords = [];
    notifyListeners();
    _init();
  }

  Future<void> _init() async {
    await _loadFromStorage();
    if (!_isGuest) {
      await _syncWithBackend();
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final jsonStr = await _storage.read(key: _storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          final list = decoded
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty && !_sampleMockKeywords.contains(e))
              .take(maxRecentKeywords)
              .toList();
          _recentKeywords = list;
          notifyListeners();
          if (list.length != decoded.length) {
            _saveToStorage();
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _syncWithBackend() async {
    try {
      final response = await _apiClient.get(ApiConfig.searchHistory);
      final rawList = response['keywords'];
      if (rawList is List) {
        final list = rawList
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty && !_sampleMockKeywords.contains(e))
            .take(maxRecentKeywords)
            .toList();
        _recentKeywords = list;
        notifyListeners();
        _saveToStorage();
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      await _storage.write(
        key: _storageKey,
        value: jsonEncode(_recentKeywords),
      );
    } catch (_) {}
  }

  /// Thêm từ khóa vào đầu danh sách lịch sử tìm kiếm (giới hạn tối đa 10 mục)
  void addKeyword(String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) return;

    _recentKeywords.remove(query);
    _recentKeywords.insert(0, query);
    if (_recentKeywords.length > maxRecentKeywords) {
      _recentKeywords.removeLast();
    }
    notifyListeners();
    _saveToStorage();

    if (!_isGuest) {
      _apiClient
          .post(ApiConfig.searchHistory, {'query': query})
          .catchError((_) => <String, dynamic>{});
    }
  }

  void removeKeyword(String rawQuery) {
    final query = rawQuery.trim();
    if (_recentKeywords.remove(query)) {
      notifyListeners();
      _saveToStorage();

      if (!_isGuest) {
        _apiClient
            .delete(
              '${ApiConfig.searchHistory}?query=${Uri.encodeComponent(query)}',
            )
            .catchError((_) => <String, dynamic>{});
      }
    }
  }

  void clear() {
    _recentKeywords.clear();
    notifyListeners();
    _saveToStorage();

    if (!_isGuest) {
      _apiClient
          .delete('${ApiConfig.searchHistory}/clear')
          .catchError((_) => <String, dynamic>{});
    }
  }

  void resetToDefault() {
    _recentKeywords = List<String>.from(defaultKeywords);
    notifyListeners();
  }
}
