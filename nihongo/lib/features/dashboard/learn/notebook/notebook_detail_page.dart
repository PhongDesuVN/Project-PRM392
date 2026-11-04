import 'package:flutter/material.dart';

import '../../../../shared/ui.dart';
import '../../../learn/topic_words/flashcard_page.dart';
import 'models/notebook_item.dart';
import 'services/notebook_service.dart';
import 'widgets/add_word_bottom_sheet.dart';

/// Màn hình chi tiết sổ tay:
/// - Khi chưa có từ: hiển thị Mascot và "Danh sách trống" kèm nút "Thêm từ mới"
/// - Khi đã có từ: hiển thị giao diện giống "Từ vựng N4"
/// - Nút thêm từ mới mở modal thêm từ và lưu trực tiếp vào MySQL database.
class NotebookDetailPage extends StatefulWidget {
  const NotebookDetailPage({super.key, required this.notebook});

  final NotebookItem notebook;

  @override
  State<NotebookDetailPage> createState() => _NotebookDetailPageState();
}

class _NotebookDetailPageState extends State<NotebookDetailPage> {
  final TextEditingController _searchController = TextEditingController();
  List<NotebookWord> _words = [];
  NotebookWord? _highlightedWord;
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    setState(() => _isLoading = true);
    final list = await NotebookService.instance.getWordsOfNotebook(
      widget.notebook.id,
    );
    if (mounted) {
      setState(() {
        _words = list;
        if (list.isNotEmpty) {
          _highlightedWord = list.first;
        } else {
          _highlightedWord = null;
        }
        _isLoading = false;
      });
    }
  }

  List<NotebookWord> get _filteredWords {
    if (_searchQuery.trim().isEmpty) return _words;
    final q = _searchQuery.trim().toLowerCase();
    return _words.where((w) {
      return w.word.toLowerCase().contains(q) ||
          w.reading.toLowerCase().contains(q) ||
          (w.romaji != null && w.romaji!.toLowerCase().contains(q)) ||
          w.meaning.toLowerCase().contains(q);
    }).toList();
  }

  void _openAddWordModal() {
    AddWordBottomSheet.show(
      context: context,
      notebookTitle: widget.notebook.title,
      onSubmit:
          ({
            required String word,
            required String reading,
            required String meaning,
            required String wordType,
          }) async {
            final newWord = await NotebookService.instance.addWordToNotebook(
              widget.notebook.id,
              word: word,
              reading: reading,
              meaning: meaning,
              wordType: wordType,
            );

            if (newWord != null && mounted) {
              setState(() {
                _words.insert(0, newWord);
                _highlightedWord = newWord;
              });

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã thêm "$word" vào sổ tay "${widget.notebook.title}"',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              return true;
            }
            return false;
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
          duration: const Duration(milliseconds: 700),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _shuffleWords() {
    if (_words.isEmpty) return;
    setState(() {
      _words.shuffle();
      _highlightedWord = _words.first;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Đã xáo trộn danh sách từ vựng!'),
          duration: Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _startFlashcard() {
    if (_words.isEmpty) return;
    final topicWords = _words.map((w) => w.toTopicWord()).toList();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            FlashcardPage(topicTitle: widget.notebook.title, words: topicWords),
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
                  hintText: 'Tìm từ vựng...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : Text(
                widget.notebook.title,
                style: const TextStyle(
                  color: Color(0xFF1E242B),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
        actions: [
          // Nút "+" Thêm từ mới
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1E242B), size: 26),
            tooltip: 'Thêm từ mới',
            onPressed: _openAddWordModal,
          ),
          // Nút "🔍" Tìm kiếm
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search_rounded,
              color: const Color(0xFF1E242B),
            ),
            tooltip: 'Tìm kiếm',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          // Nút "⋮" Menu tùy chọn
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E242B)),
            onSelected: (val) {
              if (val == 'practice') {
                _startFlashcard();
              } else if (val == 'refresh') {
                _loadWords();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'practice',
                child: Row(
                  children: [
                    Icon(
                      Icons.style_outlined,
                      size: 20,
                      color: Color(0xFF1E242B),
                    ),
                    SizedBox(width: 10),
                    Text('Luyện tập Flashcard'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20, color: Color(0xFF1E242B)),
                    SizedBox(width: 10),
                    Text('Làm mới danh sách'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _words.isEmpty
          ? _buildEmptyState()
          : _buildWordsContent(),
      bottomNavigationBar: _words.isNotEmpty ? _buildBottomPracticeBar() : null,
    );
  }

  /// Khung hiển thị khi sổ tay chưa có từ nào (Mascot + Danh sách trống + Thêm từ mới) - Ảnh 2
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mascot đồ họa phong cách chú mèo/robot đội hộp các-tông đáng yêu
              _buildMascotIllustration(),
              const SizedBox(height: 20),

              // "Danh sách trống"
              const Text(
                'Danh sách trống',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E242B),
                ),
              ),
              const SizedBox(height: 8),

              // "Chưa có từ nào. Hãy thêm từ mới"
              Text(
                'Chưa có từ nào. Hãy thêm từ mới',
                style: TextStyle(
                  fontSize: 14.5,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Nút bấm "Thêm từ mới"
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _openAddWordModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Thêm từ mới',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Minh họa Mascot chú mèo đội hộp các-tông biểu tượng Nihongo
  Widget _buildMascotIllustration() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vệt bóng mờ dưới chân
          Positioned(
            bottom: 4,
            child: Container(
              width: 110,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Nhân vật Mascot
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hộp các-tông trên đầu
              Container(
                width: 76,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFC49A6C),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Nắp hộp
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFB08556),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    // Khuôn mặt mascot lấp ló bên trong
                    Positioned(
                      bottom: 4,
                      left: 14,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 8,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E242B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5252),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E242B),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              // Thân nhân vật áo xanh dương & huy hiệu chữ Nhật 'あ'
              Container(
                width: 58,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'あ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Danh sách từ vựng theo phong cách màn hình "Từ vựng N4" (Ảnh 4 & 5)
  Widget _buildWordsContent() {
    final displayedWords = _filteredWords;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      children: [
        // ================= HIGHLIGHT CARD TRÊN CÙNG =================
        if (_highlightedWord != null) _buildHighlightCard(_highlightedWord!),

        const SizedBox(height: 20),

        // ================= THANH HEADER: DANH SÁCH TỪ + SHUFFLE & PLAY =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh sách từ (${_words.length})',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E242B),
              ),
            ),
            Row(
              children: [
                // Nút Xáo trộn (Shuffle)
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: _shuffleWords,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shuffle_rounded,
                        color: Color(0xFF1E242B),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Nút Play (Luyện tập Flashcard)
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: _startFlashcard,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
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

        // ================= CÁC THẺ TỪ VỰNG =================
        if (displayedWords.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: const Text(
              'Không tìm thấy từ vựng nào khớp với tìm kiếm',
              style: TextStyle(color: Colors.grey, fontSize: 14.5),
            ),
          )
        else
          ...displayedWords.map((item) => _buildWordCard(item)),
      ],
    );
  }

  /// Card nổi bật trên cùng
  Widget _buildHighlightCard(NotebookWord item) {
    final readingDisplay = item.reading.isNotEmpty ? '「${item.reading}」' : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
                // Kanji/Từ chính màu xanh biển nổi bật
                Text(
                  item.word,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // Phiên âm cách đọc trong ngoặc vuông
                if (readingDisplay.isNotEmpty)
                  Text(
                    readingDisplay,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 12),

                // Icon loa phát âm
                InkWell(
                  onTap: () => _playAudio(item.word),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_outlined,
                      size: 22,
                      color: Color(0xFF424242),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Nghĩa tiếng Việt
                Text(
                  item.meaning,
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

  /// Từng thẻ từ trong danh sách
  Widget _buildWordCard(NotebookWord item) {
    final isSelected = _highlightedWord?.word == item.word;
    final readingText = item.reading.isNotEmpty ? '「${item.reading}」' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.6 : 1.0,
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() => _highlightedWord = item);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng trên: Từ vựng + Phiên âm + Loa phát âm
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.word,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (readingText.isNotEmpty)
                      Expanded(
                        child: Text(
                          readingText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up_outlined,
                        color: Color(0xFF546E7A),
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _playAudio(item.word),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Nghĩa tiếng Việt
                Text(
                  item.meaning,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Đường viền mảnh phân cách
                const Divider(height: 1, color: Color(0xFFEDF2F7)),
                const SizedBox(height: 10),

                // Hàng dưới: "+ Thêm ghi chú của bạn ở đây" và Ngày tạo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '+ Thêm ghi chú của bạn ở đây',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      widget.notebook.createdAt.isNotEmpty
                          ? widget.notebook.createdAt
                          : '01/11/2026',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Thanh điều hướng & luyện tập ở dưới cùng màn hình (Ảnh 5)
  Widget _buildBottomPracticeBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Phân trang: < 1 / 1 >
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 22),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                const Text(
                  '1 / 1',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E242B),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 22),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Spacer(),

            // Nút "📝 Luyện tập" mở Flashcard
            ElevatedButton.icon(
              onPressed: _startFlashcard,
              icon: const Icon(Icons.style_outlined, size: 18),
              label: const Text('Luyện tập'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
