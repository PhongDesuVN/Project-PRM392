import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Nền mang đậm phong cách văn hóa Nhật Bản:
/// - Tông chủ đạo: Núi Phú Sĩ hùng vĩ phủ tuyết trắng, vầng thái dương đỏ mờ và dải mây lượn ukiyo-e.
/// - Chi tiết cổ truyền Nhật Bản: Búp bê may mắn Daruma và bóng chiến binh Samurai.
/// - Hiệu ứng bay bổng: Cánh hoa anh đào (Sakura) hòa cùng lá phong đỏ (Momiji).
class JapaneseBackground extends StatelessWidget {
  const JapaneseBackground({
    super.key,
    required this.child,
    this.petalCount = 18,
    this.showWaves = true, // Tương thích ngược với các màn hình gọi cũ
    this.showSun = true,
  });

  final Widget child;
  final int petalCount;
  final bool showWaves;
  final bool showSun;

  @override
  Widget build(BuildContext context) {
    final random = math.Random(42);
    final elements = List.generate(
      petalCount,
      (index) => _FallingElement.random(random, index.isEven),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Nền chuyển sắc mềm mại phong cách giấy Washi Nhật Bản
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF4F2), // Ánh bình minh hồng đào nhẹ
                Color(0xFFF3F7FC), // Sương mù lam thanh mát
                Colors.white,
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),

        // 2. Núi Phú Sĩ và Vầng thái dương đỏ
        if (showSun)
          const IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _FujiAndSunPainter(),
                size: Size.infinite,
              ),
            ),
          ),

        // 3. Chi tiết Nhật cổ: Búp bê Daruma & Bóng Samurai
        const IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _JapaneseFolklorePainter(),
              size: Size.infinite,
            ),
          ),
        ),

        // 4. Hoa anh đào (Sakura) & Lá phong đỏ (Momiji) rơi nhẹ
        IgnorePointer(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _NatureElementsPainter(elements),
              size: Size.infinite,
            ),
          ),
        ),

        // 5. Nội dung chính của màn hình
        child,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 1. VẼ NÚI PHÚ SĨ VÀ MẶT TRỜI ĐỎ (MOUNT FUJI & RED RISING SUN)
// ---------------------------------------------------------------------------

class _FujiAndSunPainter extends CustomPainter {
  const _FujiAndSunPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Vị trí tâm núi Phú Sĩ
    final fujiCenterX = w * 0.52;
    final fujiTopY = h * 0.42;
    final fujiBaseY = h * 0.78;

