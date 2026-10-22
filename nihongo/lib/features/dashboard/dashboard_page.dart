import 'package:flutter/material.dart';

import '../../shared/japanese_background.dart';
import '../../shared/ui.dart';
import '../auth/auth_service.dart';
import '../auth/login/login_page.dart';
import 'dictionary/kanji_handwriting_page.dart';
import 'dictionary/dictionary_tab.dart';
import 'home_tab.dart';
import 'learn_tab.dart';
import 'learning_topic.dart';
import 'mock_exam/mock_exam_tab.dart';
import 'profile_tab.dart';
import 'topic_detail_page.dart';
import 'translation/translation_tab.dart';

/// Man hinh chinh sau dang nhap: kham pha, tu dien, dich, hoc tap va thi thu.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.email, this.fullName});

  final String email;
  final String? fullName;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _dictionaryTabIndex = 1;
  static const _translationTabIndex = 2;
  static const _learnTabIndex = 3;
  static const _mockExamTabIndex = 4;

  final _authService = AuthService();
  int _currentIndex = 0;
  String _dictionaryQuery = '';

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  void _selectTab(int index) => setState(() => _currentIndex = index);

  void _openTopic(LearningTopic topic) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => TopicDetailPage(topic: topic)),
    );
  }

  void _openDictionary([String query = '']) {
    setState(() {
      _dictionaryQuery = query;
      _currentIndex = _dictionaryTabIndex;
    });
  }

  Future<void> _openHandwritingSearch() async {
    final kanji = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(builder: (_) => const KanjiHandwritingPage()),
    );
    if (!mounted || kanji == null) return;
    _openDictionary(kanji);
  }

  void _showFeatureNotice(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature sẽ được kết nối trong bước tiếp theo.'),
        ),
      );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Hồ sơ'),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.darkText,
          ),
          body: JapaneseBackground(
            showWaves: false,
            child: SafeArea(
              child: ProfileTab(
                email: widget.email,
                fullName: widget.fullName,
                onLogout: _logout,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildTab() {
    // Chi build tab dang chon de cac tab khong giu state an va
    // khong render trung text khi test.
    switch (_currentIndex) {
      case 0:
        return HomeTab(
          fullName: widget.fullName,
          onSearch: _openDictionary,
          onOpenDictionary: () => _openDictionary(),
          onOpenTranslation: () => _selectTab(_translationTabIndex),
          onOpenLearning: () => _selectTab(_learnTabIndex),
          onOpenMockExam: () => _selectTab(_mockExamTabIndex),
          onOpenProfile: _openProfile,
          onCameraSearch: () => _showFeatureNotice('Tìm kiếm bằng ảnh'),
          onHandwritingSearch: _openHandwritingSearch,
          onTopicTap: _openTopic,
        );
      case 1:
        return DictionaryTab(
          initialQuery: _dictionaryQuery,
          onCameraSearch: () => _showFeatureNotice('Tìm kiếm bằng ảnh'),
          onHandwritingSearch: _openHandwritingSearch,
        );
      case 2:
        return const TranslationTab();
      case 3:
        return LearnTab(onTopicTap: _openTopic);
      default:
        return const MockExamTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JapaneseBackground(
        petalCount: 10,
        child: SafeArea(child: _buildTab()),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _selectTab,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.blue.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppColors.blue),
            label: 'Khám phá',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.blue),
            label: 'Từ điển',
          ),
          NavigationDestination(
            icon: Icon(Icons.g_translate_outlined),
            selectedIcon: Icon(Icons.g_translate, color: AppColors.blue),
            label: 'Dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school, color: AppColors.blue),
            label: 'Học tập',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check, color: AppColors.blue),
            label: 'Thi thử',
          ),
        ],
      ),
    );
  }
}
