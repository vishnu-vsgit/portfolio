import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double borderWidth;
  final Color? glowColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool isHoverable;
  final VoidCallback? onTap;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.blur = 20.0,
    this.borderWidth = 1.0,
    this.glowColor,
    this.padding = const EdgeInsets.all(24.0),
    this.margin,
    this.isHoverable = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late AnimationController _borderController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Widget cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(_isHovered ? 0.55 : 0.4),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );

    // Apply the gradient border painter
    cardContent = Stack(
      children: [
        cardContent,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _borderController,
              builder: (context, child) {
                return CustomPaint(
                  painter: GlassBorderPainter(
                    strokeWidth: widget.borderWidth,
                    radius: widget.borderRadius,
                    gradient: SweepGradient(
                      colors: [
                        Colors.white.withOpacity(0.04),
                        Colors.white.withOpacity(_isHovered ? 0.35 : 0.15),
                        Colors.white.withOpacity(0.04),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      transform: GradientRotation(_borderController.value * 2.0 * math.pi),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );

    if (widget.onTap != null) {
      cardContent = GestureDetector(
        onTap: widget.onTap,
        child: cardContent,
      );
    }

    if (widget.isHoverable) {
      cardContent = MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _controller.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _controller.reverse();
        },
        cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: cardContent,
        ),
      );
    }

    return Container(
      margin: widget.margin,
      child: cardContent,
    );
  }
}

class GlassBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double radius;
  final Gradient gradient;

  GlassBorderPainter({
    required this.strokeWidth,
    required this.radius,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);

    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant GlassBorderPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.gradient != gradient;
  }
}
