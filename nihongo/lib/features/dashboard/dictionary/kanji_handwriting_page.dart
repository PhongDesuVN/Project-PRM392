import 'dart:async';

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
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Đã nhận dạng xong, nhưng bộ nhận dạng phản hồi chậm khi đóng.',
            ),
          ),
        );
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error.message?.isNotEmpty == true
                  ? 'Đã nhận dạng xong, nhưng không đóng được bộ nhận dạng: ${error.message}'
                  : 'Đã nhận dạng xong, nhưng không đóng được bộ nhận dạng.',
            ),
          ),
        );
    }
  }

  Size _canvasSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viết Kanji'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkText,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          const Text(
            'Viết một Kanji để tra cứu',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Dùng ngón tay viết chữ vào khung. Viết từng nét theo thứ tự tự nhiên.',
            style: TextStyle(
              color: AppColors.placeholder,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkText.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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
                          color: AppColors.darkText,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Có thể vẽ nhiều nét cho cùng một chữ.',
                  style: TextStyle(color: AppColors.placeholder, fontSize: 12),
                ),
              ),
              IconButton(
                key: const ValueKey('undo-kanji-stroke'),
                tooltip: 'Hoàn tác nét cuối',
                onPressed: _hasInk && !_isRecognizing ? _undoStroke : null,
                icon: const Icon(Icons.undo_rounded),
              ),
              IconButton(
                key: const ValueKey('clear-kanji-canvas'),
                tooltip: 'Xóa toàn bộ',
                onPressed: _hasInk && !_isRecognizing ? _clearCanvas : null,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          if (_isRecognizing) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              _statusMessage ?? 'Đang xử lý...',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.placeholder, fontSize: 13),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ],
          if (_candidates.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Chọn kết quả phù hợp',
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final candidate in _candidates)
                  ChoiceChip(
                    label: Text(
                      candidate,
                      style: const TextStyle(fontSize: 22),
                    ),
                    selected: candidate == _selectedCandidate,
                    onSelected: (_) =>
                        setState(() => _selectedCandidate = candidate),
                  ),
              ],
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 8, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
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
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isRecognizing ? 'Đang nhận dạng...' : 'Nhận dạng chữ viết',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (_selectedCandidate != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, _selectedCandidate),
                  icon: const Icon(Icons.search),
                  label: Text('Tra cứu “$_selectedCandidate”'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: AppColors.blue,
                  ),
                ),
              ),
            ],
          ],
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

class _KanjiCanvasPainter extends CustomPainter {
  const _KanjiCanvasPainter({required this.strokes, required this.color});

  final List<_DrawnStroke> strokes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.8)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      guidePaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      guidePaint,
    );

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 7
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
        canvas.drawCircle(stroke.points.first, 3.5, strokePaint);
      } else {
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _KanjiCanvasPainter oldDelegate) =>
      oldDelegate.strokes != strokes || oldDelegate.color != color;
}
