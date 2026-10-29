import 'package:flutter/material.dart';

import '../../../core/api.dart';
import '../../../shared/ui.dart';
import '../search_history_service.dart';
import '../shared/dashboard_tool_widgets.dart';
import 'dictionary_service.dart';

class DictionaryTab extends StatefulWidget {
  const DictionaryTab({
    super.key,
    required this.initialQuery,
    required this.onCameraSearch,
    required this.onHandwritingSearch,
    this.service,
  });

  final String initialQuery;
  final VoidCallback onCameraSearch;
  final VoidCallback onHandwritingSearch;
  final DictionaryService? service;

  @override
  State<DictionaryTab> createState() => _DictionaryTabState();
}

class _DictionaryTabState extends State<DictionaryTab> {
  late final TextEditingController _queryController;
  late final DictionaryService _dictionaryService;
  late final bool _ownsService;
  List<DictionaryEntry> _results = const [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
    _ownsService = widget.service == null;
    _dictionaryService = widget.service ?? DictionaryService();
    if (widget.initialQuery.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _search();
      });
    }
  }

  @override
  void didUpdateWidget(covariant DictionaryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery == widget.initialQuery) return;
    _queryController.text = widget.initialQuery;
    if (widget.initialQuery.trim().isEmpty) {
      setState(() {
        _results = const [];
        _errorMessage = null;
        _hasSearched = false;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _search();
      });
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    if (_ownsService) _dictionaryService.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _hasSearched = false;
        _errorMessage = 'Nhập từ hoặc Kanji cần tra cứu.';
        _results = const [];
      });
      return;
    }

    SearchHistoryService.instance.addKeyword(query);

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      final results = await _dictionaryService.search(query);
      if (!mounted) return;
      setState(() => _results = results);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.statusCode == 401
            ? 'Phiên đăng nhập hết hạn. Hãy đăng nhập lại rồi thử tiếp.'
            : error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Không thể tải kết quả. Vui lòng thử lại.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: [
        const DashboardToolHeading(
          eyebrow: 'TRA CỨU',
          title: 'Từ điển Nhật - Việt',
          subtitle: 'Tìm từ vựng và cách đọc nhanh chóng.',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _queryController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: 'Nhập từ tiếng Nhật hoặc tiếng Việt',
            prefixIcon: const Icon(Icons.search, color: AppColors.blue),
            suffixIcon: IconButton(
              tooltip: 'Tra từ',
              onPressed: _isLoading ? null : _search,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_rounded),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DictionaryAction(
                icon: Icons.camera_alt_outlined,
                label: 'Chụp ảnh',
                onTap: widget.onCameraSearch,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DictionaryAction(
                icon: Icons.gesture_rounded,
                label: 'Viết Kanji',
                onTap: widget.onHandwritingSearch,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(28),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          DashboardEmptyState(
            icon: Icons.info_outline,
            title: 'Chưa thể tra cứu',
            message: _errorMessage!,
          )
        else if (!_hasSearched)
          const DashboardEmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Sẵn sàng tra cứu',
            message:
                'Nhập từ ở phía trên hoặc dùng ảnh và nét viết để tìm Kanji.',
          )
        else if (_results.isEmpty)
          const DashboardEmptyState(
            icon: Icons.search_off_rounded,
            title: 'Không tìm thấy kết quả',
            message: 'Thử từ khác hoặc kiểm tra cách viết nhé.',
          )
        else ...[
          Text(
            'Kết quả (${_results.length})',
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final entry in _results)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DictionaryResultCard(entry: entry),
            ),
        ],
      ],
    );
  }
}

class _DictionaryResultCard extends StatelessWidget {
  const _DictionaryResultCard({required this.entry});

  final DictionaryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entry.word,
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (entry.jlptLevel != null)
                Text(
                  entry.jlptLevel!,
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            [
              entry.reading,
              if (entry.romaji?.isNotEmpty ?? false) entry.romaji!,
            ].where((part) => part.isNotEmpty).join(' · '),
            style: const TextStyle(color: AppColors.placeholder, fontSize: 14),
          ),
          if (entry.meanings.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final meaning in entry.meanings)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '${meaning.partOfSpeech == null ? '' : '${meaning.partOfSpeech}: '}${meaning.text}',
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
          ],
          if (entry.kanjis.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final kanji in entry.kanjis)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      [
                        kanji.character,
                        if (kanji.hanViet?.isNotEmpty ?? false) kanji.hanViet!,
                      ].join(' · '),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DictionaryAction extends StatelessWidget {
  const _DictionaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkText,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
    );
  }
}
