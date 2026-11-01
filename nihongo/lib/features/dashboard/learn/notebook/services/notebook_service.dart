import 'package:flutter/foundation.dart';
import '../../../../../../core/api.dart';
import '../../../../learn/topic_words/models/topic_word_model.dart';
import '../models/notebook_item.dart';

/// Trạng thái học từ vựng trong sổ tay
enum NotebookWordStatus {
  chuaThuoc('chua_thuoc', 'Chưa thuộc'),
  thuocLoMo('thuoc_lo_mo', 'Thuộc lơ mơ'),
  thuocKhaKha('thuoc_kha_kha', 'Thuộc kha khá'),
  thuocLauLau('thuoc_lau_lau', 'Thuộc làu làu');

  const NotebookWordStatus(this.code, this.label);
  final String code;
  final String label;

  static NotebookWordStatus fromCode(String code) {
    for (final s in values) {
      if (s.code == code) return s;
    }
    return NotebookWordStatus.chuaThuoc;
  }
}

/// Dữ liệu từ trong sổ tay
class NotebookWord {
  NotebookWord({
    required this.word,
    required this.reading,
    this.romaji,
    required this.meaning,
    required this.status,
    this.reviewCount = 1,
    this.notebookId,
    this.wordType,
  });

  final String word;
  final String reading;
  final String? romaji;
  final String meaning;
  NotebookWordStatus status;
  int reviewCount;
  int? notebookId;
  final String? wordType;

  TopicWord toTopicWord() {
    return TopicWord(
      id: word.hashCode,
      topicCode: 'notebook',
      word: word,
      reading: reading,
      romaji: romaji,
      meaning: meaning,
    );
  }

