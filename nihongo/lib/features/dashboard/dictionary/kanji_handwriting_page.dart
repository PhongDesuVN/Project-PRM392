import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as mlkit;

import '../../../shared/ui.dart';

class KanjiHandwritingPage extends StatefulWidget {
  const KanjiHandwritingPage({super.key});

  @override
  State<KanjiHandwritingPage> createState() => _KanjiHandwritingPageState();
}

class _KanjiHandwritingPageState extends State<KanjiHandwritingPage> {
  static const _modelLanguage = 'ja';
  static const _modelTimeout = Duration(seconds: 90);
  static const _recognitionTimeout = Duration(seconds: 15);
  static const _recognizerCloseTimeout = Duration(seconds: 2);

  final List<_DrawnStroke> _strokes = [];
  final _clock = Stopwatch()..start();
  List<String> _candidates = const [];
  String? _errorMessage;
  String? _statusMessage;
  String? _selectedCandidate;
  bool _isRecognizing = false;

  bool get _hasInk => _strokes.isNotEmpty;

  void _startStroke(Offset position) {
    if (_isRecognizing) return;
    setState(() {
      _errorMessage = null;
      _statusMessage = null;
      _candidates = const [];
      _selectedCandidate = null;
      _strokes.add(_DrawnStroke()..add(position, _clock.elapsedMilliseconds));
    });
  }

  void _extendStroke(Offset position) {
    if (_isRecognizing || _strokes.isEmpty) return;
    setState(() => _strokes.last.add(position, _clock.elapsedMilliseconds));
  }

  void _undoStroke() {
    if (!_hasInk) return;
    setState(() {
      _strokes.removeLast();
      _candidates = const [];
      _selectedCandidate = null;
      _errorMessage = null;
      _statusMessage = null;
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _candidates = const [];
      _selectedCandidate = null;
      _errorMessage = null;
      _statusMessage = null;
    });
  }

