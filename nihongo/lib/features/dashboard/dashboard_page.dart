import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../shared/japanese_background.dart';
import '../../shared/ui.dart';
import '../auth/auth_service.dart';
import '../auth/login/login_page.dart';
import '../camera_ocr/camera_ocr_page.dart';
import 'dictionary/kanji_handwriting_page.dart';
import 'dictionary/dictionary_tab.dart';
import 'home_tab.dart';
import 'learn/notebook/services/notebook_service.dart';
import 'learn_tab.dart';
import 'learning_topic.dart';
import 'mock_exam/mock_exam_tab.dart';
import 'profile_tab.dart';
import 'search_history_service.dart';
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
  int _learnInitialTabIndex = 0;

  bool get _isGuest => widget.email.isEmpty || widget.fullName == 'Khách';

  @override
  void initState() {
    super.initState();
    NotebookService.instance.switchUser(
      email: _isGuest ? null : widget.email,
      userId: null,
      isGuest: _isGuest,
    );
    SearchHistoryService.instance.switchUser(_isGuest ? null : widget.email);
  }

  void _requireLogin(String featureName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline_rounded, color: AppColors.blue),
            SizedBox(width: 8),
            Text(
              'Yêu cầu đăng nhập',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Bạn cần đăng nhập tài khoản để sử dụng $featureName và lưu tiến độ học tập cá nhân.',
          style: const TextStyle(fontSize: 14.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              );
            },
            child: const Text(
              'Đăng nhập',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  void _selectTab(int index) => setState(() => _currentIndex = index);

  void _openAlphabetLibrary() {
    setState(() {
      _learnInitialTabIndex = 1;
      _currentIndex = _learnTabIndex;
    });
  }

  void _openTopic(LearningTopic topic) {
    if (_isGuest) {
      _requireLogin('học bài "${topic.title}"');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => TopicDetailPage(topic: topic)),
    );
  }

  void _openDictionary([String query = '']) {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      SearchHistoryService.instance.addKeyword(trimmed);
    }
    setState(() {
      _dictionaryQuery = trimmed;
      _currentIndex = _dictionaryTabIndex;
    });
  }

  Future<void> _openHandwritingSearch() async {
    final kanji = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(builder: (_) => const KanjiHandwritingPage()),
    );
    if (!mounted || kanji == null || kanji.trim().isEmpty) return;
    final trimmed = kanji.trim();
    SearchHistoryService.instance.addKeyword(trimmed);
    _openDictionary(trimmed);
  }

  Future<void> _openCameraSearch() async {
    final result = await Navigator.push<CameraOcrResultData>(
      context,
      MaterialPageRoute<CameraOcrResultData>(
        builder: (_) => const CameraOcrPage(),
      ),
    );
    if (!mounted || result == null || result.query.trim().isEmpty) return;
    final trimmed = result.query.trim();

    if (result.targetAction == 'translate') {
      _selectTab(_translationTabIndex);
    } else {
      SearchHistoryService.instance.addKeyword(trimmed);
      _openDictionary(trimmed);
    }
  }

  void _openProfile() {
    if (_isGuest) {
      _requireLogin('Hồ sơ cá nhân');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: AppBar(
            title: const Text(
              'Hồ sơ cá nhân',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.darkText,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
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
    NotebookService.instance.switchUser(
      email: null,
      userId: null,
      isGuest: true,
    );
    SearchHistoryService.instance.switchUser(null);
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
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
          onOpenLearning: () {
            setState(() {
              _learnInitialTabIndex = 0;
              _currentIndex = _learnTabIndex;
            });
          },
          onOpenAlphabetLibrary: _openAlphabetLibrary,
          onOpenMockExam: () => _selectTab(_mockExamTabIndex),
          onOpenProfile: _openProfile,
          onCameraSearch: _openCameraSearch,
          onHandwritingSearch: _openHandwritingSearch,
          onTopicTap: _openTopic,
        );
      case 1:
        return DictionaryTab(
          initialQuery: _dictionaryQuery,
          onCameraSearch: _openCameraSearch,
          onHandwritingSearch: _openHandwritingSearch,
        );
      case 2:
        return const TranslationTab();
      case 3:
        return LearnTab(
          key: ValueKey('learn_tab_$_learnInitialTabIndex'),
          initialTabIndex: _learnInitialTabIndex,
          onTopicTap: _openTopic,
          isGuest: _isGuest,
        );
      default:
        return MockExamTab(isGuest: _isGuest);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: JapaneseBackground(
        petalCount: 6,
        child: SafeArea(child: _buildTab()),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == _learnTabIndex && _currentIndex != _learnTabIndex) {
            _learnInitialTabIndex = 0;
          }
          _selectTab(index);
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
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
