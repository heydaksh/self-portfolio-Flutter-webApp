import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../utils/responsive_utils.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key, this.onHireMeTap});

  final VoidCallback? onHireMeTap;

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection>
    with TickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Controllers & Streams
  // ---------------------------------------------------------------------------

  late Stream<DocumentSnapshot> _profileStream;

  late AnimationController _animationController;
  late AnimationController _codeController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late PageController _pageController;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  int _currentPage = 0;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _profileStream = FirebaseFirestore.instance
        .collection('profile')
        .doc('main_info')
        .snapshots();

    _pageController = PageController(initialPage: 0);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _codeController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _codeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return VisibilityDetector(
      key: const Key('home_animation_controller'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0) {
          if (_codeController.isAnimating) _codeController.stop();
        } else {
          if (!_codeController.isAnimating) _codeController.repeat();
        }
      },
      child: Container(
        height: size.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _codeController,
              builder: (context, child) => CustomPaint(
                painter: CodePainter(_codeController.value),
                size: size,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: ResponsiveUtils.sectionPadding(context),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _profileStream,
                  builder: (context, snapshot) {
                    String name = 'Daksh Suthar';
                    String? photoUrl;
                    String? resumeUrl;

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;

                      if (data['name'] != null &&
                          data['name'].toString().isNotEmpty) {
                        name = data['name'];
                      }

                      photoUrl = data['photoUrl'];
                      resumeUrl = data['resume'];
                    }

                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) => FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ResponsiveUtils.isDesktop(context)
                              ? _buildDesktopLayout(
                                  context,
                                  name,
                                  photoUrl,
                                  resumeUrl,
                                )
                              : _buildMobileLayout(
                                  context,
                                  name,
                                  photoUrl,
                                  resumeUrl,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Layouts
  // ---------------------------------------------------------------------------

  Widget _buildDesktopLayout(
    BuildContext context,
    String name,
    String? photoUrl,
    String? resumeUrl,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGreeting(context),
              ResponsiveUtils.verticalSpace(context, 15),
              _buildName(context, name),
              ResponsiveUtils.verticalSpace(context, 20),
              _buildTitle(context),
              ResponsiveUtils.verticalSpace(context, 20),
              _buildDescription(context),
              ResponsiveUtils.verticalSpace(context, 30),
              _buildActionButtons(context, resumeUrl),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildProfileImage(context, photoUrl),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    String name,
    String? photoUrl,
    String? resumeUrl,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProfileImage(context, photoUrl),
        ResponsiveUtils.verticalSpace(context, 30),
        _buildGreeting(context),
        ResponsiveUtils.verticalSpace(context, 15),
        _buildName(context, name),
        ResponsiveUtils.verticalSpace(context, 15),
        _buildTitle(context),
        ResponsiveUtils.verticalSpace(context, 25),
        _buildDescription(context),
        ResponsiveUtils.verticalSpace(context, 30),
        _buildActionButtons(context, resumeUrl),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Text & content
  // ---------------------------------------------------------------------------

  Widget _buildGreeting(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.paddingSymmetric(
        context,
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(ResponsiveUtils.radius(context, 50)),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
        ),
      ),
      child: Text(
        '👋 Hello, I\'m',
        style: TextStyle(
          color: Colors.white,
          fontSize: ResponsiveUtils.fontSize(context, 17),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildName(BuildContext context, String name) {
    return Text(
      name,
      style: TextStyle(
        fontSize: ResponsiveUtils.fontSize(
          context,
          ResponsiveUtils.isMobile(context)
              ? 32
              : ResponsiveUtils.isTablet(context)
                  ? 40
                  : 48,
        ),
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.1,
        letterSpacing: -1,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Flutter Developer',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: ResponsiveUtils.fontSize(
                  context,
                  ResponsiveUtils.isMobile(context)
                      ? 18
                      : ResponsiveUtils.isTablet(context)
                          ? 20
                          : 24,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
            ResponsiveUtils.horizontalSpace(context, 12),
            Container(
              width: ResponsiveUtils.width(context, 9),
              height: ResponsiveUtils.height(context, 9),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF10B981),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
        ResponsiveUtils.verticalSpace(context, 8),
        // Text(
        //   '5 Months+ Experience',
        //   style: TextStyle(
        //     color: Colors.grey[400],
        //     fontSize: ResponsiveUtils.fontSize(
        //       context,
        //       ResponsiveUtils.isMobile(context)
        //           ? 14
        //           : ResponsiveUtils.isTablet(context)
        //               ? 16
        //               : 18,
        //     ),
        //     fontWeight: FontWeight.w400,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      'Passionate about creating beautiful, performant mobile applications with Flutter. I love turning complex problems into simple, elegant solutions.',
      style: ResponsiveUtils.bodyLarge(context).copyWith(
        color: Colors.grey[400],
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Buttons
  // ---------------------------------------------------------------------------

  Widget _buildActionButtons(BuildContext context, String? resumeUrl) {
    return ResponsiveUtils.isMobile(context)
        ? Column(
            children: [
              _buildPrimaryButton(context),
              ResponsiveUtils.verticalSpace(context, 12),
              _buildSecondaryButton(context, resumeUrl),
            ],
          )
        : Row(
            children: [
              _buildPrimaryButton(context),
              ResponsiveUtils.horizontalSpace(context, 16),
              _buildSecondaryButton(context, resumeUrl),
            ],
          );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return Container(
      width: ResponsiveUtils.isMobile(context) ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF10B981),
          ],
        ),
        borderRadius:
            BorderRadius.circular(ResponsiveUtils.radius(context, 30)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: ResponsiveUtils.width(context, 20),
            offset: Offset(0, ResponsiveUtils.height(context, 10)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(ResponsiveUtils.radius(context, 30)),
          onTap: () {
            widget.onHireMeTap?.call();
          },
          child: Padding(
            padding: ResponsiveUtils.paddingSymmetric(
              context,
              horizontal: 32,
              vertical: 16,
            ),
            child: Row(
              mainAxisSize: ResponsiveUtils.isMobile(context)
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.work_rounded,
                  color: Colors.white,
                  size: ResponsiveUtils.width(context, 20),
                ),
                ResponsiveUtils.horizontalSpace(context, 8),
                Text(
                  'Hire Me',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    String? resumeUrl,
  ) {
    return Container(
      width: ResponsiveUtils.isMobile(context) ? double.infinity : null,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(ResponsiveUtils.radius(context, 30)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(ResponsiveUtils.radius(context, 30)),
          onTap: () async {
            if (resumeUrl == null || resumeUrl.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Resume link not available yet!"),
                ),
              );
              return;
            }

            final Uri url = Uri.parse(resumeUrl);

            if (!await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
            )) {
              throw Exception("Could not launch $url");
            }
          },
          child: Padding(
            padding: ResponsiveUtils.paddingSymmetric(
              context,
              horizontal: 32,
              vertical: 16,
            ),
            child: Row(
              mainAxisSize: ResponsiveUtils.isMobile(context)
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: ResponsiveUtils.width(context, 20),
                ),
                ResponsiveUtils.horizontalSpace(context, 8),
                Text(
                  'Resume',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.fontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Profile / cube image
  // ---------------------------------------------------------------------------

  Widget _buildProfileImage(BuildContext context, String? photoUrl) {
    final imageSize = ResponsiveUtils.isMobile(context)
        ? 200.0
        : ResponsiveUtils.isTablet(context)
            ? 250.0
            : 300.0;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ResponsiveUtils.width(context, imageSize),
            height: ResponsiveUtils.width(context, imageSize),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                  ],
                ),
              ),
              child: ClipOval(
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0.0;
                    if (_pageController.hasClients) {
                      value = _pageController.page ?? 0.0;
                    }

                    return PageView(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        _buildCubeFace(
                          context: context,
                          pageValue: value,
                          index: 0,
                          child: (photoUrl != null && photoUrl.isNotEmpty)
                              ? Image.network(
                                  photoUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : const SizedBox(),
                        ),
                        _buildCubeFace(
                          context: context,
                          pageValue: value,
                          index: 1,
                          child: Lottie.asset(
                            'assets/animation/Hello pp.json',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            repeat: false,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.code,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          ResponsiveUtils.verticalSpace(context, 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF6366F1)
                      : Colors.grey[600]?.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCubeFace({
    required BuildContext context,
    required double pageValue,
    required int index,
    required Widget child,
  }) {
    final double isMoving = (index - pageValue);
    final double angle = isMoving * pi / 2;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        } else {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      },
      child: Transform(
        alignment: isMoving > 0 ? Alignment.centerLeft : Alignment.centerRight,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle),
        child: Container(
          color: const Color(0xFF0F172A),
          child: child,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Background code animation
// -----------------------------------------------------------------------------

class CodePainter extends CustomPainter {
  final double animationValue;

  static final List<CodeParticle> particles = [];

  final Random random = Random();

  CodePainter(this.animationValue) {
    if (particles.isEmpty) {
      for (int i = 0; i < 50; i++) {
        particles.add(CodeParticle());
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      double yPos = particle.y - (animationValue * particle.speed * 1.5);

      if (yPos < -0.1) yPos = (yPos % 1.0) + 1.0;

      final x = particle.x * size.width;
      final y = yPos * size.height;

      final textSpan = TextSpan(
        text: particle.char,
        style: TextStyle(
          color: particle.color.withOpacity(particle.opacity),
          fontSize: particle.size,
          fontFamily: 'Courier',
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CodeParticle {
  late double x;
  late double y;
  late double size;
  late double opacity;
  late double speed;
  late String char;
  late Color color;

  static final List<String> symbols = [
    "{",
    "}",
    "(",
    ")",
    "[",
    "]",
    "<",
    ">",
    "</>",
    "<<",
    ">>",
    "::",
    "=>",
    "->",
    "+",
    "-",
    "*",
    "/",
    "%",
    "=",
    "==",
    "===",
    "!=",
    "!==",
    ">",
    "<",
    ">=",
    "<=",
    "&&",
    "||",
    "!",
    "??",
    "?.",
    "+=",
    "-=",
    "*=",
    "/=",
    "%=",
    "<<=",
    ">>=",
    "&=",
    "|=",
    "^=",
    "@",
    "#",
    "^",
    "&",
    "*",
    "~",
    "`",
    "\\",
    "|",
    ":",
    ";",
    ",",
    ".",
    "...",
    "//",
    "/*",
    "*/",
    "0",
    "1",
    "x",
    "y",
    "z",
    "_",
    "var",
    "let",
    "const",
    "if",
    "else",
    "for",
    "while",
    "return",
    "true",
    "false",
    "null",
    "undefined",
    "async",
    "await",
    " ()",
    "{}",
    "<>",
    "{ ... }"
  ];

  static final List<Color> colors = [
    const Color(0xFF6366F1),
    const Color(0xFF10B981),
    const Color(0xFF3B82F6),
    Colors.white,
  ];

  CodeParticle() {
    reset();
  }

  void reset() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = random.nextDouble() * 15 + 10;
    opacity = random.nextDouble() * 0.5 + 0.1;
    speed = random.nextDouble() * 0.5 + 0.2;
    char = symbols[random.nextInt(symbols.length)];
    color = colors[random.nextInt(colors.length)];
  }
}