  factory NotebookWord.fromJson(Map<String, dynamic> json) {
    return NotebookWord(
      word: json['word'] as String? ?? '',
      reading: json['reading'] as String? ?? '',
      romaji: json['romaji'] as String?,
      meaning: json['meaning'] as String? ?? '',
      status: NotebookWordStatus.fromCode(json['status'] as String? ?? ''),
      reviewCount: json['reviewCount'] as int? ?? 1,
      notebookId: json['notebookId'] as int?,
      wordType: json['wordType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'word': word,
    'reading': reading,
    'romaji': romaji,
    'meaning': meaning,
    'status': status.code,
    if (notebookId != null) 'notebookId': notebookId,
    if (wordType != null) 'wordType': wordType,
  };
}

/// Dữ liệu thống kê 4 ô trạng thái
class NotebookStats {
  const NotebookStats({
    this.chuaThuoc = 0,
    this.thuocLoMo = 0,
    this.thuocKhaKha = 0,
    this.thuocLauLau = 0,
  });

  final int chuaThuoc;
  final int thuocLoMo;
  final int thuocKhaKha;
  final int thuocLauLau;

  int get total => chuaThuoc + thuocLoMo + thuocKhaKha + thuocLauLau;

  factory NotebookStats.fromJson(Map<String, dynamic> json) {
    return NotebookStats(
      chuaThuoc: json['chuaThuoc'] as int? ?? 0,
      thuocLoMo: json['thuocLoMo'] as int? ?? 0,
      thuocKhaKha: json['thuocKhaKha'] as int? ?? 0,
      thuocLauLau: json['thuocLauLau'] as int? ?? 0,
    );
  }
}

/// Service quản lý Sổ tay của tôi:
/// - Kế thừa ChangeNotifier để màn hình MyNotebookView tự động cập nhật ngay khi bấm Hoàn tất ở Flashcard.
/// - Đồng bộ dữ liệu 2 chiều với Backend Spring Boot và MySQL: danh sách sổ tay & từ vựng.
class NotebookService extends ChangeNotifier {
  NotebookService._();
  static final NotebookService instance = NotebookService._();

  final ApiClient _apiClient = ApiClient();
  final Map<String, NotebookWord> _notebookMap = {};
  final List<NotebookItem> _notebooks = [];
  NotebookItem? _selectedNotebook;
  bool _isInitialized = false;
  bool _isLoadingNotebooks = false;
  bool isGuest = false;
  String? _currentUserEmail;
  int? _currentUserId;

  Map<String, NotebookWord> get notebookMap => Map.unmodifiable(_notebookMap);
  List<NotebookItem> get notebooks => List.unmodifiable(_notebooks);
  NotebookItem? get selectedNotebook => _selectedNotebook;
  bool get isLoadingNotebooks => _isLoadingNotebooks;

  /// Chuyển đổi người dùng: Khách hoặc tài khoản cụ thể.
  /// Giúp phân tách độc lập toàn bộ sổ tay và thống kê học tập giữa các tài khoản khác nhau.
  void switchUser({String? email, int? userId, required bool isGuest}) {
    this.isGuest = isGuest;
    _currentUserEmail = isGuest ? null : email;
    _currentUserId = isGuest ? null : userId;
    ApiClient.defaultUserEmail = _currentUserEmail;
    ApiClient.defaultUserId = _currentUserId;

    _notebookMap.clear();
    _notebooks.clear();
    _selectedNotebook = null;
    notifyListeners();

    if (!isGuest) {
      refreshAll();
    }
  }

  int get totalReviewWordsCount {
    if (isGuest) return 0;
    int count = 0;
    for (final w in _notebookMap.values) {
      if (w.notebookId != null) count++;
    }
    if (count > 0) return count;

    int sum = 0;
    for (final nb in _notebooks) {
      sum += nb.wordCount;
    }
    return sum;
  }

  NotebookStats get stats {
    if (isGuest) {
      return const NotebookStats(
        chuaThuoc: 0,
        thuocLoMo: 0,
        thuocKhaKha: 0,
        thuocLauLau: 0,
      );
    }
    int chuaThuoc = 0;
    int thuocLoMo = 0;
    int thuocLauLau = 0;

    for (final w in _notebookMap.values) {
      // Hiển thị cả từ học ở Thư viện và Sổ tay lên phần Tổng quan
      switch (w.status) {
        case NotebookWordStatus.chuaThuoc:
          chuaThuoc++;
          break;
        case NotebookWordStatus.thuocLoMo:
          thuocLoMo++;
          break;
        case NotebookWordStatus.thuocKhaKha:
        case NotebookWordStatus.thuocLauLau:
          thuocLauLau++;
          break;
      }
    }
    return NotebookStats(
      chuaThuoc: chuaThuoc,
      thuocLoMo: thuocLoMo,
      thuocKhaKha: 0,
      thuocLauLau: thuocLauLau,
    );
  }

  /// Khởi tạo và tải dữ liệu từ Backend khi mở app
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    if (isGuest) return;
    await Future.wait([
      fetchStatsAndWords(),
      fetchNotebooks(),
    ]);
  }

  /// Tải danh sách các sổ tay từ Backend MySQL
  Future<void> fetchNotebooks() async {
    if (isGuest) {
      _notebooks.clear();
      _isLoadingNotebooks = false;
      notifyListeners();
      return;
    }
    _isLoadingNotebooks = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConfig.notebookList);
      final rawList = response['notebooks'];
      _notebooks.clear();
      if (rawList is List && rawList.isNotEmpty) {
        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            _notebooks.add(NotebookItem.fromJson(item));
          }
        }
      }
    } catch (_) {
      // Khi offline
    } finally {
      _isLoadingNotebooks = false;
      notifyListeners();
    }
  }

  /// Làm mới toàn bộ danh sách sổ tay và thống kê từ vựng từ MySQL
  Future<void> refreshAll() async {
    if (isGuest) return;
    await Future.wait([
      fetchNotebooks(),
      fetchStatsAndWords(),
    ]);
  }

  /// Tạo sổ tay mới và đồng bộ lên MySQL
  Future<NotebookItem?> createNotebook(
    String title, {
    String description = '',
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return null;

    try {
      final response = await _apiClient.post(
        ApiConfig.notebook,
        {
          'title': trimmedTitle,
          'description': description,
        },
      );
      final created = NotebookItem.fromJson(response);
      _notebooks.insert(0, created);
      notifyListeners();
      return created;
    } catch (_) {
      // Fallback local
      final localCreated = NotebookItem(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: trimmedTitle,
        description: description,
        wordCount: 0,
        createdAt: '29/10/2026',
      );
      _notebooks.insert(0, localCreated);
      notifyListeners();
      return localCreated;
    }
  }

  /// Cập nhật tên hoặc mô tả sổ tay
  Future<bool> updateNotebook(
    int id,
    String title, {
    String description = '',
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return false;

    final index = _notebooks.indexWhere((n) => n.id == id);
    if (index != -1) {
      final old = _notebooks[index];
      _notebooks[index] = old.copyWith(
        title: trimmedTitle,
        description: description,
      );
      notifyListeners();
    }

    try {
      await _apiClient.put(
        '${ApiConfig.notebook}/$id',
        {
          'title': trimmedTitle,
          'description': description,
        },
      );
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Xóa sổ tay khỏi MySQL
  Future<bool> deleteNotebook(int id) async {
    _notebooks.removeWhere((n) => n.id == id);
    if (_selectedNotebook?.id == id) {
      _selectedNotebook = null;
    }
    notifyListeners();

    try {
      await _apiClient.delete('${ApiConfig.notebook}/$id');
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Chọn / bỏ chọn sổ tay để ôn tập hoặc lọc
  void selectNotebook(NotebookItem? notebook) {
    _selectedNotebook = notebook;
    notifyListeners();
  }

  Future<void> fetchStatsAndWords() async {
    if (isGuest) {
      _notebookMap.clear();
      notifyListeners();
      return;
    }
    try {
      final response = await _apiClient.get(ApiConfig.notebookWords);
      final rawWords = response['words'];
      if (rawWords is List) {
        _notebookMap.clear();
        for (final item in rawWords) {
          if (item is Map<String, dynamic>) {
            final w = NotebookWord.fromJson(item);
            _notebookMap[w.word] = w;
          }
        }
        notifyListeners();
      }
    } catch (_) {
      // Khi server offline thì dùng dữ liệu local
    }
  }

  /// Lấy danh sách từ thuộc một sổ tay từ Backend MySQL
  Future<List<NotebookWord>> getWordsOfNotebook(int notebookId) async {
    try {
      final response = await _apiClient.get('${ApiConfig.notebook}/$notebookId/words');
      final rawWords = response['words'];
      if (rawWords is List) {
        final List<NotebookWord> list = [];
        for (final item in rawWords) {
          if (item is Map<String, dynamic>) {
            final w = NotebookWord.fromJson(item);
            _notebookMap[w.word] = w;
            list.add(w);
          }
        }
        notifyListeners();
        return list;
      }
    } catch (_) {
      // Fallback lấy từ local cache
    }
    return _notebookMap.values.where((w) => w.notebookId == notebookId).toList();
  }

  /// Thêm từ mới vào sổ tay và đồng bộ trực tiếp vào database MySQL
  Future<NotebookWord?> addWordToNotebook(
    int notebookId, {
    required String word,
    required String reading,
    required String meaning,
    String? romaji,
    String? wordType,
  }) async {
    final trimmedWord = word.trim();
    if (trimmedWord.isEmpty) return null;

    final requestBody = {
      'word': trimmedWord,
      'reading': reading.trim(),
      'romaji': romaji?.trim() ?? '',
      'meaning': meaning.trim(),
      'wordType': wordType ?? 'Từ vựng',
    };

    NotebookWord? created;
    try {
      final response = await _apiClient.post(
        '${ApiConfig.notebook}/$notebookId/words',
        requestBody,
      );
      created = NotebookWord.fromJson(response);
    } catch (_) {
      // Fallback local
      created = NotebookWord(
        word: trimmedWord,
        reading: reading.trim(),
        romaji: romaji?.trim(),
        meaning: meaning.trim(),
        status: NotebookWordStatus.chuaThuoc,
        notebookId: notebookId,
        wordType: wordType,
      );
    }

    _notebookMap[created.word] = created;

    // Cập nhật số lượng từ của sổ tay trong danh sách
    final idx = _notebooks.indexWhere((n) => n.id == notebookId);
    if (idx != -1) {
      final old = _notebooks[idx];
      _notebooks[idx] = old.copyWith(wordCount: old.wordCount + 1);
    }

    notifyListeners();
    return created;
  }

  /// Lưu kết quả sau khi kết thúc buổi học Flashcard và bấm "Hoàn tất"
  Future<void> saveStudyResult({
    required List<TopicWord> masteredWords,
    required List<TopicWord> hardWords,
    required List<TopicWord> unknownWords,
  }) async {
    final List<Map<String, dynamic>> syncItems = [];
    final currentNotebookId = _selectedNotebook?.id;

    // 1. Từ chưa thuộc (Nút X đỏ)
    for (final word in unknownWords) {
      final existing = _notebookMap[word.word];
      if (existing != null) {
        existing.status = NotebookWordStatus.chuaThuoc;
        existing.reviewCount++;
      } else {
        _notebookMap[word.word] = NotebookWord(
          word: word.word,
          reading: word.reading,
          romaji: word.romaji,
          meaning: word.meaning,
          status: NotebookWordStatus.chuaThuoc,
          notebookId: currentNotebookId,
        );
      }
      syncItems.add(_notebookMap[word.word]!.toJson());
    }

    // 2. Từ thuộc lơ mơ / chưa chắc chắn (Nút ? vàng)
    for (final word in hardWords) {
      final existing = _notebookMap[word.word];
      if (existing != null) {
        existing.status = NotebookWordStatus.thuocLoMo;
        existing.reviewCount++;
      } else {
        _notebookMap[word.word] = NotebookWord(
          word: word.word,
          reading: word.reading,
          romaji: word.romaji,
          meaning: word.meaning,
          status: NotebookWordStatus.thuocLoMo,
          notebookId: currentNotebookId,
        );
      }
      syncItems.add(_notebookMap[word.word]!.toJson());
    }

    // 3. Từ đã thuộc làu làu (Nút Check xanh lá - bỏ thuộc kha khá)
    for (final word in masteredWords) {
      final existing = _notebookMap[word.word];
      if (existing != null) {
        existing.reviewCount++;
        existing.status = NotebookWordStatus.thuocLauLau;
      } else {
        _notebookMap[word.word] = NotebookWord(
          word: word.word,
          reading: word.reading,
          romaji: word.romaji,
          meaning: word.meaning,
          status: NotebookWordStatus.thuocLauLau,
          notebookId: currentNotebookId,
        );
      }
      syncItems.add(_notebookMap[word.word]!.toJson());
    }

    notifyListeners();

    // Đồng bộ lên Backend Spring Boot & MySQL
    try {
      await _apiClient.post(
        ApiConfig.notebookSync,
        {'words': syncItems},
      );
    } catch (_) {
      // Offline fallback: dữ liệu đã được lưu an toàn trong local map
    }
  }

  /// Lấy danh sách từ theo trạng thái (hiển thị đầy đủ cả từ ở Thư viện và ở các Sổ tay)
  List<TopicWord> getWordsByStatus(NotebookWordStatus status) {
    return _notebookMap.values
        .where((w) {
          if (status == NotebookWordStatus.thuocLauLau) {
            return w.status == NotebookWordStatus.thuocLauLau || w.status == NotebookWordStatus.thuocKhaKha;
          }
          return w.status == status;
        })
        .map((w) => w.toTopicWord())
        .toList();
  }

  /// Lấy toàn bộ từ để ôn tập sổ tay (chỉ lấy từ thuộc về sổ tay)
  List<TopicWord> getAllReviewWords({int? notebookId}) {
    if (notebookId != null) {
      final list = _notebookMap.values
          .where((w) => w.notebookId == notebookId)
          .map((w) => w.toTopicWord())
          .toList();
      if (list.isNotEmpty) return list;
    }
    return _notebookMap.values
        .where((w) => w.notebookId != null)
        .map((w) => w.toTopicWord())
        .toList();
  }

  @visibleForTesting
  void clearForTesting() {
    _notebookMap.clear();
    _notebooks.clear();
    _selectedNotebook = null;
    isGuest = false;
    _currentUserEmail = null;
    _currentUserId = null;
    ApiClient.defaultUserEmail = null;
    ApiClient.defaultUserId = null;
    notifyListeners();
  }
}
