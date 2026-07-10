import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AuroraBackground extends StatefulWidget {
  final Widget child;

  const AuroraBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Static Grid background (drawn once, cached in GPU memory)
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: StaticGridPainter(),
            ),
          ),
        ),
        // 2. Animated drifting glow blob & children layout
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: GlowPainter(progress: _controller.value),
                child: widget.child,
              );
            },
          ),
        ),
      ],
    );
  }
}

class StaticGridPainter extends CustomPainter {
  const StaticGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    
    // Draw absolute pitch black background
    final Paint bgPaint = Paint()..color = const Color(0xff000000);
    canvas.drawRect(rect, bgPaint);

    // Draw modern minimalist dotted engineering grid using drawPoints
    final double step = 28.0;
    final List<Offset> points = [];
    
    for (double x = 14.0; x < size.width; x += step) {
      for (double y = 14.0; y < size.height; y += step) {
        points.add(Offset(x, y));
      }
    }

    final Paint dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    if (points.isNotEmpty) {
      canvas.drawPoints(ui.PointMode.points, points, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant StaticGridPainter oldDelegate) => false;
}

class GlowPainter extends CustomPainter {
  final double progress;

  GlowPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double angle = progress * 2.0 * math.pi;

    // Draw a single, extremely faint tech ambient glow drifting in the center-top
    final double bx = size.width * 0.5 + (math.sin(angle) * 100.0);
    final double by = size.height * 0.4 + (math.cos(angle) * 70.0);
    final double bRadius = size.width > 800 ? size.width * 0.45 : size.width * 0.75;
    
    _drawGlowBlob(
      canvas, 
      Offset(bx, by), 
      bRadius, 
      const Color(0xff3b82f6).withValues(alpha: 0.04), // 4% opacity royal blue backlight
    );
  }

  void _drawGlowBlob(Canvas canvas, Offset center, double radius, Color color) {
    if (radius <= 0) return;
    
    final Paint paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: 0.5),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant GlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
