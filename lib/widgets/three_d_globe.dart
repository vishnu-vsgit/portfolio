import 'dart:math' as math;
import 'package:flutter/material.dart';

class ThreeDGlobe extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const ThreeDGlobe({
    Key? key,
    this.size = 350.0,
    this.primaryColor = const Color(0xff00f3ff),
    this.secondaryColor = const Color(0xff9d4edd),
  }) : super(key: key);

  @override
  State<ThreeDGlobe> createState() => _ThreeDGlobeState();
}

class _ThreeDGlobeState extends State<ThreeDGlobe> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  
  double _angleX = -0.3; // Default tilt
  double _angleY = 0.0;
  double _dragStartX = 0.0;
  double _dragStartY = 0.0;
  double _angleXOnDragStart = 0.0;
  double _angleYOnDragStart = 0.0;

  final List<GlobePoint> _points = [];
  final int _latSegments = 10;
  final int _longSegments = 14;
  final double _radius = 120.0;

  @override
  void initState() {
    super.initState();
    
    // Generate grid points on the sphere surface
    for (int lat = 0; lat <= _latSegments; lat++) {
      final double phi = math.pi * lat / _latSegments - math.pi / 2; // -pi/2 to pi/2
      final double cosPhi = math.cos(phi);
      final double sinPhi = math.sin(phi);

      for (int lon = 0; lon < _longSegments; lon++) {
        final double theta = 2.0 * math.pi * lon / _longSegments; // 0 to 2pi
        final double cosTheta = math.cos(theta);
        final double sinTheta = math.sin(theta);

        final double x = _radius * cosPhi * cosTheta;
        final double y = _radius * sinPhi;
        final double z = _radius * cosPhi * sinTheta;

        _points.add(GlobePoint(
          x: x, 
          y: y, 
          z: z, 
          latIndex: lat, 
          lonIndex: lon,
        ));
      }
    }

    // Auto-spin animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..addListener(() {
        setState(() {
          // Slow continuous spin around Y axis
          _angleY += 0.003;
        });
      });
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
    _dragStartY = details.localPosition.dy;
    _angleXOnDragStart = _angleX;
    _angleYOnDragStart = _angleY;
    _rotationController.stop(); // Stop automatic spin during manual interaction
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final double dx = details.localPosition.dx - _dragStartX;
    final double dy = details.localPosition.dy - _dragStartY;
    
    setState(() {
      // Map drag offset to camera yaw/pitch angles
      _angleY = _angleYOnDragStart + (dx * 0.01);
      _angleX = _angleXOnDragStart - (dy * 0.01);
      
      // Limit pitch to prevent flipping upside down
      _angleX = _angleX.clamp(-math.pi / 2.2, math.pi / 2.2);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Resume auto spin after releasing
    _rotationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _GlobePainter(
          points: _points,
          angleX: _angleX,
          angleY: _angleY,
          latSegments: _latSegments,
          longSegments: _longSegments,
          primaryColor: widget.primaryColor,
          secondaryColor: widget.secondaryColor,
        ),
      ),
    );
  }
}

class GlobePoint {
  final double x, y, z;
  final int latIndex;
  final int lonIndex;

  GlobePoint({
    required this.x,
    required this.y,
    required this.z,
    required this.latIndex,
    required this.lonIndex,
  });
}

class _GlobePainter extends CustomPainter {
  final List<GlobePoint> points;
  final double angleX;
  final double angleY;
  final int latSegments;
  final int _longSegments;
  final Color primaryColor;
  final Color secondaryColor;

  _GlobePainter({
    required this.points,
    required this.angleX,
    required this.angleY,
    required this.latSegments,
    required int longSegments,
    required this.primaryColor,
    required this.secondaryColor,
  }) : _longSegments = longSegments;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double focalLength = 320.0;

    final cosX = math.cos(angleX);
    final sinX = math.sin(angleX);
    final cosY = math.cos(angleY);
    final sinY = math.sin(angleY);

