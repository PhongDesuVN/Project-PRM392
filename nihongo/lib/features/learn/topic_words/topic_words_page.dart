import 'package:flutter/material.dart';

import 'flashcard_page.dart';
import 'models/topic_word_model.dart';
import 'services/topic_words_service.dart';
import 'widgets/practice_mode_bottom_sheet.dart';

/// Màn hình danh sách từ vựng theo chủ đề (Ảnh 1 - "Từ vựng N4"):
/// - Card từ vựng nổi bật ở trên cùng
/// - Section "Danh sách từ" kèm nút Xáo trộn và nút Play (Luyện tập)
/// - Danh sách các từ có thể nghe phát âm và chọn để xem nhanh
/// - Bấm nút Play sẽ mở BottomSheet "Chọn chế độ luyện tập" -> dẫn vào Flashcard
class TopicWordsPage extends StatefulWidget {
  const TopicWordsPage({
    super.key,
    required this.topicCode,
    required this.topicTitle,
  });

  final String topicCode;
  final String topicTitle;

  @override
  State<TopicWordsPage> createState() => _TopicWordsPageState();
}

class _TopicWordsPageState extends State<TopicWordsPage> {
  final TopicWordsService _service = TopicWordsService();
  List<TopicWord> _allWords = [];
  List<TopicWord> _filteredWords = [];
  TopicWord? _selectedHighlightWord;
  bool _isLoading = true;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTopicWords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadTopicWords() async {
    setState(() => _isLoading = true);
    final words = await _service.getWordsByTopic(widget.topicCode);
    if (mounted) {
      setState(() {
        _allWords = words;
        _filteredWords = words;
        if (words.isNotEmpty) {
          _selectedHighlightWord = words.first;
        }
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredWords = _allWords;
      } else {
        _filteredWords = _allWords.where((w) {
          return w.word.toLowerCase().contains(q) ||
              w.reading.toLowerCase().contains(q) ||
              (w.romaji != null && w.romaji!.toLowerCase().contains(q)) ||
              w.meaning.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  void _shuffleWords() {
    setState(() {
      _filteredWords.shuffle();
      if (_filteredWords.isNotEmpty) {
        _selectedHighlightWord = _filteredWords.first;
      }
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Đã xáo trộn danh sách từ vựng!'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openPracticeBottomSheet() {
    PracticeModeBottomSheet.show(
      context: context,
      onSelectFlashcard: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) =>
                FlashcardPage(topicTitle: widget.topicTitle, words: _allWords),
          ),
        );
      },
    );
  }

  void _playAudio(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Phát âm: $text'),
            ],
          ),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F3F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E242B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tìm từ vựng, romaji, nghĩa...',
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : Text(
                widget.topicTitle,
                style: const TextStyle(
                  color: Color(0xFF1E242B),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search_rounded,
              color: const Color(0xFF1E242B),
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredWords = _allWords;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E242B)),
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Tùy chọn danh sách bài học'),
                    duration: Duration(seconds: 1),
                  ),
                );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  // ================= HIGHLIGHT CARD TRÊN CÙNG (Ảnh 1) =================
                  if (_selectedHighlightWord != null)
                    _buildTopHighlightCard(_selectedHighlightWord!),

                  const SizedBox(height: 24),

                  // ================= HEADER: DANH SÁCH TỪ + NÚT SHUFFLE & PLAY =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Danh sách từ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E242B),
                        ),
                      ),
                      Row(
                        children: [
                          // Nút Shuffle (Xáo trộn)
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            elevation: 0.5,
                            child: InkWell(
                              onTap: _shuffleWords,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.shuffle_rounded,
                                  color: Color(0xFF1E242B),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Nút Play (Luyện tập) -> Bật Modal "Chọn chế độ luyện tập"
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            elevation: 0.5,
                            child: InkWell(
                              onTap: _openPracticeBottomSheet,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xFF1E242B),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ================= DANH SÁCH TỪ VỰNG =================
                  if (_filteredWords.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Text(
                        'Không tìm thấy từ vựng nào',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    )
                  else
                    ..._filteredWords.map((word) => _buildWordRowItem(word)),
                ],
              ),
            ),
    );
  }

  /// Top Highlight Card hiển thị từ vựng to ở trên cùng (Ảnh 1)
  Widget _buildTopHighlightCard(TopicWord word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              children: [
                // Kanji/Từ chính màu xanh dương nổi bật
                Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 12),

                // Furigana / Cách đọc trong ngoặc
                Text(
                  word.reading,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 14),

                // Icon loa phát âm
                InkWell(
                  onTap: () => _playAudio(word.word),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_outlined,
                      size: 24,
                      color: Color(0xFF424242),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Nghĩa tiếng Việt
                Text(
                  word.meaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E242B),
                  ),
                ),
              ],
            ),
          ),

          // Logo nihon nhỏ góc dưới phải
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD6E4F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'nihon',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF90A4AE),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Từng hàng trong danh sách từ
  Widget _buildWordRowItem(TopicWord word) {
    final isSelected = _selectedHighlightWord?.id == word.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF90CAF9) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() => _selectedHighlightWord = word);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Từ tiếng Nhật (màu xanh biển)
                Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(width: 14),

                // Furigana / Cách đọc trong ngoặc
                Expanded(
                  child: Text(
                    word.reading,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),

                // Nút loa phát âm
                IconButton(
                  icon: const Icon(
                    Icons.volume_up_outlined,
                    color: Color(0xFF546E7A),
                    size: 22,
                  ),
                  onPressed: () => _playAudio(word.word),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
