import 'package:flutter/material.dart';

import '../../../core/api.dart';
import '../../../shared/japanese_background.dart';
import '../../../shared/nihon_logo.dart';
import '../../../shared/ui.dart';
import '../auth_service.dart';
import '../../dashboard/dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _acceptedTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      _showMessage('Vui lòng đồng ý với điều khoản sử dụng.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _authService.register(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _fullNameController.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (_) =>
              DashboardPage(email: result.email, fullName: result.fullName),
        ),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: JapaneseBackground(
        petalCount: 6,
        showSun: false,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nút quay lại tròn thanh lịch
                    InkWell(
                      onTap: () => Navigator.maybePop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Logo & Tiêu đề trang
                    const Center(
                      child: Column(
                        children: [
                          NihonLogo(fontSize: 28),
                          SizedBox(height: 6),
                          Text(
                            'Bắt đầu hành trình chinh phục tiếng Nhật',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Tạo tài khoản',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Đăng ký nhanh chóng để lưu tiến độ và sổ tay từ vựng.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AuthTextField(
                            labelText: 'Họ và tên',
                            hintText: 'Nhập họ và tên của bạn',
                            prefixIcon: Icons.person_outline_rounded,
                            controller: _fullNameController,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Vui lòng nhập họ và tên'
                                    : null,
                          ),
                          const SizedBox(height: 14),
                          AuthTextField(
                            labelText: 'Email',
                            hintText: 'Nhập email của bạn',
                            prefixIcon: Icons.mail_outline_rounded,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),
                          AuthTextField(
                            labelText: 'Mật khẩu',
                            hintText: 'Tạo mật khẩu (tối thiểu 6 ký tự)',
                            prefixIcon: Icons.lock_outline_rounded,
                            isPassword: true,
                            controller: _passwordController,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value == null || value.length < 6
                                    ? 'Mật khẩu cần ít nhất 6 ký tự'
                                    : null,
                          ),
                          const SizedBox(height: 14),
                          AuthTextField(
                            labelText: 'Xác nhận mật khẩu',
                            hintText: 'Nhập lại mật khẩu',
                            prefixIcon: Icons.lock_reset_rounded,
                            isPassword: true,
                            controller: _confirmPasswordController,
                            textInputAction: TextInputAction.done,
                            validator: (value) =>
                                value != _passwordController.text
                                    ? 'Mật khẩu nhập lại chưa khớp'
                                    : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Điều khoản sử dụng
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _acceptedTerms,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            side: const BorderSide(
                              color: Color(0xFFCBD5E1),
                              width: 1.5,
                            ),
                            onChanged: (value) =>
                                setState(() => _acceptedTerms = value ?? false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Tôi đồng ý với ',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13.5,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showMessage(
                                  'Điều khoản sử dụng của Nihon.',
                                ),
                                child: const Text(
                                  'Điều khoản sử dụng',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Text(
                                ' & ',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13.5,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showMessage(
                                  'Chính sách bảo mật của Nihon.',
                                ),
                                child: const Text(
                                  'Chính sách bảo mật',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Nút Đăng ký chính
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF2563EB).withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : _submit,
                          borderRadius: BorderRadius.circular(14),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Tạo tài khoản',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Footer đăng nhập
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Bạn đã có tài khoản? ',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Đăng nhập ngay',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

