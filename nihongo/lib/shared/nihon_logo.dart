import 'package:flutter/material.dart';

import 'ui.dart';

/// Logo chính thức của ứng dụng:
/// Biểu tượng Monogram chữ "N" cách điệu mang dáng dấp Cổng trời Torii Nhật Bản
/// kết hợp Vầng thái dương đỏ (Hinomaru 日の丸) và tên thương hiệu đầy đủ "Nihongo".
class NihonLogo extends StatelessWidget {
  const NihonLogo({
    super.key,
    this.fontSize = 28,
    this.showBadge = true,
    this.showTagline = false,
  });

  final double fontSize;
  final bool showBadge;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final iconSize = fontSize * 1.22;

    return Semantics(
      label: 'Nihongo',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Biểu tượng độc quyền: Chữ "N" cách điệu cổng Torii & Mặt trời đỏ Nhật Bản
          NihonLogoIcon(size: iconSize),
          const SizedBox(width: 10),

          // 2. Tên thương hiệu đầy đủ "Nihongo" thiết kế hiện đại
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    height: 1.0,
                  ),
                  children: const [
                    TextSpan(text: 'Nihon'),
                    TextSpan(
                      text: 'go',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              if (showTagline) ...[
                const SizedBox(height: 3),
                Text(
                  'HỌC TIẾNG NHẬT THÔNG MINH',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: fontSize * 0.32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    height: 1.0,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Biểu tượng Monogram độc lập (App Icon mark) của Nihongo
class NihonLogoIcon extends StatelessWidget {
  const NihonLogoIcon({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.28),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: const _NihongoToriiMonogramPainter(),
      ),
    );
  }
}

/// Họa sĩ vẽ vector chữ "N" cách điệu kết hợp Cổng trời Torii và Mặt trời mọc Hinomaru
class _NihongoToriiMonogramPainter extends CustomPainter {
  const _NihongoToriiMonogramPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. VẦNG THÁI DƯƠNG NHẬT BẢN (HINOMARU 日の丸)
    // Tượng trưng cho đất nước mặt trời mọc & nguồn sáng tri thức
    final sunCenter = Offset(w * 0.50, h * 0.44);
    final sunRadius = w * 0.19;

    // Quầng hào quang nhẹ
    final glowPaint = Paint()
      ..color = const Color(0xFFDC2626).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(sunCenter, sunRadius * 1.3, glowPaint);

    // Mặt trời đỏ son Nhật Bản
    final sunPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius));
    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // 2. CHỮ "N" CÁCH ĐIỆU CỔNG TORII
    final strokeW = w * 0.125;
    final leftX = w * 0.29;
    final rightX = w * 0.71;
    final topY = h * 0.24;
    final bottomY = h * 0.77;

    // 2.1 Mái cổng Torii (Kasagi - 笠木) cong vút nhẹ đặc trưng ở đỉnh chữ N
    final roofPath = Path();
    final roofLeft = w * 0.15;
    final roofRight = w * 0.85;
    final roofCenterY = h * 0.23;
    final roofCurve = h * 0.035;

    // Đường cong cạnh trên mái
    roofPath.moveTo(roofLeft, roofCenterY - roofCurve);
    roofPath.quadraticBezierTo(
      w * 0.5,
      roofCenterY + roofCurve * 0.2,
      roofRight,
      roofCenterY - roofCurve,
    );
    // Vát góc phải
    roofPath.lineTo(roofRight + w * 0.015, roofCenterY - roofCurve + h * 0.045);
    // Đường cong cạnh dưới mái
    roofPath.quadraticBezierTo(
      w * 0.5,
      roofCenterY + roofCurve * 0.2 + h * 0.045,
      roofLeft - w * 0.015,
      roofCenterY - roofCurve + h * 0.045,
    );
    roofPath.close();

    final whiteFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(roofPath, whiteFill);

    // 2.2 Thân chữ N: 2 cột trụ Torii và nét chéo vươn lên
    final nPath = Path()
      ..moveTo(leftX, bottomY)
      ..lineTo(leftX, topY)
      ..lineTo(rightX, bottomY)
      ..lineTo(rightX, topY);

    final nPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(nPath, nPaint);

    // 2.3 Chân đế cột Torii vững chãi
    final baseWidth = strokeW * 1.35;
    final baseHeight = h * 0.045;
    final basePaint = Paint()..color = const Color(0xFFDBEAFE);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(leftX, bottomY),
          width: baseWidth,
          height: baseHeight,
        ),
        const Radius.circular(2),
      ),
      basePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(rightX, bottomY),
          width: baseWidth,
          height: baseHeight,
        ),
        const Radius.circular(2),
      ),
      basePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
