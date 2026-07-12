import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/warp_grid_background.dart';
import 'widgets/glass_card.dart';
import 'widgets/holographic_skill_matrix.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vishnu VS | Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff000000),
        primaryColor: Colors.white,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xffa1a1aa),
          surface: Color(0xff09090b),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      home: const PortfolioShell(),
    );
  }
}

class PortfolioShell extends StatefulWidget {
  const PortfolioShell({Key? key}) : super(key: key);

  @override
  State<PortfolioShell> createState() => _PortfolioShellState();
}

class _PortfolioShellState extends State<PortfolioShell>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _timelineKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  int _activeNavIndex = 0;

  // Typewriter parameters
  late Timer _typewriterTimer;
  int _wordIndex = 0;
  int _charIndex = 0;
  String _currentDisplayText = "";
  bool _isDeleting = false;
  static const List<String> _typewriterWords = [
    "WEB DEVELOPER",
    "6G NETWORK RESEARCHER",
    "IEDC STUDENT LEAD 2025-26",
    "UI/UX DESIGNER",
  ];



  // Skills console state
  int _selectedSkillIndex = 0;

  static const List<SkillCategoryDetail> _skillsCategories = [
    SkillCategoryDetail(
      name: "Web Development",
      icon: Icons.web,
      description:
          "Building production-grade web systems and responsive core frontends.",
      skills: [
        "Flutter Web & Dart",
        " API Architectures",
        "Git & Deployment Modules",
      ],
    ),
    SkillCategoryDetail(
      name: "Graphic Design",
      icon: Icons.design_services,
      description:
          "Crafting modern vector layouts, typography hierarchies, and premium user interfaces.",
      skills: ["Figma Design", "Logo Design", "Web-App Prototyping"],
    ),
    SkillCategoryDetail(
      name: "AI & Computational CSE",
      icon: Icons.memory,
      description:
          "Developing intelligent agent pipelines and high-speed compiler architectures.",
      skills: [
        "Computer Vision Basics",
        "Centralized Learning Networks",
        "Graph Algorithms",
        "Python Core Modules",
      ],
    ),
    SkillCategoryDetail(
      name: "Leadership Operations",
      icon: Icons.groups,
      description:
          "Managing technical operations, mentoring engineering projects, and hosting tech bootcamps.",
      skills: [
        "IEDC (2025-26)",
        "Team Leadership",
        "Public Speaking",
        "Event Coordination",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTypewriter();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _typewriterTimer.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    try {
      final keys = [
        _aboutKey,
        _projectsKey,
        _timelineKey,
        _skillsKey,
        _contactKey,
      ];
      int activeIndex = _activeNavIndex;
      double minDistance = double.infinity;

      for (int i = 0; i < keys.length; i++) {
        final key = keys[i];
        if (key.currentContext == null) continue;
        final context = key.currentContext;
        if (context != null) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            final position = box.localToGlobal(Offset.zero);
            final distance = position.dy.abs();
            if (distance < minDistance) {
              minDistance = distance;
              activeIndex = i;
            }
          }
        }
      }
      if (_activeNavIndex != activeIndex) {
        setState(() => _activeNavIndex = activeIndex);
      }
    } catch (e) {
      debugPrint("Scroll listener state error: $e");
    }
  }

  void _scrollToKey(GlobalKey key, int navIndex) {
    setState(() => _activeNavIndex = navIndex);
    if (key.currentContext == null) return;
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _startTypewriter() {
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      final currentWord = _typewriterWords[_wordIndex];
      setState(() {
        if (!_isDeleting) {
          _currentDisplayText = currentWord.substring(0, _charIndex);
          _charIndex++;
          if (_charIndex > currentWord.length) {
            _isDeleting = true;
            timer.cancel();
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) _startTypewriter();
            });
          }
        } else {
          _charIndex--;
          _currentDisplayText = currentWord.substring(0, _charIndex);
          if (_charIndex == 0) {
            _isDeleting = false;
            _wordIndex = (_wordIndex + 1) % _typewriterWords.length;
          }
        }
      });
    });
  }

  // Removed _triggerConsoleLogs since it is replaced by HolographicSkillMatrix animation

  void _launchPhone() async {
    final Uri url = Uri.parse('tel:+918778944493');
    if (!await launchUrl(url)) {
      debugPrint("Failed to launch Phone dialer");
    }
  }

  void _launchLinkedIn() async {
    final Uri url = Uri.parse('https://www.linkedin.com/in/-vishnu-vs');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Failed to launch LinkedIn URL");
    }
  }

  void _launchEmail() async {
    final Uri url = Uri.parse(
      'mailto:vishnu_vs@ahalia.ac.in?subject=Portfolio%20Inquiry',
    );
    if (!await launchUrl(url)) {
      debugPrint("Failed to launch Email composer");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isMobile = screenSize.width < 1000;

    return Scaffold(
      body: SelectionArea(
        child: Stack(
          children: [
            // Background Canvas System
            Positioned.fill(child: const WarpGridBackground()),

            // Main Layout Viewport
            Positioned.fill(
              child: isMobile
                  ? _buildMobileLayout()
                  : _buildDesktopLayout(screenSize),
            ),
          ],
        ),
      ),
    );
  }

  // DESKTOP LAYOUT (Split Panel Grid workspace)
  Widget _buildDesktopLayout(Size size) {
    return Row(
      children: [
        // Left Column Panel (Brand Hub)
        Container(
          width: 320.0,
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 48.0),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.white.withOpacity(0.04)),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar with rotating halo simulation
                        Center(
                          child: Container(
                            width: 130.0,
                            height: 130.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white12,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 110.0,
                                height: 110.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.03),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    "assets/profile.png",
                                    width: 110.0,
                                    height: 110.0,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          "VS",
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 42.0,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // Name & Tag
                        Text(
                          "VISHNU VS",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          "B.Tech CSE Student & Developer",
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Typewriter effect status
                        Row(
                          children: [
                            Text(
                              "> ",
                              style: GoogleFonts.outfit(
                                color: Colors.white30,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _currentDisplayText,
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "|",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0),

                        // Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white.withOpacity(0.04),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white54,
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "AVAILABLE FOR WORK",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Spacer(),

                        // Left navigation shortcuts
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDesktopNavItem(
                              "01 // ARCHIVE_BIO",
                              0,
                              _aboutKey,
                            ),
                            _buildDesktopNavItem(
                              "02 // PORTFOLIO_GRID",
                              1,
                              _projectsKey,
                            ),
                            _buildDesktopNavItem(
                              "03 // JOURNEY_LINE",
                              2,
                              _timelineKey,
                            ),
                            _buildDesktopNavItem(
                              "04 // SYSTEM_SKILLS",
                              3,
                              _skillsKey,
                            ),
                            _buildDesktopNavItem(
                              "05 // CONTACT_LINK",
                              4,
                              _contactKey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        const Spacer(),

                        // Social connections
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.link,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: _launchLinkedIn,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.email_outlined,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: _launchEmail,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Right Workspace Grid (Dynamic Scroll view)
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: 48.0,
              vertical: 48.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAboutModule(false),
                const SizedBox(height: 64.0),
                _buildProjectsModule(false),
                const SizedBox(height: 64.0),
                _buildTimelineModule(false),
                const SizedBox(height: 64.0),
                _buildSkillsModule(false),
                const SizedBox(height: 64.0),
                _buildContactModule(false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // MOBILE LAYOUT (Stacked vertical columns)
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 24.0),
          // Profile header card
          GlassCard(
            isHoverable: false,
            child: Column(
              children: [
                Container(
                  width: 90.0,
                  height: 90.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12, width: 1.5),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/profile.png",
                      width: 90.0,
                      height: 90.0,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            "VS",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  "VISHNU VS",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 26.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "B.Tech CSE Student & Lead",
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.link, size: 20),
                      onPressed: _launchLinkedIn,
                    ),
                    IconButton(
                      icon: const Icon(Icons.email_outlined, size: 20),
                      onPressed: _launchEmail,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          _buildAboutModule(true),
          const SizedBox(height: 32.0),
          _buildProjectsModule(true),
          const SizedBox(height: 32.0),
          _buildTimelineModule(true),
          const SizedBox(height: 32.0),
          _buildSkillsModule(true),
          const SizedBox(height: 32.0),
          _buildContactModule(true),
          const SizedBox(height: 48.0),
        ],
      ),
    );
  }

  // DESKTOP NAVIGATION BUTTONS
  Widget _buildDesktopNavItem(String label, int index, GlobalKey key) {
    final bool isActive = _activeNavIndex == index;
    return TextButton(
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      onPressed: () => _scrollToKey(key, index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 12.0 : 0.0,
              height: 1.5,
              color: Colors.white,
              margin: EdgeInsets.only(right: isActive ? 8.0 : 0.0),
            ),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. ABOUT MODULE
  Widget _buildAboutModule(bool isMobile) {
    return Container(
      key: _aboutKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleTitle("01 // EXECUTIVE SUMMARY", "ABOUT ME"),
          const SizedBox(height: 20.0),
          isMobile
              ? Column(
                  children: [
                    _buildBioCard(),
                    const SizedBox(height: 16.0),
                    _buildCapabilitiesCard(),
                  ],
                )
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildBioCard()),
                      const SizedBox(width: 24.0),
                      Expanded(child: _buildCapabilitiesCard()),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBioCard() {
    return GlassCard(
      isHoverable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.white, size: 22.0),
              const SizedBox(width: 12.0),
              Text(
                "BIOGRAPHY",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          Text(
            "Greetings! I'm a Final Year Computer Science & Engineering student at Ahalia School of Engineering and Technology, specializing in building high-quality web applications and interactive interfaces.",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            "Graphic Designer | Web Developer\nPassionate about designing engaging visuals and developing modern, responsive websites that deliver seamless user experiences.",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13.5,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesCard() {
    return GlassCard(
      isHoverable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 20.0,
              ),
              const SizedBox(width: 12.0),
              Text(
                "CORE CAPABILITIES",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          _buildMiniProgress("WEB ARCHITECTURES (FLUTTER/JS)", 0.94, 1.0),
          const SizedBox(height: 14.0),
          _buildMiniProgress("GRAPHIC DESIGN (UI/UX)", 0.92, 0.8),
          const SizedBox(height: 14.0),
          _buildMiniProgress("AI & COMPUTER NETWORKING", 0.88, 0.6),
          const SizedBox(height: 14.0),
          _buildMiniProgress("OPERATIONS & LEADERSHIP", 0.98, 0.4),
        ],
      ),
    );
  }

  Widget _buildMiniProgress(String label, double val, double opacity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${(val * 100).toInt()}%",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            height: 4.0,
            width: double.infinity,
            color: Colors.white.withOpacity(0.04),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: val,
                child: Container(
                  color: Colors.white.withOpacity(opacity * 0.7 + 0.2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 2. PROJECTS MODULE
  Widget _buildProjectsModule(bool isMobile) {
    final List<ProjectDetail> projList = const [
      ProjectDetail(
        title: "Visual Compiler",
        subtitle: "Layout Engine & LLM Guardrails // Mini Project",
        description:
            "A canvas-based editor that lets developers compile visual UI mockups into clean codebase templates.",
        accomplishments: [
          "Engineered a custom canvas-to-code layout engine that compiles visual UI mockups into clean, responsive templates.",
          "Decreased layout generation hallucinations by 80% through target-constrained parsing rules.",
        ],
        technologies: ["Flutter", "Dart", "Python"],
        icon: Icons.code,
        githubUrl: "https://github.com/vishnu-vsgit/portfolio",
      ),
      ProjectDetail(
        title: "AV Perception",
        subtitle: "AI Perception & Edge Privacy // Internship Project",
        description:
            "Worked on an AI research project focused on autonomous vehicle perception, centralized learning, and data anonymization at AI NEST Research Lab, Amrita Vishwa Vidyapeetham.",
        accomplishments: [
          "Developed edge-anonymization camera pipelines using PyTorch to secure local vehicle telemetry data.",
          "Optimized model inference constraints for real-time operation on low-power edge compute hardware.",
        ],
        technologies: [
          "Vision AI",
          "PyTorch",
          "Centralized Learning",
          "Privacy",
        ],
        icon: Icons.directions_car,
      ),
      ProjectDetail(
        title: "6G Congestion Control",
        subtitle: "Active R&D Project",
        description:
            "This project is currently under active development. Detailed specifications and modules will be updated here soon.",
        accomplishments: [],
        technologies: ["6G Networks", "R&D"],
        icon: Icons.settings_input_antenna,
      ),
    ];

    return Container(
      key: _projectsKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleTitle("02 // PORTFOLIO_INDEX", "PROJECTS"),
          const SizedBox(height: 20.0),
          isMobile
              ? Column(
                  children: projList.map((project) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildProjectCard(project, true),
                    );
                  }).toList(),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: projList.map((project) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildProjectCard(project, false),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }



  Widget _buildProjectCard(ProjectDetail project, bool isMobile) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
              child: Icon(project.icon, color: Colors.white, size: 20.0),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    project.subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (project.githubUrl != null || project.liveUrl != null) ...[
              const SizedBox(width: 8.0),
              if (project.githubUrl != null)
                IconButton(
                  icon: const Icon(Icons.code, size: 18, color: Colors.white70),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    final Uri url = Uri.parse(project.githubUrl!);
                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    )) {
                      debugPrint("Failed to launch GitHub URL");
                    }
                  },
                  tooltip: "View Source Code",
                ),
              if (project.liveUrl != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.open_in_new,
                    size: 18,
                    color: Colors.white70,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    final Uri url = Uri.parse(project.liveUrl!);
                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    )) {
                      debugPrint("Failed to launch Live URL");
                    }
                  },
                  tooltip: "View Live Demo",
                ),
              ],
            ],
          ],
        ),
        const SizedBox(height: 16.0),
        Text(
          project.description,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.75),
            fontSize: 12.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16.0),
        ...project.accomplishments.map((bullet) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  width: 4.0,
                  height: 4.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    bullet,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12.0,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        if (!isMobile) const Spacer(),
        const SizedBox(height: 14.0),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: project.technologies.map((tech) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                tech,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );

    return GlassCard(
      child: isMobile ? content : SizedBox(height: 380.0, child: content),
    );
  }

  // 3. TIMELINE MODULE
  Widget _buildTimelineModule(bool isMobile) {
    final List<ExperienceTimelineItem> archive = const [
      ExperienceTimelineItem(
        role: "6G Network Prediction Researcher",
        company: "Amrita College",
        duration: "2026 - PRESENT",
        details:
            "Developing GNN prediction metrics to forecast 6G spectra loading spikes and balancing latency routing.",
      ),
      ExperienceTimelineItem(
        role: "IEDC Student Lead",
        company: "Innovation Development Centre (IEDC)",
        duration: "2025 - 2026",
        details:
            "Managing entrepreneurship bootcamps, vector graphics bootcamps, and technical student hackathons.",
      ),
      ExperienceTimelineItem(
        role: "Artificial Intelligence Intern",
        company: "Amrita Vishwa Vidyapeetham",
        duration: "2025 (INTERNSHIP)",
        details:
            "Adapted autonomous cameras classification while keeping local telemetry anonymized at edge.",
      ),
      ExperienceTimelineItem(
        role: "Computer Science Student",
        company: "Ahalia CSE School",
        duration: "2023 - 2027",
        details:
            "Core undergraduate studies in Compilers, Networks, Object-Oriented layouts, and AI algorithms.",
      ),
    ];

    return Container(
      key: _timelineKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleTitle("03 // HISTORICAL_INDEX", "EXPERIENCE TIMELINE"),
          const SizedBox(height: 20.0),
          GlassCard(
            isHoverable: false,
            child: Column(
              children: archive.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4.0),
                            width: 10.0,
                            height: 10.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: 1.0,
                            height: 45.0,
                            color: Colors.white10,
                          ),
                        ],
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.role,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  item.duration,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white54,
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              item.company,
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 4. SKILLS CONSOLE MODULE
  Widget _buildSkillsModule(bool isMobile) {
    return Container(
      key: _skillsKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleTitle("04 // SYSTEM_ABILITIES", "SKILLS INDEX"),
          const SizedBox(height: 20.0),
          isMobile
              ? Column(
                  children: [
                    _buildSkillsSelectors(),
                    const SizedBox(height: 16.0),
                    _buildConsoleScreen(),
                  ],
                )
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 5, child: _buildSkillsSelectors()),
                      const SizedBox(width: 24.0),
                      Expanded(flex: 5, child: _buildConsoleScreen()),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSkillsSelectors() {
    return Column(
      children: List.generate(_skillsCategories.length, (index) {
        final category = _skillsCategories[index];
        final bool isSelected = _selectedSkillIndex == index;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            borderRadius: 12.0,
            padding: EdgeInsets.zero,
            onTap: () {
              setState(() => _selectedSkillIndex = index);
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: isSelected
                  ? Colors.white.withOpacity(0.04)
                  : Colors.transparent,
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    color: isSelected ? Colors.white : Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          category.description,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white54,
                            fontSize: 10.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isSelected ? Colors.white : Colors.white12,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildConsoleScreen() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white12,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "console@vishnu_vs:~/skills",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white30,
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Container(
            height: 180.0,
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: HolographicSkillMatrix(
              skills: _skillsCategories[_selectedSkillIndex].skills,
              categoryIndex: _selectedSkillIndex,
            ),
          ),
        ],
      ),
    );
  }

  // 5. CONTACT MODULE
  Widget _buildContactModule(bool isMobile) {
    return Container(
      key: _contactKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModuleTitle("05 // CONNECT_LINK", "GET IN TOUCH"),
          const SizedBox(height: 20.0),
          _buildMiniContactInfo(),
        ],
      ),
    );
  }

  Widget _buildMiniContactInfo() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ESTABLISH LINK",
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14.0),
          Text(
            "I'm open to discussing web systems, compiler structures, UI/UX graphics, or research opportunities. Tap below to launch channels directly.",
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13.0,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24.0),
          _buildContactRow(
            Icons.link,
            "LINKEDIN NETWORK",
            "linkedin.com/in/-vishnu-vs",
            _launchLinkedIn,
          ),
          const SizedBox(height: 12.0),
          _buildContactRow(
            Icons.email_outlined,
            "ELECTRONIC MAIL",
            "vishnu_vs@ahalia.ac.in",
            _launchEmail,
          ),
          const SizedBox(height: 12.0),
          _buildContactRow(
            Icons.phone,
            "TELEPHONE CONNECTION",
            "+91 87789 44493",
            _launchPhone,
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String title,
    String val,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 9.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    val,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }



  // CORE TITLES PAINTER
  Widget _buildModuleTitle(String numLabel, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          numLabel,
          style: GoogleFonts.outfit(
            color: Colors.white54,
            fontSize: 11.0,
            letterSpacing: 1.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6.0),
        Container(width: 40.0, height: 2.0, color: Colors.white24),
      ],
    );
  }
}

// Data holder helper classes inside main.dart for complete decoupling
class ProjectDetail {
  final String title;
  final String subtitle;
  final String description;
  final List<String> accomplishments;
  final List<String> technologies;
  final IconData icon;
  final String? githubUrl;
  final String? liveUrl;

  const ProjectDetail({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accomplishments,
    required this.technologies,
    required this.icon,
    this.githubUrl,
    this.liveUrl,
  });
}

class ExperienceTimelineItem {
  final String role;
  final String company;
  final String duration;
  final String details;

  const ExperienceTimelineItem({
    required this.role,
    required this.company,
    required this.duration,
    required this.details,
  });
}

class SkillCategoryDetail {
  final String name;
  final IconData icon;
  final String description;
  final List<String> skills;

  const SkillCategoryDetail({
    required this.name,
    required this.icon,
    required this.description,
    required this.skills,
  });
}