    // 1. Vầng thái dương đỏ lớn phía sau đỉnh núi Phú Sĩ
    final sunCenter = Offset(w * 0.50, fujiTopY - h * 0.04);
    final sunRadius = w * 0.28;
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE23832).withValues(alpha: 0.18),
          const Color(0xFFE23832).withValues(alpha: 0.08),
          const Color(0xFFE23832).withValues(alpha: 0.0),
        ],
        stops: const [0.45, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius));
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // 2. Thân núi Phú Sĩ hình nón thoải (parabolic curves)
    final fujiPath = Path();
    final topHalfWidth = w * 0.07; // Đỉnh núi phẳng nhẹ đặc trưng
    final baseLeftX = -w * 0.15;
    final baseRightX = w * 1.15;

    fujiPath.moveTo(fujiCenterX - topHalfWidth, fujiTopY);
    // Sườn trái thoải cong dần ra chân núi
    fujiPath.cubicTo(
      fujiCenterX - w * 0.22,
      fujiTopY + h * 0.12,
      w * 0.10,
      fujiBaseY - h * 0.06,
      baseLeftX,
      fujiBaseY,
    );
    // Chân núi sang phải
    fujiPath.lineTo(baseRightX, fujiBaseY);
    // Sườn phải thoải cong lên đỉnh
    fujiPath.cubicTo(
      w * 0.90,
      fujiBaseY - h * 0.06,
      fujiCenterX + w * 0.22,
      fujiTopY + h * 0.12,
      fujiCenterX + topHalfWidth,
      fujiTopY,
    );
    fujiPath.close();

    // Đổ màu thân núi với sắc xanh chàm Ukiyo-e mờ tinh tế
    final fujiPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2C3E6B).withValues(alpha: 0.16),
          const Color(0xFF4A69BD).withValues(alpha: 0.08),
          const Color(0xFF4A69BD).withValues(alpha: 0.02),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTRB(baseLeftX, fujiTopY, baseRightX, fujiBaseY));
    canvas.drawPath(fujiPath, fujiPaint);

    // 3. Đỉnh tuyết phủ (Snow Crown của Phú Sĩ)
    final snowPath = Path();
    final snowBottomY = fujiTopY + h * 0.09;
    snowPath.moveTo(fujiCenterX - topHalfWidth, fujiTopY);
    snowPath.lineTo(fujiCenterX + topHalfWidth, fujiTopY);

    // Điểm dốc tuyết mép phải
    snowPath.lineTo(fujiCenterX + w * 0.12, snowBottomY);

    // Mép tuyết răng cưa lượn sóng tự nhiên
    snowPath.quadraticBezierTo(
      fujiCenterX + w * 0.08,
      snowBottomY - 8,
      fujiCenterX + w * 0.05,
      snowBottomY + 10,
    );
    snowPath.quadraticBezierTo(
      fujiCenterX + w * 0.02,
      snowBottomY - 5,
      fujiCenterX - w * 0.01,
      snowBottomY + 12,
    );
    snowPath.quadraticBezierTo(
      fujiCenterX - w * 0.05,
      snowBottomY - 7,
      fujiCenterX - w * 0.09,
      snowBottomY + 8,
    );
    snowPath.lineTo(fujiCenterX - w * 0.12, snowBottomY);
    snowPath.close();

    final snowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.85),
          Colors.white.withValues(alpha: 0.45),
        ],
      ).createShader(Rect.fromLTRB(
        fujiCenterX - w * 0.12,
        fujiTopY,
        fujiCenterX + w * 0.12,
        snowBottomY + 12,
      ));
    canvas.drawPath(snowPath, snowPaint);

    // 4. Dải mây truyền thống Kasumi mềm mại ngang sườn núi
    _drawJapaneseCloud(
      canvas,
      Offset(w * 0.15, fujiTopY + h * 0.16),
      w * 0.36,
      h * 0.035,
    );
    _drawJapaneseCloud(
      canvas,
      Offset(w * 0.62, fujiTopY + h * 0.19),
      w * 0.32,
      h * 0.032,
    );
  }

  void _drawJapaneseCloud(Canvas canvas, Offset pos, double width, double height) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final r = height / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pos.dx, pos.dy, width, height),
      Radius.circular(r),
    );
    canvas.drawRRect(rrect, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// 2. VẼ CHI TIẾT NHẬT CỔ: BÚP BÊ DARUMA & BÓNG SAMURAI
// ---------------------------------------------------------------------------

class _JapaneseFolklorePainter extends CustomPainter {
  const _JapaneseFolklorePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // A. Búp bê lật đật Daruma ở góc dưới bên phải
    _drawDarumaDoll(canvas, Offset(w * 0.84, h * 0.78), w * 0.11);

    // B. Bóng Samurai hiên ngang ở sườn đồi bên trái
    _drawSamuraiSilhouette(canvas, Offset(w * 0.12, h * 0.74), w * 0.14);
  }

  /// Vẽ búp bê lật đật Daruma may mắn
  void _drawDarumaDoll(Canvas canvas, Offset center, double radius) {
    // 1. Thân tròn đỏ rực may mắn của Daruma
    final bodyPaint = Paint()
      ..color = const Color(0xFFD63031).withValues(alpha: 0.26)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bodyPaint);

    // Viền nhẹ thân
    final borderPaint = Paint()
      ..color = const Color(0xFFC0392B).withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(center, radius, borderPaint);

    // 2. Vùng mặt trắng bầu dục đặc trưng
    final faceRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - radius * 0.12),
      width: radius * 1.25,
      height: radius * 1.05,
    );
    final facePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;
    canvas.drawOval(faceRect, facePaint);

    // 3. Lông mày hình chim hạc (tsuru) cong rậm rạp
    final inkPaint = Paint()
      ..color = const Color(0xFF2C3E50).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Lông mày trái & phải
    final browY = center.dy - radius * 0.35;
    final browLeft = Path()
      ..moveTo(center.dx - radius * 0.45, browY + 3)
      ..quadraticBezierTo(
        center.dx - radius * 0.28,
        browY - 8,
        center.dx - radius * 0.08,
        browY + 1,
      );
    canvas.drawPath(browLeft, inkPaint);

    final browRight = Path()
      ..moveTo(center.dx + radius * 0.45, browY + 3)
      ..quadraticBezierTo(
        center.dx + radius * 0.28,
        browY - 8,
        center.dx + radius * 0.08,
        browY + 1,
      );
    canvas.drawPath(browRight, inkPaint);

    // 4. Mắt to tròn vẽ mực
    final eyeRadius = radius * 0.13;
    final eyeY = center.dy - radius * 0.14;
    canvas.drawCircle(
      Offset(center.dx - radius * 0.26, eyeY),
      eyeRadius,
      inkPaint..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.26, eyeY),
      eyeRadius,
      inkPaint..style = PaintingStyle.stroke,
    );

    // 5. Ria mép rùa (kame) uốn lượn dưới mũi
    final beardPath = Path()
      ..moveTo(center.dx - radius * 0.35, center.dy + radius * 0.15)
      ..quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.05,
        center.dx + radius * 0.35,
        center.dy + radius * 0.15,
      );
    canvas.drawPath(beardPath, inkPaint);

    // 6. Họa tiết vàng kim may mắn trước bụng
    final goldPaint = Paint()
      ..color = const Color(0xFFF39C12).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.45),
        width: radius * 0.8,
        height: radius * 0.45,
      ),
      0.3,
      math.pi - 0.6,
      false,
      goldPaint,
    );
  }

  /// Vẽ bóng kiếm sĩ Samurai Nhật cổ hiên ngang
  void _drawSamuraiSilhouette(Canvas canvas, Offset base, double scale) {
    final samuraiPaint = Paint()
      ..color = const Color(0xFF2C3E50).withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;

    final path = Path();
    final x = base.dx;
    final y = base.dy;
    final s = scale;

    // 1. Nón giáp Kabuto & sừng trăng khuyết Kuwagata
    final headY = y - s * 1.55;
    // Sừng trăng khuyết vươn cao
    path.moveTo(x - s * 0.25, headY - s * 0.35);
    path.quadraticBezierTo(x, headY - s * 0.15, x + s * 0.25, headY - s * 0.35);
    path.lineTo(x + s * 0.18, headY - s * 0.18);
    path.quadraticBezierTo(x, headY - s * 0.08, x - s * 0.18, headY - s * 0.18);
    path.close();

    // Vành nón Kabuto tròn
    path.addOval(Rect.fromCenter(
      center: Offset(x, headY),
      width: s * 0.65,
      height: s * 0.35,
    ));

    // 2. Thân giáp và áo choàng Haori
    final bodyPath = Path();
    bodyPath.moveTo(x - s * 0.15, headY + s * 0.15);
    // Giáp vai O-sode bồng bềnh
    bodyPath.lineTo(x - s * 0.45, headY + s * 0.45);
    bodyPath.lineTo(x - s * 0.35, y);
    // Vạt áo giáp dưới
    bodyPath.lineTo(x + s * 0.35, y);
    bodyPath.lineTo(x + s * 0.45, headY + s * 0.45);
    bodyPath.lineTo(x + s * 0.15, headY + s * 0.15);
    bodyPath.close();

    canvas.drawPath(path, samuraiPaint);
    canvas.drawPath(bodyPath, samuraiPaint);

    // 3. Thanh kiếm Katana dài đeo bên hông chéo
    final swordPaint = Paint()
      ..color = const Color(0xFF2C3E50).withValues(alpha: 0.24)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(x - s * 0.55, y - s * 0.20),
      Offset(x + s * 0.50, y + s * 0.18),
      swordPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// 3. VẼ HOA ANH ĐÀO (SAKURA) VÀ LÁ PHONG ĐỎ (MOMIJI) RƠI NHẸ
// ---------------------------------------------------------------------------

enum _NatureType { sakura, momiji }

class _FallingElement {
  _FallingElement({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.opacity,
    required this.type,
  });

  final double x; // 0..1
  final double y; // 0..1
  final double size;
  final double rotation;
  final double opacity;
  final _NatureType type;

  factory _FallingElement.random(math.Random r, bool isSakura) {
    return _FallingElement(
      x: r.nextDouble(),
      y: r.nextDouble(),
      size: isSakura ? (8 + r.nextDouble() * 8) : (13 + r.nextDouble() * 9),
      rotation: r.nextDouble() * math.pi * 2,
      opacity: 0.32 + r.nextDouble() * 0.45,
      type: isSakura ? _NatureType.sakura : _NatureType.momiji,
    );
  }
}

class _NatureElementsPainter extends CustomPainter {
  const _NatureElementsPainter(this.elements);

  final List<_FallingElement> elements;

  @override
  void paint(Canvas canvas, Size size) {
    for (final el in elements) {
      final posX = el.x * size.width;
      final posY = el.y * size.height;

      canvas.save();
      canvas.translate(posX, posY);
      canvas.rotate(el.rotation);

      if (el.type == _NatureType.sakura) {
        _drawSakuraPetal(canvas, el.size, el.opacity);
      } else {
        _drawMomijiLeaf(canvas, el.size, el.opacity);
      }

      canvas.restore();
    }
  }

  /// Vẽ cánh hoa anh đào với khía nhỏ đầu cánh
  void _drawSakuraPetal(Canvas canvas, double s, double opacity) {
    final path = Path()
      ..moveTo(0, -s)
      ..cubicTo(s * 0.9, -s * 0.7, s * 0.8, s * 0.5, 0, s)
      ..cubicTo(-s * 0.8, s * 0.5, -s * 0.9, -s * 0.7, 0, -s)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFB8C6).withValues(alpha: opacity),
          const Color(0xFFFF8DA1).withValues(alpha: opacity),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: s));

    canvas.drawPath(path, paint);

    // Khía nhỏ đầu cánh hoa anh đào
    canvas.drawLine(
      Offset(0, -s),
      Offset(0, -s * 0.58),
      Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.9)
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Vẽ lá phong Momiji 5 thùy đặc trưng của mùa thu Nhật Bản
  void _drawMomijiLeaf(Canvas canvas, double s, double opacity) {
    final path = Path();
    // Cuống lá
    path.moveTo(0, s * 0.9);
    path.lineTo(0, s * 0.3);

    // 5 thùy lá phong vươn ra các hướng
    // Thùy 1 (dưới trái)
    path.lineTo(-s * 0.75, s * 0.45);
    path.lineTo(-s * 0.45, s * 0.1);
    // Thùy 2 (ngang trái)
    path.lineTo(-s * 0.95, -s * 0.15);
    path.lineTo(-s * 0.4, -s * 0.3);
    // Thùy 3 (đỉnh chính)
    path.lineTo(0, -s);
    path.lineTo(s * 0.4, -s * 0.3);
    // Thùy 4 (ngang phải)
    path.lineTo(s * 0.95, -s * 0.15);
    path.lineTo(s * 0.45, s * 0.1);
    // Thùy 5 (dưới phải)
    path.lineTo(s * 0.75, s * 0.45);
    path.close();

    final leafPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD63031).withValues(alpha: opacity * 0.85), // Đỏ lá phong
          const Color(0xFFE17055).withValues(alpha: opacity * 0.85), // Đỏ cam hổ phách
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: s));

    canvas.drawPath(path, leafPaint);

    // Gân lá phong
    final veinPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.5)
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, s * 0.8), Offset(0, -s * 0.85), veinPaint);
    canvas.drawLine(Offset(0, 0), Offset(-s * 0.65, -s * 0.1), veinPaint);
    canvas.drawLine(Offset(0, 0), Offset(s * 0.65, -s * 0.1), veinPaint);
  }

  @override
  bool shouldRepaint(covariant _NatureElementsPainter oldDelegate) => false;
}