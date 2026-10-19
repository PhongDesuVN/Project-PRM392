import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Nền phong cách Nhật: mặt trời đỏ mờ, hoa anh đào rơi, sóng Seigaiha ở đáy.
/// Đặt file này tại: lib/shared/widgets/japanese_background.dart
class JapaneseBackground extends StatelessWidget {
  const JapaneseBackground({
    super.key,
    required this.child,
    this.petalCount = 14,
    this.showWaves = true,
    this.showSun = true,
  });

  final Widget child;
  final int petalCount;
  final bool showWaves;
  final bool showSun;

  @override
  Widget build(BuildContext context) {
    final random = math.Random(7);
    final petals = List.generate(petalCount, (_) => _Petal.random(random));

    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF6F7), Colors.white],
              stops: [0, 0.45],
            ),
          ),
        ),
        if (showSun)
          const IgnorePointer(child: RepaintBoundary(child: _SunLayer())),
        if (showWaves)
          const IgnorePointer(child: RepaintBoundary(child: _WaveLayer())),
        IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _PetalPainter(petals, 0),
              size: Size.infinite,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mặt trời đỏ
// ---------------------------------------------------------------------------

class _SunLayer extends StatelessWidget {
  const _SunLayer();

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _SunPainter(),
    size: Size.infinite,
  );
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width * 0.38;
    final center = Offset(size.width * 0.88, size.height * 0.1);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE23832).withValues(alpha: 0.16),
          const Color(0xFFE23832).withValues(alpha: 0.0),
        ],
        stops: const [0.55, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);

    canvas.drawCircle(
      center,
      radius * 0.55,
      Paint()..color = const Color(0xFFE23832).withValues(alpha: 0.07),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Sóng Seigaiha
// ---------------------------------------------------------------------------

class _WaveLayer extends StatelessWidget {
  const _WaveLayer();

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _SeigaihaPainter(),
    size: Size.infinite,
  );
}

class _SeigaihaPainter extends CustomPainter {
  static const _rows = 5;
  static const _rings = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 7; // bán kính vòng ngoài của mỗi cung sóng
    final step = r / 2; // khoảng cách dọc giữa các hàng
    const blue = Color(0xFF4F96E8);

    // Vẽ từ hàng trên (mờ) xuống hàng dưới (đậm) để hàng dưới đè lên.
    for (var row = _rows - 1; row >= 0; row--) {
      final y = size.height + r * 0.15 - row * step;
      final xOffset = row.isOdd ? r : 0.0;
      final opacity = 0.14 + (1 - row / _rows) * 0.26;

      for (double x = -r + xOffset; x < size.width + r; x += r * 2) {
        final center = Offset(x, y);

        // Nền trắng đục để che phần sóng của hàng phía sau
        canvas.drawCircle(center, r, Paint()..color = Colors.white);

        for (var i = 0; i < _rings; i++) {
          final ringRadius = r * (1 - i / _rings);
          canvas.drawCircle(
            center,
            ringRadius,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4
              ..color = blue.withValues(alpha: opacity),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Hoa anh đào rơi
// ---------------------------------------------------------------------------

class _Petal {
  _Petal({
    required this.x,
    required this.offset,
    required this.speed,
    required this.sway,
    required this.swayAmount,
    required this.phase,
    required this.size,
    required this.spin,
    required this.opacity,
  });

  final double x; // 0..1 theo chiều ngang
  final double offset; // 0..1 vị trí bắt đầu theo chiều dọc
  final int speed; // số lần rơi hết màn hình trong 1 vòng animation
  final int sway; // số lần đung đưa trong 1 vòng animation
  final double swayAmount;
  final double phase;
  final double size;
  final int spin; // số vòng xoay trong 1 vòng animation
  final double opacity;

  factory _Petal.random(math.Random r) => _Petal(
    x: r.nextDouble(),
    offset: r.nextDouble(),
    speed: 3 + r.nextInt(4),
    sway: 6 + r.nextInt(6),
    swayAmount: 14 + r.nextDouble() * 22,
    phase: r.nextDouble() * math.pi * 2,
    size: 7 + r.nextDouble() * 7,
    spin: 1 + r.nextInt(3),
    opacity: 0.35 + r.nextDouble() * 0.4,
  );
}

class _PetalPainter extends CustomPainter {
  _PetalPainter(this.petals, this.t);

  final List<_Petal> petals;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      final progress = (t * p.speed + p.offset) % 1.0;
      final y = progress * (size.height + 60) - 30;
      final x = p.x * size.width +
          math.sin(t * math.pi * 2 * p.sway + p.phase) * p.swayAmount;
      final angle = t * math.pi * 2 * p.spin + p.phase;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      _drawPetal(canvas, p.size, p.opacity);
      canvas.restore();
    }
  }

  void _drawPetal(Canvas canvas, double s, double opacity) {
    final path = Path()
      ..moveTo(0, -s)
      ..cubicTo(s * 0.9, -s * 0.7, s * 0.8, s * 0.5, 0, s)
      ..cubicTo(-s * 0.8, s * 0.5, -s * 0.9, -s * 0.7, 0, -s)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFC9D6).withValues(alpha: opacity),
            const Color(0xFFFF9DB5).withValues(alpha: opacity),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: s)),
    );

    // Khía nhỏ ở đầu cánh cho giống hoa anh đào
    canvas.drawLine(
      Offset(0, -s),
      Offset(0, -s * 0.55),
      Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PetalPainter oldDelegate) =>
      oldDelegate.t != t;
}