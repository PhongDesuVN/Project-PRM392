import 'package:flutter/material.dart';

import '../../../shared/japanese_background.dart';
import '../../../shared/ui.dart';
import '../auth_service.dart';
import '../login/login_page.dart';

/// Man hinh tam sau khi dang nhap thanh cong, dung de xac nhan
/// luong auth da chay thong. Se duoc thay bang man hinh hoc that sau.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.email, this.fullName});

  final String email;
  final String? fullName;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final name = widget.fullName?.trim();

    return Scaffold(
      body: JapaneseBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.blue,
                    size: 72,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    name != null && name.isNotEmpty
                        ? 'Xin chào, $name'
                        : 'Đăng nhập thành công',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.blue,
                        side: const BorderSide(color: AppColors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
