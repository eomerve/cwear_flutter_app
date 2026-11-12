import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/cwear_theme.dart';
import '../utils/respiration_demo.dart';

class RespirationChart extends StatefulWidget {
  const RespirationChart({super.key, required this.connected});
  final bool connected;
  @override
  State<RespirationChart> createState() => _RespirationChartState();
}

class _RespirationChartState extends State<RespirationChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 3750));
    if (widget.connected) _clock.repeat();
  }

  @override
  void didUpdateWidget(covariant RespirationChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.connected && !_clock.isAnimating) {
      _clock.repeat();
    } else if (!widget.connected && _clock.isAnimating) {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 224,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _clock,
          builder: (context, _) => CustomPaint(
            painter: _BreathingPainter(
              connected: widget.connected,
              phase: _clock.value * 2 * math.pi,
            ),
          ),
        ),
      );
}

class _BreathingPainter extends CustomPainter {
  _BreathingPainter({required this.connected, required this.phase});
  final bool connected;
  final double phase;
  @override
  void paint(Canvas canvas, Size size) {
    const left = 39.0;
    const top = 25.0;
    final right = size.width - 9;
    final bottom = size.height - 27;
    final w = math.max(1.0, right - left);
    final h = math.max(1.0, bottom - top);
    final grid = Paint()..color = CW.line..strokeWidth = .8;
    final labels = TextStyle(color: CW.muted.withValues(alpha: .9), fontSize: 11);
    final header = TextStyle(color: CW.muted, fontSize: 11);
    _text(canvas, 'Strain (%)', const Offset(0, 1), header);

    for (var tick = 0; tick <= 4; tick++) {
      final value = 2.0 - tick * .5;
      final y = top + tick * h / 4;
      canvas.drawLine(Offset(left, y), Offset(right, y), grid);
      _text(canvas, value.toStringAsFixed(1), Offset(0, y - 7), labels);
    }
    for (var i = 0; i <= 3; i++) {
      final x = left + w * (i / 3);
      _text(canvas, '${i * 5}', Offset(x - (i == 0 ? 2 : 7), bottom + 6), labels);
    }
    _text(canvas, 'Time (s)', Offset(left + w / 2 - 25, size.height - 11), labels);
    if (!connected) return; // Keep axes in place; do not draw synthetic data.

    final line = Path();
    final area = Path()..moveTo(left, bottom);
    const steps = 240;
    for (var i = 0; i <= steps; i++) {
      final fraction = i / steps;
      final value = RespirationDemo.strainAt(
        fraction * RespirationDemo.windowSeconds, phase: phase);
      final x = left + fraction * w;
      final y = bottom - value / 2 * h;
      if (i == 0) {
        line.moveTo(x, y);
        area.lineTo(x, y);
      } else {
        line.lineTo(x, y);
        area.lineTo(x, y);
      }
    }
    area..lineTo(right, bottom)..close();
    canvas.drawPath(area, Paint()..color = CW.teal.withValues(alpha: .09));
    canvas.drawPath(line, Paint()
      ..color = CW.teal
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke);
  }

  void _text(Canvas canvas, String value, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _BreathingPainter old) =>
      connected != old.connected || phase != old.phase;
}

/// A simple chart painter avoids any 3rd-party chart dependency.
class HistoryBars extends StatelessWidget {
  const HistoryBars({super.key, required this.values, required this.labels,
    required this.enabled, this.highlightIndex = -1});
  final List<double?> values;
  final List<String> labels;
  final bool enabled;
  final int highlightIndex;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 172,
        width: double.infinity,
        child: CustomPaint(
          painter: _BarsPainter(values: values, labels: labels,
              enabled: enabled, highlightIndex: highlightIndex),
        ),
      );
}

class _BarsPainter extends CustomPainter {
  const _BarsPainter({required this.values, required this.labels,
      required this.enabled, required this.highlightIndex});
  final List<double?> values;
  final List<String> labels;
  final bool enabled;
  final int highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 27.0;
    const top = 10.0;
    final bottom = size.height - 26;
    final w = size.width - left - 8;
    final h = bottom - top;
    final grid = Paint()..color = CW.line..strokeWidth = 1;
    for (var level = 8; level <= 20; level += 4) {
      final y = bottom - (level - 8) / 12 * h;
      canvas.drawLine(Offset(left, y), Offset(left + w, y), grid);
      _paintText(canvas, '$level', Offset(0, y - 7), CW.muted, 10);
    }
    final n = values.length;
    if (n == 0) return;
    final gap = w / n;
    for (var i = 0; i < n; i++) {
      final x = left + gap * (i + .5);
      _paintText(canvas, i < labels.length ? labels[i] : '',
          Offset(x - 4, bottom + 8), CW.muted, 11);
      final value = enabled ? values[i] : null;
      if (value == null) continue;
      final fraction = math.max(0.0, math.min(1.0, (value - 8) / 12));
      final barWidth = gap * .55;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(
          x - barWidth / 2, bottom - fraction * h,
          barWidth, fraction * h), const Radius.circular(5)),
        Paint()..color = i == highlightIndex ? CW.teal : const Color(0xFFB6D6C8),
      );
      if (i == highlightIndex) {
        _paintText(canvas, value.round().toString(),
            Offset(x - 6, bottom - fraction * h - 18), CW.tealDark, 11);
      }
    }
  }

  void _paintText(Canvas canvas, String text, Offset pos, Color color, double size) {
    final painter = TextPainter(text: TextSpan(text: text,
        style: TextStyle(color: color, fontSize: size)),
      textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, pos);
  }
  @override
  bool shouldRepaint(covariant _BarsPainter old) =>
      old.enabled != enabled || old.highlightIndex != highlightIndex ||
          !listEqualsDouble(old.values, values) || !listEqualsString(old.labels, labels);
}

bool listEqualsDouble(List<double?> a, List<double?> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
bool listEqualsString(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
