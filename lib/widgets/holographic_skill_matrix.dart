import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HolographicSkillMatrix extends StatefulWidget {
  final List<String> skills;
  final int categoryIndex;

  const HolographicSkillMatrix({
    Key? key,
    required this.skills,
    required this.categoryIndex,
  }) : super(key: key);

  @override
  State<HolographicSkillMatrix> createState() => _HolographicSkillMatrixState();
}

class _HolographicSkillMatrixState extends State<HolographicSkillMatrix>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _barsController;
  late Animation<double> _barsAnimation;

  // Real-time signal fluctuation noise for cybernetic telemetry look
  double _telemetryFluctuation = 0.05;
  Timer? _fluctuationTimer;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Infinite rotation for radar telemetry
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Entrance and reload animation for skill bars
    _barsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _barsAnimation = CurvedAnimation(
      parent: _barsController,
      curve: Curves.easeOutCubic,
    );

    _barsController.forward();

    // Small timer to change fluctuation noise in UI readouts
    _fluctuationTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (mounted) {
        setState(() {
          _telemetryFluctuation = (_random.nextDouble() - 0.5) * 0.1; // +/- 5% noise
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant HolographicSkillMatrix oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryIndex != widget.categoryIndex) {
      _barsController.reset();
      _barsController.forward();
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    _barsController.dispose();
    _fluctuationTimer?.cancel();
    super.dispose();
  }

  double _getSkillLevel(String skillName) {
    final String clean = skillName.toLowerCase().trim();
    if (clean.contains("flutter")) return 0.95;
    if (clean.contains("dart")) return 0.92;
    if (clean.contains("api")) return 0.88;
    if (clean.contains("git")) return 0.85;
    if (clean.contains("deployment")) return 0.82;
    if (clean.contains("figma")) return 0.94;
    if (clean.contains("logo")) return 0.80;
    if (clean.contains("prototyping")) return 0.88;
    if (clean.contains("vision")) return 0.72;
    if (clean.contains("learning")) return 0.78;
    if (clean.contains("algorithms")) return 0.84;
    if (clean.contains("python")) return 0.89;
    if (clean.contains("iedc")) return 0.96;
    if (clean.contains("team")) return 0.92;
    if (clean.contains("speaking")) return 0.90;
    if (clean.contains("event")) return 0.86;
    return 0.85; // Default fallback mastery
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showMiniRadar = constraints.maxWidth > 320;
        final double radarSize = constraints.maxWidth > 400 ? 110.0 : 80.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showMiniRadar) ...[
              // Holographic Radar Scope
              SizedBox(
                width: radarSize,
                height: radarSize,
                child: AnimatedBuilder(
                  animation: _radarController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _RadarTelemetryPainter(
                        rotationAngle: _radarController.value * 2 * math.pi,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 20.0),
            ],

            // Skill telemetry meters list
            Expanded(
              child: AnimatedBuilder(
                animation: _barsAnimation,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.skills.length, (index) {
                      final skill = widget.skills[index];
                      final double baseLevel = _getSkillLevel(skill);
                      
                      // Calculate active level with easing and subtle fluctuations
                      final double animatedVal = baseLevel * _barsAnimation.value;
                      final double displayVal = (animatedVal +
                              (animatedVal > 0.1 ? _telemetryFluctuation * 0.02 : 0))
                          .clamp(0.0, 1.0);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    skill.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.shareTechMono(
                                      color: Colors.white,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  "[SYS_OK // ${(displayVal * 100).toStringAsFixed(1)}%]",
                                  style: GoogleFonts.shareTechMono(
                                    color: Colors.cyanAccent.withOpacity(0.85),
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5.0),
                            Stack(
                              children: [
                                // Track back
                                Container(
                                  height: 5.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                ),
                                // Glowing fill
                                FractionallySizedBox(
                                  widthFactor: displayVal,
                                  child: Container(
                                    height: 5.0,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.cyan.withOpacity(0.6),
                                          Colors.tealAccent.withOpacity(0.9),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.cyan.withOpacity(0.3),
                                          blurRadius: 4.0,
                                          spreadRadius: 0.5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RadarTelemetryPainter extends CustomPainter {
  final double rotationAngle;

  _RadarTelemetryPainter({required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) / 2;

    // Paints
    final gridPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.12)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dashGridPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.08)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // 1. Draw Concentric Circles
    canvas.drawCircle(center, radius, gridPaint);
    canvas.drawCircle(center, radius * 0.65, dashGridPaint);
    canvas.drawCircle(center, radius * 0.3, gridPaint);

    // 2. Draw Crosshair lines
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      gridPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      gridPaint,
    );

    // 3. Draw Rotational Scanning Sector Sweep
    final Rect sweepRect = Rect.fromCircle(center: center, radius: radius);
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          Colors.cyan.withOpacity(0.0),
          Colors.cyan.withOpacity(0.25),
        ],
        stops: const [0.85, 1.0],
        transform: GradientRotation(rotationAngle),
      ).createShader(sweepRect)
      ..style = PaintingStyle.fill;

    canvas.drawArc(sweepRect, 0, 2 * math.pi, true, sweepPaint);

    // 4. Draw Sweeping active radar line edge
    final double endX = center.dx + radius * math.cos(rotationAngle);
    final double endY = center.dy + radius * math.sin(rotationAngle);
    final activeLinePaint = Paint()
      ..color = Colors.cyan.withOpacity(0.6)
      ..strokeWidth = 1.5;
    canvas.drawLine(center, Offset(endX, endY), activeLinePaint);

    // 5. Draw Outer degree ticks
    final tickPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.3)
      ..strokeWidth = 1.0;
    
    for (int i = 0; i < 360; i += 30) {
      final double angle = i * math.pi / 180;
      final double startR = radius - 4;
      final double endR = radius;

      final double sX = center.dx + startR * math.cos(angle);
      final double sY = center.dy + startR * math.sin(angle);
      final double eX = center.dx + endR * math.cos(angle);
      final double eY = center.dy + endR * math.sin(angle);

      canvas.drawLine(Offset(sX, sY), Offset(eX, eY), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarTelemetryPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle;
  }
}
