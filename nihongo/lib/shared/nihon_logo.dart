import 'package:flutter/material.dart';

import 'ui.dart';

class NihonLogo extends StatelessWidget {
  const NihonLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nihon',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'nihon',
            style: TextStyle(
              color: AppColors.ink,
              fontFamily: 'serif',
              fontSize: 38,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(width: 7),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.78, end: 1),
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutBack,
            builder: (context, progress, child) => Transform.rotate(
              angle: (1 - progress) * -0.18,
              child: Transform.scale(scale: progress, child: child),
            ),
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                '日本',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'serif',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