  Future<void> _recognize() async {
    if (!_hasInk || _isRecognizing) return;

    setState(() {
      _isRecognizing = true;
      _errorMessage = null;
      _statusMessage = 'Đang kiểm tra mô hình tiếng Nhật...';
      _candidates = const [];
      _selectedCandidate = null;
    });

    final modelManager = mlkit.DigitalInkRecognizerModelManager();
    var stage = _RecognitionStage.checkingModel;
    try {
      final isModelDownloaded = await modelManager
          .isModelDownloaded(_modelLanguage)
          .timeout(_modelTimeout);
      if (!isModelDownloaded) {
        stage = _RecognitionStage.downloadingModel;
        if (mounted) {
          setState(
            () => _statusMessage = 'Đang tải mô hình tiếng Nhật lần đầu. Hãy giữ kết nối Internet...',
          );
        }
        final downloaded = await modelManager
            .downloadModel(_modelLanguage)
            .timeout(_modelTimeout);
        if (!downloaded) {
          throw StateError('Không thể tải mô hình nhận dạng tiếng Nhật.');
        }
      }

      stage = _RecognitionStage.recognizing;
      if (mounted) {
        setState(() => _statusMessage = 'Đang nhận dạng nét viết...');
      }
      final recognizer = mlkit.DigitalInkRecognizer(
        languageCode: _modelLanguage,
      );
      List<String> recognizedText;
      try {
        final ink = mlkit.Ink()
          ..strokes = _strokes.map((stroke) => stroke.ink).toList();
        final candidates = await recognizer
            .recognize(
              ink,
              context: mlkit.DigitalInkRecognitionContext(
                writingArea: mlkit.WritingArea(
                  width: _canvasSize.width,
                  height: _canvasSize.height,
                ),
              ),
            )
            .timeout(_recognitionTimeout);
        recognizedText = candidates
            .map((candidate) => candidate.text.trim())
            .where((text) => text.isNotEmpty)
            .toSet()
            .take(5)
            .toList();
      } finally {
        unawaited(_closeRecognizer(recognizer));
      }
      if (!mounted) return;

      setState(() {
        _statusMessage = null;
        _candidates = recognizedText;
        _selectedCandidate = recognizedText.isEmpty
            ? null
            : recognizedText.first;
        if (recognizedText.isEmpty) {
          _errorMessage = 'Chưa nhận ra chữ viết. Hãy thử viết lại rõ hơn.';
        }
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _statusMessage = null;
        _errorMessage = switch (stage) {
          _RecognitionStage.checkingModel => 'Kiểm tra mô hình quá lâu. Hãy kiểm tra kết nối Internet rồi thử lại.',
          _RecognitionStage.downloadingModel => 'Tải mô hình tiếng Nhật quá lâu. Hãy kiểm tra kết nối Internet rồi thử lại.',
          _RecognitionStage.recognizing => 'Nhận dạng quá lâu. Hãy thử lại với ít nét hơn hoặc khởi động lại ứng dụng.',
        };
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _statusMessage = null;
        _errorMessage = error.message?.isNotEmpty == true
            ? 'Không thể nhận dạng chữ viết: ${error.message}'
            : 'Không thể nhận dạng chữ viết. Vui lòng thử lại.';
      });
    } on MissingPluginException {
      if (!mounted) return;
      setState(() {
        _statusMessage = null;
        _errorMessage = 'Tính năng nhận dạng chưa khả dụng trên thiết bị này.';
      });
    } on StateError catch (error) {
      if (!mounted) return;
      setState(() {
        _statusMessage = null;
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRecognizing = false;
          _statusMessage = null;
        });
      }
    }
  }

  Future<void> _closeRecognizer(mlkit.DigitalInkRecognizer recognizer) async {
    try {
      await recognizer.close().timeout(_recognizerCloseTimeout);
    } catch (_) {
      // Bỏ qua lỗi hoặc timeout khi đóng bộ nhận dạng
    }
  }

  Size _canvasSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '漢字',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Viết Kanji',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkText,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Banner Hướng Dẫn Sang Trọng
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, AppColors.blue.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9EDF2), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.brush_rounded,
                    color: AppColors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Viết một Kanji để tra cứu',
                        style: TextStyle(
                          color: Color(0xFF1E242B),
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Dùng ngón tay viết chữ vào khung. Viết từng nét theo thứ tự tự nhiên.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Khung Viết Kanji Chuẩn Kiểu Tập Viết Nhật Bản (米字格)
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD6DBE1), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.5),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _canvasSize = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      return RawGestureDetector(
                        key: const ValueKey('kanji-writing-canvas'),
                        gestures: {
                          EagerGestureRecognizer:
                              GestureRecognizerFactoryWithHandlers<
                                EagerGestureRecognizer
                              >(EagerGestureRecognizer.new, (recognizer) {}),
                        },
                        child: Listener(
                          onPointerDown: (event) =>
                              _startStroke(event.localPosition),
                          onPointerMove: (event) =>
                              _extendStroke(event.localPosition),
                          child: CustomPaint(
                            painter: _KanjiCanvasPainter(
                              strokes: _strokes,
                              color: const Color(0xFF1E2229),
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Thanh Công Cụ Thao Tác Canvas (Thống kê số nét & Nút hoàn tác, xóa)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8ECF0)),
            ),
            child: Row(
              children: [
                // Số lượng nét đã viết
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _hasInk
                          ? AppColors.blue.withValues(alpha: 0.12)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: _hasInk
                              ? AppColors.blue
                              : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _strokes.isEmpty
                                ? 'Có thể vẽ nhiều nét cho cùng một chữ.'
                                : '${_strokes.length} nét đã viết',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _hasInk
                                  ? AppColors.blue
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Nút Hoàn Tác
                IconButton(
                  key: const ValueKey('undo-kanji-stroke'),
                  tooltip: 'Hoàn tác nét cuối',
                  onPressed: _hasInk && !_isRecognizing ? _undoStroke : null,
                  style: IconButton.styleFrom(
                    backgroundColor: _hasInk && !_isRecognizing
                        ? const Color(0xFFF1F5F9)
                        : Colors.transparent,
                    foregroundColor: const Color(0xFF475569),
                  ),
                  icon: const Icon(Icons.undo_rounded, size: 20),
                ),

                // Nút Xóa Toàn Bộ
                IconButton(
                  key: const ValueKey('clear-kanji-canvas'),
                  tooltip: 'Xóa toàn bộ',
                  onPressed: _hasInk && !_isRecognizing ? _clearCanvas : null,
                  style: IconButton.styleFrom(
                    backgroundColor: _hasInk && !_isRecognizing
                        ? const Color(0xFFFEE2E2)
                        : Colors.transparent,
                    foregroundColor: const Color(0xFFDC2626),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                ),
              ],
            ),
          ),

          // Trạng Thái Đang Nhận Dạng
          if (_isRecognizing) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      backgroundColor: Color(0xFFE2E8F0),
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusMessage ?? 'Đang xử lý...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Thông Báo Lỗi Nếu Có
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFDC2626),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFF991B1B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Kết Quả Nhận Dạng (Candidates)
          if (_candidates.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.auto_awesome, size: 18, color: AppColors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Chọn kết quả phù hợp',
                          style: TextStyle(
                            color: Color(0xFF1E242B),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final candidate in _candidates)
                        ChoiceChip(
                          label: Text(
                            candidate,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: candidate == _selectedCandidate
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: candidate == _selectedCandidate
                                  ? AppColors.blue
                                  : const Color(0xFF1E242B),
                            ),
                          ),
                          selected: candidate == _selectedCandidate,
                          selectedColor: AppColors.blue.withValues(alpha: 0.12),
                          backgroundColor: const Color(0xFFF8FAFC),
                          side: BorderSide(
                            color: candidate == _selectedCandidate
                                ? AppColors.blue
                                : const Color(0xFFE2E8F0),
                            width: candidate == _selectedCandidate ? 1.8 : 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          showCheckmark: false,
                          onSelected: (_) =>
                              setState(() => _selectedCandidate = candidate),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),

      // Thanh Nút Bấm Dưới Cùng
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _hasInk && !_isRecognizing ? _recognize : null,
                  icon: _isRecognizing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome, size: 20),
                  label: Text(
                    _isRecognizing ? 'Đang nhận dạng...' : 'Nhận dạng chữ viết',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    foregroundColor: Colors.white,
                    elevation: _hasInk ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              if (_selectedCandidate != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, _selectedCandidate),
                    icon: const Icon(Icons.search_rounded, size: 20),
                    label: Text(
                      'Tra cứu “$_selectedCandidate”',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.blue,
                      side: const BorderSide(color: AppColors.blue, width: 1.5),
                      backgroundColor: AppColors.blue.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _RecognitionStage { checkingModel, downloadingModel, recognizing }

class _DrawnStroke {
  final List<Offset> points = [];
  final mlkit.Stroke ink = mlkit.Stroke();

  void add(Offset position, int timestamp) {
    points.add(position);
    ink.points.add(
      mlkit.StrokePoint(x: position.dx, y: position.dy, t: timestamp),
    );
  }
}

/// Canvas Painter vẽ nét Kanji cùng lưới tập viết chuẩn 米字格 (Tian Zi Ge / Mi Zi Ge)
class _KanjiCanvasPainter extends CustomPainter {
  const _KanjiCanvasPainter({required this.strokes, required this.color});

  final List<_DrawnStroke> strokes;
  final Color color;

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint, {
    double dashWidth = 5,
    double dashSpace = 4,
  }) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final count = (distance / (dashWidth + dashSpace)).floor();
    for (int i = 0; i < count; i++) {
      final startFraction = (i * (dashWidth + dashSpace)) / distance;
      final endFraction = (i * (dashWidth + dashSpace) + dashWidth) / distance;
      canvas.drawLine(
        Offset(p1.dx + dx * startFraction, p1.dy + dy * startFraction),
        Offset(p1.dx + dx * endFraction, p1.dy + dy * endFraction),
        paint,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Vẽ nền kẻ ô tập viết nét chữ (Đường đứt đoạn chữ thập và đường chéo)
    final guidePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    final diagonalPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 0.8;

    _drawDashedLine(
      canvas,
      Offset.zero,
      Offset(size.width, size.height),
      diagonalPaint,
      dashWidth: 6,
      dashSpace: 6,
    );
    _drawDashedLine(
      canvas,
      Offset(size.width, 0),
      Offset(0, size.height),
      diagonalPaint,
      dashWidth: 6,
      dashSpace: 6,
    );

    // Đường chữ thập trục tọa độ giữa ô
    _drawDashedLine(
      canvas,
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      guidePaint,
    );

    // 2. Vẽ nét mực Kanji (Mô phỏng mực tàu đậm nét mượt mà)
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, 3.25, strokePaint);
      } else {
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KanjiCanvasPainter oldDelegate) =>
      oldDelegate.strokes != strokes || oldDelegate.color != color;
}
