import 'package:flutter/material.dart';

import '../../shared/japanese_background.dart';
import '../../shared/ui.dart';
import '../auth/auth_service.dart';
import '../auth/login/login_page.dart';
import 'home_tab.dart';
import 'learn_tab.dart';
import 'learning_topic.dart';
import 'profile_tab.dart';
import 'topic_detail_page.dart';

/// Man hinh chinh sau khi dang nhap: 3 tab Trang chu / Hoc / Ho so.
/// Cac chuc nang hoc se duoc noi vao sau, hien tai chi co khung giao dien.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.email, this.fullName});

  final String email;
  final String? fullName;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _learnTabIndex = 1;

  final _authService = AuthService();
  int _currentIndex = 0;

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  void _selectTab(int index) => setState(() => _currentIndex = index);

  void _openTopic(LearningTopic topic) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TopicDetailPage(topic: topic),
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
          onStartLearning: () => _selectTab(_learnTabIndex),
          onTopicTap: _openTopic,
        );
      case 1:
        return LearnTab(onTopicTap: _openTopic);
      default:
        return ProfileTab(
          email: widget.email,
          fullName: widget.fullName,
          onLogout: _logout,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JapaneseBackground(
        petalCount: 8,
        showWaves: false,
        child: SafeArea(child: _buildTab()),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _selectTab,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.blue.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.blue),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.blue),
            label: 'Học',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.blue),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
