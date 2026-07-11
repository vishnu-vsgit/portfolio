import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_card.dart';

class DesignItem {
  final String filename;
  final String title;
  final String category;
  final String path;
  final String dimensions;
  final String extension;
  final String size;
  final String tools;

  const DesignItem({
    required this.filename,
    required this.title,
    required this.category,
    required this.path,
    required this.dimensions,
    required this.extension,
    required this.size,
    required this.tools,
  });
}

class DesignCarousel extends StatefulWidget {
  final bool isMobile;
  const DesignCarousel({Key? key, required this.isMobile}) : super(key: key);

  @override
  State<DesignCarousel> createState() => _DesignCarouselState();
}

class _DesignCarouselState extends State<DesignCarousel> {
  int _selectedIndex = 0;
  bool _isLoading = false;
  Timer? _loadingTimer;
  double _scanlineOffset = 0.0;
  late Timer _scanlineTimer;

  final List<DesignItem> _items = const [
    DesignItem(
      filename: "DESIGN_01.PNG",
      title: "Neon UI Concept",
      category: "Mobile Application UI",
      path: "assets/design_1.png",
      dimensions: "4320 x 5236 PX",
      extension: "PNG",
      size: "1.57 MB",
      tools: "Figma",
    ),
    DesignItem(
      filename: "DESIGN_02.JPEG",
      title: "Minimalist Web Layout",
      category: "Responsive Web System",
      path: "assets/design_2.jpeg",
      dimensions: "1152 x 1440 PX",
      extension: "JPEG",
      size: "136 KB",
      tools: "Figma",
    ),
    DesignItem(
      filename: "DESIGN_03.JPEG",
      title: "Creative Poster Art",
      category: "Vector Illustration",
      path: "assets/design_3.jpeg",
      dimensions: "1023 x 1280 PX",
      extension: "JPEG",
      size: "144 KB",
      tools: "Figma",
    ),
    DesignItem(
      filename: "DESIGN_04.JPEG",
      title: "Corporate Brand Book",
      category: "Brand Book & Identity",
      path: "assets/design_4.jpeg",
      dimensions: "1170 x 1463 PX",
      extension: "JPEG",
      size: "186 KB",
      tools: "Figma",
    ),
    DesignItem(
      filename: "DESIGN_05.JPEG",
      title: "Abstract Workspace Layout",
      category: "Visual Architecture",
      path: "assets/design_5.jpeg",
      dimensions: "1170 x 1170 PX",
      extension: "JPEG",
      size: "135 KB",
      tools: "Figma",
    ),
    DesignItem(
      filename: "DESIGN_06.JPEG",
      title: "Modern Brand Visual",
      category: "Brand Graphic & Visuals",
      path: "assets/design_6.jpeg",
      dimensions: "1024 x 1280 PX",
      extension: "JPEG",
      size: "163 KB",
      tools: "Figma",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scanlineTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _scanlineOffset = (_scanlineOffset + 0.015) % 1.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _scanlineTimer.cancel();
    super.dispose();
  }

  void _selectIndex(int index) {
    if (index == _selectedIndex) return;
    _loadingTimer?.cancel();
    setState(() {
      _isLoading = true;
    });
    _loadingTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _selectedIndex = index;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeItem = _items[_selectedIndex];

    return widget.isMobile
        ? _buildMobileDashboard(activeItem)
        : _buildDesktopDashboard(activeItem);
  }

  Widget _buildDesktopDashboard(DesignItem activeItem) {
    return SizedBox(
      height: 420.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Sidebar: File system index tree
          Container(
            width: 240.0,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.01),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.folder_open_outlined, color: Colors.cyan, size: 16.0),
                    const SizedBox(width: 8.0),
                    Text(
                      "ASSET_INDEX // SOURCE",
                      style: GoogleFonts.shareTechMono(
                        color: Colors.cyan,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 16.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final bool isSelected = index == _selectedIndex;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: InkWell(
                          onTap: () => _selectIndex(index),
                          borderRadius: BorderRadius.circular(8.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.cyan.withOpacity(0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: isSelected ? Colors.cyan.withOpacity(0.3) : Colors.transparent,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.insert_drive_file_outlined,
                                  color: isSelected ? Colors.cyan : Colors.white38,
                                  size: 14.0,
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    item.filename,
                                    style: GoogleFonts.shareTechMono(
                                      color: isSelected ? Colors.cyan : Colors.white70,
                                      fontSize: 11.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  item.extension,
                                  style: GoogleFonts.shareTechMono(
                                    color: Colors.white24,
                                    fontSize: 9.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),

          // Right Viewport and Metadata panel
          Expanded(
            child: Row(
              children: [
                // Image viewport
                Expanded(
                  flex: 3,
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 16.0,
                    isHoverable: false,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Calibrated terminal grids backdrop
                          _buildGridBackground(),

                          // Image
                          if (!_isLoading)
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Image.asset(
                                  activeItem.path,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
                                ),
                              ),
                            ),

                          // Interactive overlay viewport corners
                          _buildViewportCorners(),

                          // Animated Scanline overlay
                          _buildScanlineOverlay(),

                          // Glitch loading panel
                          if (_isLoading) _buildLoadingGlitch(),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),

                // Asset Metadata Inspector panel
                Expanded(
                  flex: 2,
                  child: GlassCard(
                    padding: const EdgeInsets.all(16.0),
                    borderRadius: 16.0,
                    isHoverable: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "INSPECTOR_V1.0",
                              style: GoogleFonts.shareTechMono(
                                color: Colors.white30,
                                fontSize: 10.0,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4.0),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: Text(
                                "ONLINE",
                                style: GoogleFonts.shareTechMono(
                                  color: Colors.green,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          activeItem.title.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          activeItem.category,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.cyan,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(color: Colors.white10, height: 24.0),
                        _buildMetaRow("ASSET_ID", "VS_DS_0${_selectedIndex + 1}"),
                        _buildMetaRow("RESOLUTION", activeItem.dimensions),
                        _buildMetaRow("FILE_SIZE", activeItem.size),
                        _buildMetaRow("FORMAT_TYPE", activeItem.extension),
                        _buildMetaRow("ENGINE_CORE", activeItem.tools),
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.cyan.withOpacity(0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SYSTEM CONSOLE // STATUS",
                                style: GoogleFonts.shareTechMono(
                                  color: Colors.cyan,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                "Data buffer decrypted successfully. Output matches grid dimensions.",
                                style: GoogleFonts.shareTechMono(
                                  color: Colors.white54,
                                  fontSize: 9.0,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDashboard(DesignItem activeItem) {
    return Column(
      children: [
        // 1. Viewport screen
        SizedBox(
          height: 220.0,
          child: GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: 16.0,
            isHoverable: false,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildGridBackground(),
                  if (!_isLoading)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          activeItem.path,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
                        ),
                      ),
                    ),
                  _buildViewportCorners(),
                  _buildScanlineOverlay(),
                  if (_isLoading) _buildLoadingGlitch(),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12.0),

        // 2. Horizontal selection tabs
        SizedBox(
          height: 38.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(
                    "DS_0${index + 1}",
                    style: GoogleFonts.shareTechMono(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) _selectIndex(index);
                  },
                  selectedColor: Colors.cyan,
                  backgroundColor: Colors.white.withOpacity(0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: isSelected ? Colors.cyan : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12.0),

        // 3. Compact Meta Details Info
        GlassCard(
          padding: const EdgeInsets.all(12.0),
          borderRadius: 12.0,
          isHoverable: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activeItem.title.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                activeItem.category,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.cyan,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.white10, height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMobileMetaTag("SIZE: ${activeItem.size}"),
                  _buildMobileMetaTag("DIM: ${activeItem.dimensions.split(' ')[0]}"),
                  _buildMobileMetaTag("TECH: ${activeItem.tools.split(' ')[0]}"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridBackground() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: CustomPaint(
          painter: _TerminalGridPainter(),
        ),
      ),
    );
  }

  Widget _buildViewportCorners() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomPaint(
          painter: _CornerCrosshairPainter(),
        ),
      ),
    );
  }

  Widget _buildScanlineOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.cyan.withOpacity(0.015),
                Colors.cyan.withOpacity(0.06),
                Colors.cyan.withOpacity(0.015),
                Colors.transparent,
              ],
              stops: [
                (_scanlineOffset - 0.15).clamp(0.0, 1.0),
                (_scanlineOffset - 0.05).clamp(0.0, 1.0),
                _scanlineOffset,
                (_scanlineOffset + 0.05).clamp(0.0, 1.0),
                (_scanlineOffset + 0.15).clamp(0.0, 1.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingGlitch() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Colors.cyan,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan.withOpacity(0.8)),
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              "DECRYPTING_ASSET...",
              style: GoogleFonts.shareTechMono(
                color: Colors.cyan,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.white.withOpacity(0.02),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined, color: Colors.white24, size: 36.0),
            const SizedBox(height: 8.0),
            Text(
              "Asset decrypted block error",
              style: GoogleFonts.shareTechMono(color: Colors.white24, fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.0,
            child: Text(
              label,
              style: GoogleFonts.shareTechMono(
                color: Colors.white30,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.shareTechMono(
                color: Colors.white70,
                fontSize: 10.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMetaTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Text(
        label,
        style: GoogleFonts.shareTechMono(
          color: Colors.white54,
          fontSize: 9.5,
        ),
      ),
    );
  }
}

class _TerminalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.04)
      ..strokeWidth = 0.5;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerCrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const len = 10.0;

    // Top-Left
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, len), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - len), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
