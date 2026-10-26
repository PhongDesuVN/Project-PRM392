import 'package:flutter/material.dart';

import 'models/alphabet_models.dart';
import 'services/alphabet_service.dart';
import 'widgets/alphabet_section_view.dart';

/// Màn hình hiển thị bảng chữ cái tiếng Nhật (Hiragana / Katakana)
/// Hỗ trợ đầy đủ 3 kiểu phân loại:
/// 1. Gojuuon (Ngũ thập âm)
/// 2. Dakuon & Handakuon (Biến âm & Bán biến âm)
/// 3. Youon (Ảo âm / Âm ghép)
class AlphabetPage extends StatefulWidget {
  const AlphabetPage({
    super.key,
    this.script = AlphabetScript.hiragana,
  });

  final AlphabetScript script;

  @override
  State<AlphabetPage> createState() => _AlphabetPageState();
}

class _AlphabetPageState extends State<AlphabetPage>
    with SingleTickerProviderStateMixin {
  late final AlphabetService _alphabetService;
  late final TabController _tabController;

  AlphabetResponse? _alphabetData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _alphabetService = AlphabetService();
    _loadAlphabetData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _alphabetService.dispose();
    super.dispose();
  }

  Future<void> _loadAlphabetData() async {
    final data = await _alphabetService.fetchAlphabet(widget.script);
    if (!mounted) return;
    setState(() {
      _alphabetData = data;
      _isLoading = false;
    });
  }

  void _showCharacterDetails(AlphabetItem item) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(
            'Ký tự: ${item.character}  •  Phiên âm: ${item.romaji}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.script == AlphabetScript.katakana
        ? 'Bảng chữ cái Kata'
        : 'Bảng chữ cái Hira';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1E242B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E242B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.settings_outlined, color: Color(0xFF718096)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF1976D2),
              unselectedLabelColor: const Color(0xFF8F9CA9),
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              indicatorColor: const Color(0xFF1976D2),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Gojuuon'),
                Tab(text: 'Dakuon & Handakuon'),
                Tab(text: 'Youon'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF1976D2),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSectionView('gojuuon'),
                _buildSectionView('dakuon'),
                _buildSectionView('youon'),
              ],
            ),
    );
  }

  Widget _buildSectionView(String type) {
    final sections = _alphabetData?.sections ?? [];
    final section = sections.firstWhere(
      (s) => s.type == type,
      orElse: () => AlphabetSection(
        type: type,
        title: type,
        columns: type == 'youon' ? 3 : 5,
        grid: const [],
      ),
    );

    return AlphabetSectionView(
      section: section,
      onCharacterTap: _showCharacterDetails,
    );
  }
}
