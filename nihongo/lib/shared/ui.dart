import 'package:flutter/material.dart';

/// Mau va theme dung chung.
class AppColors {
  static const blue = Color(0xFF4F96E8);
  static const darkText = Color(0xFF555A60);
  static const placeholder = Color(0xFFA8AAAC);
  static const border = Color(0xFFE1E2E4);
  static const googleBackground = Color(0xFFFCEBEC);
  static const googleRed = Color(0xFFD83A3A);
  static const error = Color(0xFFD32F2F);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          primary: AppColors.blue,
        ),
        fontFamily: 'Roboto',
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.blue,
          selectionHandleColor: AppColors.blue,
        ),
      );
}
/// O input dung chung cho cac form auth: icon ben trai, toggle an/hien
/// mat khau, va dong text loi rieng ben duoi khung.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.textInputAction,
  });

  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;
  String? _errorText;

  /// TextFormField ben trong an errorStyle de giu khung cao 56px, nen loi
  /// duoc bat o day va ve lai thanh dong text rieng ben duoi.
  String? _runValidator(String? value) {
    final error = widget.validator?.call(value);
    if (error != _errorText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _errorText = error);
      });
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.border,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Icon(
                  widget.prefixIcon,
                  color: hasError ? AppColors.error : AppColors.border,
                  size: 22,
                ),
              ),
              Container(width: 1, height: 34, color: AppColors.border),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.isPassword && _obscureText,
                  validator: widget.validator == null ? null : _runValidator,
                  textInputAction: widget.textInputAction,
                  autocorrect: false,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.darkText,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(color: AppColors.placeholder),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: InputBorder.none,
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                    suffixIcon: widget.isPassword
                        ? IconButton(
                            tooltip:
                                _obscureText ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                            onPressed: () =>
                                setState(() => _obscureText = !_obscureText),
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.placeholder,
                              size: 21,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              _errorText!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
      ],
    );
  }
}



class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.googleBackground,
          foregroundColor: AppColors.googleRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'G',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4285F4),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Đăng nhập với Google',
              style: TextStyle(
                color: AppColors.googleRed,
                fontSize: 19,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
