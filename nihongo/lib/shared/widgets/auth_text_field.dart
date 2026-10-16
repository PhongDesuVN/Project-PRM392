import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1.2),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Icon(widget.prefixIcon, color: AppColors.border, size: 22),
          ),
          Container(width: 1, height: 34, color: AppColors.border),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.isPassword && _obscureText,
              validator: widget.validator,
              textInputAction: widget.textInputAction,
              autocorrect: false,
              style: const TextStyle(fontSize: 18, color: AppColors.darkText),
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
    );
  }
}