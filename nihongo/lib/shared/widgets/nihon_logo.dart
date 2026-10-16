import 'dart:math' as math;

import 'package:flutter/material.dart';

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
            'n',
            style: TextStyle(
              color: Color(0xFF1670D2),
              fontSize: 54,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          SizedBox(
            width: 60,
            height: 68,
            child: CustomPaint(
              painter: _MagnifierPainter(),
              child: const Align(
                // Canh chữ vào đúng tâm lens (26, 26) trong khung 60x68.
                alignment: Alignment(-0.133, -0.235),
                child: Text(
                  'い',
                  style: TextStyle(
                    color: Color(0xFFE23832),
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          const Text(
            'hon',
            style: TextStyle(
              color: Color(0xFF1670D2),
              fontSize: 54,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vẽ kính lúp: cán mọc ra từ rìa vành theo hướng chéo 45 độ.
class _MagnifierPainter extends CustomPainter {
  static const _ink = Color(0xFF171717);
  static const _center = Offset(26, 26);
  static const _lensRadius = 22.0;
  static const _ringWidth = 4.0;
  static const _handleLength = 16.0;
  static const _handleWidth = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final dir = Offset(math.cos(math.pi / 4), math.sin(math.pi / 4));
    final start = _center + dir * (_lensRadius + 1);
    final end = _center + dir * (_lensRadius + 1 + _handleLength);

    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = _ink
        ..strokeWidth = _handleWidth
        ..strokeCap = StrokeCap.round,
    );

    // Vẽ vành sau cán để vành che chân cán, tạo mối nối liền mạch.
    canvas.drawCircle(
      _center,
      _lensRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringWidth
        ..color = _ink,
    );
  }

  @override
  bool shouldRepaint(covariant _MagnifierPainter oldDelegate) => false;
}