    // Project coordinates function
    _ProjectedPoint? project(GlobePoint gp) {
      // 1. Rotate around Y axis
      double rx1 = gp.x * cosY - gp.z * sinY;
      double rz1 = gp.x * sinY + gp.z * cosY;

      // 2. Rotate around X axis
      double ry2 = gp.y * cosX - rz1 * sinX;
      double rz2 = gp.y * sinX + rz1 * cosX;

      if (rz2 + focalLength <= 10) return null;

      double scale = focalLength / (rz2 + focalLength);
      return _ProjectedPoint(
        offset: Offset(cx + rx1 * scale, cy + ry2 * scale),
        depth: rz2,
        scale: scale,
        latIndex: gp.latIndex,
        lonIndex: gp.lonIndex,
      );
    }

    // Project all points
    final List<_ProjectedPoint> projected = [];
    for (var p in points) {
      final proj = project(p);
      if (proj != null) {
        projected.add(proj);
      }
    }

    // Organize by coordinates indices to draw grid lines
    final Map<String, _ProjectedPoint> gridMap = {};
    for (var p in projected) {
      gridMap["${p.latIndex}_${p.lonIndex}"] = p;
    }

    // 1. Draw grid connections (back and front)
    final gridPaint = Paint()..style = PaintingStyle.stroke;
    
    void drawConnection(_ProjectedPoint p1, _ProjectedPoint p2) {
      // Calculate opacity based on average depth (fainter behind, brighter in front)
      // Depth ranges from -radius to +radius
      double avgDepth = (p1.depth + p2.depth) / 2;
      double opacity = 1.0 - ((avgDepth + 120.0) / 240.0); // 0 in back, 1 in front
      opacity = opacity.clamp(0.08, 0.85);

      final color = Color.lerp(primaryColor, secondaryColor, (p1.latIndex / latSegments));
      gridPaint.color = color!.withOpacity(opacity * 0.18);
      gridPaint.strokeWidth = 0.6 + (opacity * 0.8);
      canvas.drawLine(p1.offset, p2.offset, gridPaint);
    }

    // Draw lines along latitudes
    for (int lat = 0; lat <= latSegments; lat++) {
      for (int lon = 0; lon < _longSegments; lon++) {
        final pCurrent = gridMap["${lat}_$lon"];
        final pNext = gridMap["${lat}_${(lon + 1) % _longSegments}"];
        if (pCurrent != null && pNext != null) {
          drawConnection(pCurrent, pNext);
        }
      }
    }

    // Draw lines along longitudes
    for (int lat = 0; lat < latSegments; lat++) {
      for (int lon = 0; lon < _longSegments; lon++) {
        final pCurrent = gridMap["${lat}_$lon"];
        final pNext = gridMap["${lat + 1}_$lon"];
        if (pCurrent != null && pNext != null) {
          drawConnection(pCurrent, pNext);
        }
      }
    }

    // 2. Sort nodes by depth to draw back-to-front
    projected.sort((a, b) => b.depth.compareTo(a.depth));

    // 3. Draw nodes (intersections)
    final nodePaint = Paint()..style = PaintingStyle.fill;
    final glowPaint = Paint()..style = PaintingStyle.fill;

    for (var p in projected) {
      double avgDepth = p.depth;
      double opacity = 1.0 - ((avgDepth + 120.0) / 240.0);
      opacity = opacity.clamp(0.1, 1.0);

      final baseColor = Color.lerp(primaryColor, secondaryColor, (p.latIndex / latSegments))!;
      double radius = (1.8 + opacity * 2.0) * p.scale;

      // Draw outer glow for front nodes
      if (opacity > 0.6) {
        glowPaint.color = baseColor.withOpacity(opacity * 0.15);
        canvas.drawCircle(p.offset, radius * 3.5, glowPaint);
      }

      nodePaint.color = baseColor.withOpacity(opacity * 0.9);
      canvas.drawCircle(p.offset, radius, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ProjectedPoint {
  final Offset offset;
  final double depth;
  final double scale;
  final int latIndex;
  final int lonIndex;

  _ProjectedPoint({
    required this.offset,
    required this.depth,
    required this.scale,
    required this.latIndex,
    required this.lonIndex,
  });
}
