import 'dart:math' as math;
import 'package:flutter/material.dart';

class MorphingWaves extends StatefulWidget {
  final Widget? child;
  const MorphingWaves({Key? key, this.child}) : super(key: key);

  @override
  State<MorphingWaves> createState() => _MorphingWavesState();
}

class _MorphingWavesState extends State<MorphingWaves>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _mousePosition = Offset.zero;
  Offset _targetMousePosition = Offset.zero;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMouseHover(PointerEvent details) {
    setState(() {
      _targetMousePosition = details.localPosition;
      if (!_initialized) {
        _mousePosition = _targetMousePosition;
        _initialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (!_initialized) {
      _targetMousePosition = Offset(size.width / 2, size.height / 2);
      _mousePosition = _targetMousePosition;
      _initialized = true;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Smooth mouse position interpolation
        _mousePosition = Offset(
          _mousePosition.dx + (_targetMousePosition.dx - _mousePosition.dx) * 0.08,
          _mousePosition.dy + (_targetMousePosition.dy - _mousePosition.dy) * 0.08,
        );

        return MouseRegion(
          onHover: _onMouseHover,
          onExit: (_) {
            setState(() {
              _targetMousePosition = Offset(size.width / 2, size.height / 2);
            });
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: WavePainter(
                    time: _controller.value,
                    mousePos: _mousePosition,
                  ),
                ),
              ),
              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double time;
  final Offset mousePos;

  WavePainter({
    required this.time,
    required this.mousePos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw 3 layered waves with different properties
    _drawWave(
      canvas: canvas,
      width: width,
      height: height,
      centerY: height * 0.50,
      baseAmplitude: height * 0.08,
      wavelength: 0.0025,
      speed: 1.5,
      phaseOffset: 0.0,
      strokeColor: const Color(0xff3b82f6), // Royal Blue
      strokeOpacity: 0.08,
      fillOpacity: 0.015,
      strokeWidth: 2.2,
    );

    _drawWave(
      canvas: canvas,
      width: width,
      height: height,
      centerY: height * 0.53,
      baseAmplitude: height * 0.10,
      wavelength: 0.0018,
      speed: -1.0,
      phaseOffset: math.pi * 0.5,
      strokeColor: const Color(0xff14b8a6), // Teal
      strokeOpacity: 0.06,
      fillOpacity: 0.012,
      strokeWidth: 1.6,
    );

    _drawWave(
      canvas: canvas,
      width: width,
      height: height,
      centerY: height * 0.47,
      baseAmplitude: height * 0.06,
      wavelength: 0.0035,
      speed: 2.2,
      phaseOffset: math.pi * 1.2,
      strokeColor: const Color(0xff6366f1), // Indigo
      strokeOpacity: 0.05,
      fillOpacity: 0.010,
      strokeWidth: 1.2,
    );
  }

  void _drawWave({
    required Canvas canvas,
    required double width,
    required double height,
    required double centerY,
    required double baseAmplitude,
    required double wavelength,
    required double speed,
    required double phaseOffset,
    required Color strokeColor,
    required double strokeOpacity,
    required double fillOpacity,
    required double strokeWidth,
  }) {
    final double phase = time * 2.0 * math.pi * speed + phaseOffset;

    final Path path = Path();
    final Path fillPath = Path();

    // Determine the start point
    double getWaveY(double x) {
      // Modulate amplitude over time slowly
      final double ampMod = 0.8 + 0.2 * math.sin(time * 4.0 * math.pi + phaseOffset);
      final double amplitude = baseAmplitude * ampMod;

      // Basic sine wave
      double y = centerY + math.sin(x * wavelength + phase) * amplitude;

      // Add a secondary harmonic for organic organic liquid feel
      y += math.sin(x * wavelength * 2.2 - phase * 0.8) * (amplitude * 0.28);

      // Mouse interactive vertical push/pull
      final double dx = x - mousePos.dx;
      final double maxDist = 240.0;
      if (dx.abs() < maxDist) {
        final double ratio = dx.abs() / maxDist;
        final double factor = math.cos(ratio * math.pi / 2);
        final double factorSq = factor * factor;

        // Pull wave vertically towards mouse Y position slightly
        y += (mousePos.dy - y) * 0.16 * factorSq;
      }
      return y;
    }

    final double startY = getWaveY(0);
    path.moveTo(0, startY);
    fillPath.moveTo(0, height);
    fillPath.lineTo(0, startY);

    // Generate points along the X axis
    // Use step of 4 for smoother curves while remaining extremely fast
    final int step = 4;
    for (double x = step.toDouble(); x <= width; x += step) {
      final double y = getWaveY(x);
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    // Ensure we hit exactly the right boundary
    final double endY = getWaveY(width);
    path.lineTo(width, endY);
    fillPath.lineTo(width, endY);
    fillPath.lineTo(width, height);
    fillPath.close();

    // 1. Draw the gradient fill under the wave
    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          strokeColor.withOpacity(fillOpacity),
          strokeColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(0, centerY - baseAmplitude * 1.5, 0, height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // 2. Draw the stroke line
    final Paint strokePaint = Paint()
      ..color = strokeColor.withOpacity(strokeOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.mousePos != mousePos;
  }
}
