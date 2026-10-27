import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../../core/api.dart';
import '../../../shared/ui.dart';

import '../../../shared/nihon_logo.dart';
import '../auth_service.dart';
import '../forgot_password/forgot_password_dialog.dart';
import '../../dashboard/dashboard_page.dart';
import '../register/register_page.dart';
import '../../../shared/japanese_background.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authService.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              DashboardPage(email: result.email, fullName: result.fullName),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      // 1. Mở popup đăng nhập tài khoản Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Người dùng ấn hủy đăng nhập
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 2. Lấy Credential xác thực với Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // 3. Lấy Firebase ID Token để gửi về Spring Boot
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        await _authenticateWithBackend(idToken, userCredential.user);
      } else {
        if (!mounted) return;
        _showMessage('Không lấy được ID Token từ Firebase.');
      }
    } catch (e) {
      debugPrint('Lỗi xác thực Google: $e');
      if (mounted) {
        _showMessage('Lỗi xác thực Google: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _authenticateWithBackend(
    String idToken,
    User? firebaseUser,
  ) async {
    // 10.0.2.2 trỏ về localhost nếu chạy trên Android Emulator
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/google');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        debugPrint('Đăng nhập thành công với Backend: ${response.body}');

        String token = '';
        String email = firebaseUser?.email ?? '';
        String? fullName = firebaseUser?.displayName;

        try {
          final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
          if (data is Map<String, dynamic>) {
            token = data['token'] as String? ?? '';
            email = data['email'] as String? ?? email;
            fullName = data['fullName'] as String? ?? fullName;
          }
        } catch (_) {}

        if (token.isNotEmpty) {
          await _authService.storage.save(
            token: token,
            email: email,
            fullName: fullName,
          );
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => DashboardPage(email: email, fullName: fullName),
          ),
        );
      } else {
        debugPrint(
          'Backend trả lỗi: ${response.statusCode} - ${response.body}',
        );
        String errorMessage = 'Backend trả lỗi: ${response.statusCode}';
        try {
          final dynamic errorData = jsonDecode(utf8.decode(response.bodyBytes));
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        } catch (_) {}
        if (!mounted) return;
        _showMessage(errorMessage);
      }
    } on SocketException {
      if (!mounted) return;
      _showMessage(
        'Không thể kết nối đến backend server ($url). Vui lòng kiểm tra server.',
      );
    } on TimeoutException {
      if (!mounted) return;
      _showMessage('Server phản hồi quá lâu. Vui lòng thử lại.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Lỗi kết nối Backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JapaneseBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 16,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'Quay lại',
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF888888),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const NihonLogo(),
                    const SizedBox(height: 72),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AuthTextField(
                            hintText: 'Nhập email của bạn',
                            prefixIcon: Icons.person_outline,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            hintText: 'Mật khẩu',
                            prefixIcon: Icons.visibility_outlined,
                            isPassword: true,
                            controller: _passwordController,
                            textInputAction: TextInputAction.done,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Vui lòng nhập mật khẩu'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PrimaryButton(
                      label: 'Đăng nhập',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _submit,
                    ),
                    const SizedBox(height: 22),
                    TextButton(
                      onPressed: () => showForgotPasswordDialog(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.darkText,
                      ),
                      child: const Text(
                        'Quên mật khẩu?',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GoogleSignInButton(
                      onPressed: _isLoading ? () {} : _signInWithGoogle,
                    ),
                    const SizedBox(height: 68),
                    Padding(
                      padding: const EdgeInsets.only(top: 68, bottom: 24),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Bạn chưa có tài khoản Nihon?',
                            style: TextStyle(
                              color: AppColors.darkText,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const RegisterPage(),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                            ),
                            child: const Text(
                              'Đăng kí',
                              style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!value.contains('@')) return 'Email không hợp lệ';
    return null;
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(label, style: const TextStyle(fontSize: 19)),
      ),
    );
  }
}
