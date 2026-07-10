import 'dart:math' as math;
import 'package:flutter/material.dart';

class ThreeDParticle {
  double x, y, z;
  double vx, vy, vz;
  double radius;
  Color color;

  ThreeDParticle({
    required this.x,
    required this.y,
    required this.z,
    required this.vx,
    required this.vy,
    required this.vz,
    required this.radius,
    required this.color,
  });

  void update(double speedMultiplier) {
    x += vx * speedMultiplier;
    y += vy * speedMultiplier;
    z += vz * speedMultiplier;

    // Boundary check (cube bounds: x: [-350, 350], y: [-250, 250], z: [-200, 400])
    if (x.abs() > 350) vx = -vx;
    if (y.abs() > 250) vy = -vy;
    if (z < -200 || z > 400) vz = -vz;
  }
}

class ThreeDParticleBackground extends StatefulWidget {
  final Widget? child;
  const ThreeDParticleBackground({Key? key, this.child}) : super(key: key);

  @override
  State<ThreeDParticleBackground> createState() => _ThreeDParticleBackgroundState();
}

class _ThreeDParticleBackgroundState extends State<ThreeDParticleBackground>
    with SingleTickerProviderStateMixin {
  late List<ThreeDParticle> particles;
  late AnimationController _controller;
  
  double rotX = -0.15; // Initial slight tilt down
  double rotY = 0.0;
  double targetRotX = -0.15;
  double targetRotY = 0.0;
  
  final int maxParticles = 35;
  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    
    // Initialize random particles in 3D space
    particles = List.generate(maxParticles, (index) {
      final colorVal = random.nextInt(3);
      final Color pColor = colorVal == 0
          ? Colors.white.withOpacity(0.12) // soft white
          : (colorVal == 1
              ? const Color(0xff60a5fa).withOpacity(0.15) // soft blue
              : const Color(0xff94a3b8).withOpacity(0.12)); // soft slate
      return ThreeDParticle(
        x: (random.nextDouble() * 700) - 350,
        y: (random.nextDouble() * 500) - 250,
        z: (random.nextDouble() * 600) - 200,
        vx: (random.nextDouble() * 0.4) - 0.2,
        vy: (random.nextDouble() * 0.4) - 0.2,
        vz: (random.nextDouble() * 0.4) - 0.2,
        radius: random.nextDouble() * 2.5 + 1.5,
        color: pColor,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {
          // Update particle positions
          for (var p in particles) {
            p.update(1.0);
          }
          // Smoothly interpolate rotation to mouse position
          rotX += (targetRotX - rotX) * 0.05;
          rotY += (targetRotY - rotY) * 0.05;
        });
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMouseHover(PointerEvent details, Size size) {
    // Map mouse position coordinates to rotation values
    // Horizontal mouse movement rotates around Y axis (yaw)
    // Vertical mouse movement rotates around X axis (pitch)
    final double normX = (details.localPosition.dx / size.width) * 2 - 1;
    final double normY = (details.localPosition.dy / size.height) * 2 - 1;
    
    targetRotY = normX * 0.25; // max rotation around Y
    targetRotX = -0.15 + (normY * 0.15); // pivot around default tilt
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return MouseRegion(
          onHover: (details) => _onMouseHover(details, size),
          child: Stack(
            children: [
              CustomPaint(
                size: size,
                painter: ThreeDParticlePainter(
                  particles: particles,
                  rotX: rotX,
                  rotY: rotY,
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

class ThreeDParticlePainter extends CustomPainter {
  final List<ThreeDParticle> particles;
  final double rotX;
  final double rotY;

  ThreeDParticlePainter({
    required this.particles,
    required this.rotX,
    required this.rotY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double focalLength = size.width > 800 ? 500 : 300;

    // Ambient background is handled by AuroraBackground

    // Pre-calculate sin/cos values
    final double cosX = math.cos(rotX);
    final double sinX = math.sin(rotX);
    final double cosY = math.cos(rotY);
    final double sinY = math.sin(rotY);

    // Dynamic scale helper
    Offset? project(double x, double y, double z) {
      // Rotate around Y axis (yaw)
      double rx = x * cosY - z * sinY;
      double rz = x * sinY + z * cosY;

      // Rotate around X axis (pitch)
      double ry = y * cosX - rz * sinX;
      double rzFinal = y * sinX + rz * cosX;

      // Prevent division by zero and handle points behind camera
      if (rzFinal + focalLength <= 10) return null;

      double scale = focalLength / (rzFinal + focalLength);
      double screenX = centerX + rx * scale;
      double screenY = centerY + ry * scale;
      return Offset(screenX, screenY);
    }

    // 1. Draw glowing grid floor at y = 220
    final gridFloorPaint = Paint()
      ..color = const Color(0x0c818cf8)
      ..strokeWidth = 0.8;
    
    final gridFloorZMax = 500.0;
    final gridFloorZMin = -200.0;
    final gridFloorStepZ = 60.0;
    final gridFloorWidthX = 400.0;
    final gridFloorStepX = 80.0;
    final double floorY = 220.0;

    // Draw horizontal grid lines (lines along X-axis, moving down Z)
    for (double gz = gridFloorZMin; gz <= gridFloorZMax; gz += gridFloorStepZ) {
      final p1 = project(-gridFloorWidthX, floorY, gz);
      final p2 = project(gridFloorWidthX, floorY, gz);
      if (p1 != null && p2 != null) {
        // Fade lines based on distance
        double opacity = 1.0 - ((gz - gridFloorZMin) / (gridFloorZMax - gridFloorZMin));
        opacity = opacity.clamp(0.0, 1.0) * 0.15;
        gridFloorPaint.color = Colors.white.withOpacity(opacity * 0.015);
        canvas.drawLine(p1, p2, gridFloorPaint);
      }
    }

    // Draw longitudinal grid lines (lines along Z-axis)
    for (double gx = -gridFloorWidthX; gx <= gridFloorWidthX; gx += gridFloorStepX) {
      final p1 = project(gx, floorY, gridFloorZMin);
      final p2 = project(gx, floorY, gridFloorZMax);
      if (p1 != null && p2 != null) {
        gridFloorPaint.color = Colors.white.withOpacity(0.01);
        canvas.drawLine(p1, p2, gridFloorPaint);
      }
    }

    // 2. Project all particles
    final List<_ProjectedParticle> projected = [];
    for (var p in particles) {
      // Apply same transformations
      double rx = p.x * cosY - p.z * sinY;
      double rz = p.x * sinY + p.z * cosY;

      double ry = p.y * cosX - rz * sinX;
      double rzFinal = p.y * sinX + rz * cosX;

      if (rzFinal + focalLength > 10) {
        double scale = focalLength / (rzFinal + focalLength);
        double screenX = centerX + rx * scale;
        double screenY = centerY + ry * scale;
        projected.add(_ProjectedParticle(
          screenPos: Offset(screenX, screenY),
          depth: rzFinal,
          scale: scale,
          original: p,
        ));
      }
    }

    // Sort by depth (back to front)
    projected.sort((a, b) => b.depth.compareTo(a.depth));

    // 3. Draw connection lines in 3D
    final linePaint = Paint()..strokeWidth = 0.8;
    for (int i = 0; i < projected.length; i++) {
      for (int j = i + 1; j < projected.length; j++) {
        final p1 = projected[i];
        final p2 = projected[j];
        
        // Calculate 3D distance
        double dx = p1.original.x - p2.original.x;
        double dy = p1.original.y - p2.original.y;
        double dz = p1.original.z - p2.original.z;
        double distSq = dx * dx + dy * dy + dz * dz;
        double maxDist = 130.0;
        
        if (distSq < maxDist * maxDist) {
          double dist = math.sqrt(distSq);
          double alpha = 1.0 - (dist / maxDist);
          alpha = alpha.clamp(0.0, 1.0) * 0.12;

          // Merge color based on both nodes
          final bool isSameColor = p1.original.color == p2.original.color;
          final color = isSameColor
              ? p1.original.color.withOpacity(alpha)
              : Colors.white.withOpacity(alpha * 0.5); // neutral line

          linePaint.color = color;
          canvas.drawLine(p1.screenPos, p2.screenPos, linePaint);
        }
      }
    }

    // 4. Draw particle dots and glow
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final glowPaint = Paint()..style = PaintingStyle.fill;

    for (var p in projected) {
      double renderRadius = p.original.radius * p.scale;
      // Adjust alpha by depth (closer nodes are brighter)
      double alphaScale = 1.0 - ((p.depth + 200) / 600); // 0 at far, 1 at close
      alphaScale = alphaScale.clamp(0.2, 1.0);

      // Core dot
      dotPaint.color = p.original.color.withOpacity(alphaScale * 0.8);
      canvas.drawCircle(p.screenPos, renderRadius, dotPaint);

      // Outer glow
      glowPaint.color = p.original.color.withOpacity(alphaScale * 0.15);
      canvas.drawCircle(p.screenPos, renderRadius * 3, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ProjectedParticle {
  final Offset screenPos;
  final double depth;
  final double scale;
  final ThreeDParticle original;

  _ProjectedParticle({
    required this.screenPos,
    required this.depth,
    required this.scale,
    required this.original,
  });
}
