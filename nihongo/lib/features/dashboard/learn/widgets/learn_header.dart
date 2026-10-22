import 'package:flutter/material.dart';

/// Header của màn hình Học tập: Tiêu đề "Học tập".
class LearnHeader extends StatelessWidget {
  const LearnHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Học tập',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E242B),
      ),
    );
  }
}
