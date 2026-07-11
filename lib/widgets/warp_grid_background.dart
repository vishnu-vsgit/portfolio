import 'dart:math' as math;
import 'package:flutter/material.dart';

class WarpGridBackground extends StatefulWidget {
  final Widget? child;
  const WarpGridBackground({Key? key, this.child}) : super(key: key);

  @override
  State<WarpGridBackground> createState() => _WarpGridBackgroundState();
}

class _WarpRipple {
  final Offset center;
  final double maxRadius;
  double currentRadius = 0.0;
  final double speed = 380.0; // pixels per second

  _WarpRipple({
    required this.center,
    this.maxRadius = 550.0,
  });
}

class _WarpGridBackgroundState extends State<WarpGridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _mousePosition = Offset.zero;
  Offset _targetMousePosition = Offset.zero;
  bool _initialized = false;
  bool _isHovered = false;
  
  final List<_WarpRipple> _ripples = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
      _isHovered = true;
      if (!_initialized) {
        _mousePosition = _targetMousePosition;
        _initialized = true;
      }
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _ripples.add(_WarpRipple(
        center: event.localPosition,
        maxRadius: 550.0,
      ));
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

        // Update ripples
        for (int i = _ripples.length - 1; i >= 0; i--) {
          _ripples[i].currentRadius += 6.5;
          if (_ripples[i].currentRadius >= _ripples[i].maxRadius) {
            _ripples.removeAt(i);
          }
        }

        return Listener(
          onPointerDown: _onPointerDown,
          behavior: HitTestBehavior.translucent,
          child: MouseRegion(
            onHover: _onMouseHover,
            onExit: (_) {
              setState(() {
                _isHovered = false;
                _targetMousePosition = Offset(size.width / 2, size.height / 2);
              });
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: WarpGridPainter(
                      time: _controller.value,
                      mousePos: _mousePosition,
                      isHovered: _isHovered,
                      ripples: List.from(_ripples),
                    ),
                  ),
                ),
                if (widget.child != null) widget.child!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class WarpGridPainter extends CustomPainter {
  final double time;
  final Offset mousePos;
  final bool isHovered;
  final List<_WarpRipple> ripples;

  WarpGridPainter({
    required this.time,
    required this.mousePos,
    required this.isHovered,
    required this.ripples,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // 1. Draw static dark radial background gradient (very premium and clean)
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.6, -0.6),
        radius: 1.5,
        colors: [
          Color(0xff05090f), // very deep space tint
          Color(0xff000000), // absolute black
        ],
        stops: [0.0, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Draw soft core glow under mouse position to light up grid lines
    if (isHovered) {
      final Paint mouseGlowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xff3b82f6).withOpacity(0.05), // very soft blue glow
            const Color(0xff3b82f6).withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: mousePos, radius: 250.0));
      canvas.drawCircle(mousePos, 250.0, mouseGlowPaint);
    }

    final double gridSpacing = 42.0;
    final double warpRadius = 260.0;
    
    // Slow breathing animation to simulate organic expansion/contraction of gravity
    final double pulse = math.sin(time * 2.0 * math.pi);
    final double baseStrength = isHovered ? 0.38 : 0.15;
    final double warpStrength = baseStrength + 0.04 * pulse;

    // Core mapping function: transforms straight coordinate to warped coordinate
    Offset getWarpedPoint(double x, double y) {
      double curX = x;
      double curY = y;

      // A. Gravity Well (Pull towards mouse)
      final double dx = curX - mousePos.dx;
      final double dy = curY - mousePos.dy;
      final double dist = math.sqrt(dx * dx + dy * dy);

      if (dist < warpRadius) {
        final double ratio = dist / warpRadius;
        final double factor = 1.0 - ratio;
        final double factorCubed = factor * factor * factor;

        curX -= dx * warpStrength * factorCubed;
        curY -= dy * warpStrength * factorCubed;
      }

      // B. Dynamic Click Ripples (Push outward)
      for (var ripple in ripples) {
        final double rdx = curX - ripple.center.dx;
        final double rdy = curY - ripple.center.dy;
        final double rdist = math.sqrt(rdx * rdx + rdy * rdy);

        final double waveWidth = 80.0;
        final double distToFront = (rdist - ripple.currentRadius).abs();

        if (distToFront < waveWidth / 2) {
          final double ratio = distToFront / (waveWidth / 2);
          final double waveFactor = math.cos(ratio * math.pi / 2);
          final double waveFactorSq = waveFactor * waveFactor;

          final double lifeRatio = ripple.currentRadius / ripple.maxRadius;
          final double fade = 1.0 - lifeRatio;
          final double rippleStrength = 28.0 * fade * waveFactorSq;

          if (rdist > 10.0) {
            curX += (rdx / rdist) * rippleStrength;
            curY += (rdy / rdist) * rippleStrength;
          }
        }
      }

      return Offset(curX, curY);
    }

    // 3. Draw warped grid lines
    final Paint linePaint = Paint()
      ..color = const Color(0xff3b82f6).withOpacity(0.045) // subtle tech blue line
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    final double sampleStep = 25.0;

    // Horizontal warped lines
    for (double y = 0; y <= height + gridSpacing; y += gridSpacing) {
      final Path path = Path();
      final Offset first = getWarpedPoint(0, y);
      path.moveTo(first.dx, first.dy);
      
      for (double x = sampleStep; x <= width; x += sampleStep) {
        final Offset p = getWarpedPoint(x, y);
        path.lineTo(p.dx, p.dy);
      }
      final Offset last = getWarpedPoint(width, y);
      path.lineTo(last.dx, last.dy);
      canvas.drawPath(path, linePaint);
    }

    // Vertical warped lines
    for (double x = 0; x <= width + gridSpacing; x += gridSpacing) {
      final Path path = Path();
      final Offset first = getWarpedPoint(x, 0);
      path.moveTo(first.dx, first.dy);

      for (double y = sampleStep; y <= height; y += sampleStep) {
        final Offset p = getWarpedPoint(x, y);
        path.lineTo(p.dx, p.dy);
      }
      final Offset last = getWarpedPoint(x, height);
      path.lineTo(last.dx, last.dy);
      canvas.drawPath(path, linePaint);
    }

    // 4. Draw interactive glowing grid nodes (intersections)
    final Paint nodePaint = Paint()..style = PaintingStyle.fill;
    
    for (double y = 0; y <= height + gridSpacing; y += gridSpacing) {
      for (double x = 0; x <= width + gridSpacing; x += gridSpacing) {
        final Offset p = getWarpedPoint(x, y);
        
        final double dx = p.dx - mousePos.dx;
        final double dy = p.dy - mousePos.dy;
        final double dist = math.sqrt(dx * dx + dy * dy);
        
        double nodeSize = 0.7;
        Color nodeColor = const Color(0xff3b82f6).withOpacity(0.10);
        
        if (dist < warpRadius) {
          final double ratio = dist / warpRadius;
          final double factor = 1.0 - ratio;
          
          nodeSize = 0.7 + 1.8 * factor;
          nodeColor = Color.lerp(
            const Color(0xff3b82f6).withOpacity(0.10),
            const Color(0xff60a5fa).withOpacity(0.65),
            factor,
          )!;
        }
        
        nodePaint.color = nodeColor;
        canvas.drawCircle(p, nodeSize, nodePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
