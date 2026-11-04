import 'package:flutter/material.dart';

/// Mau va theme dung chung.
class AppColors {
  static const canvas = Color(0xFFFAF6F1);
  static const surface = Color(0xFFFFFDFB);
  static const primary = Color(0xFFB93B32);
  static const primarySoft = Color(0xFFF7E6E1);
  static const accent = Color(0xFF607A5B);
  static const gold = Color(0xFFC19243);
  static const ink = Color(0xFF2D2926);
  static const muted = Color(0xFF746B66);
  static const border = Color(0xFFE8DCD4);

  // Compatibility aliases for existing feature widgets.
  static const blue = primary;
  static const darkText = ink;
  static const placeholder = Color(0xFF9A918B);
  static const googleBackground = Color(0xFFFFFEFA);
  static const googleRed = Color(0xFFB44136);
  static const error = Color(0xFFB42318);
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'serif',
          color: AppColors.ink,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'serif',
          color: AppColors.ink,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontFamily: 'serif',
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: AppColors.ink, fontSize: 16, height: 1.45),
        bodyMedium: TextStyle(
          color: AppColors.muted,
          fontSize: 14,
          height: 1.4,
        ),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(color: AppColors.placeholder),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          animationDuration: const Duration(milliseconds: 160),
          minimumSize: const Size(48, 50),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          overlayColor: AppColors.gold.withValues(alpha: 0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1.5,
          shadowColor: AppColors.primary.withValues(alpha: 0.24),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          animationDuration: const Duration(milliseconds: 160),
          minimumSize: const Size(48, 48),
          foregroundColor: AppColors.ink,
          overlayColor: AppColors.accent.withValues(alpha: 0.08),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titleTextStyle: const TextStyle(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primarySoft,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: const TextStyle(color: AppColors.ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? AppColors.primary : AppColors.muted,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionHandleColor: AppColors.primary,
      ),
    );
  }
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
            borderRadius: BorderRadius.circular(12),
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
                    fontSize: 16,
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
                            tooltip: _obscureText
                                ? 'Hiện mật khẩu'
                                : 'Ẩn mật khẩu',
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
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
