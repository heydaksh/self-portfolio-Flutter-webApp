import 'dart:ui';

import 'package:flutter/material.dart';

class CustomNavbar extends StatefulWidget {
  final GlobalKey homeKey;
  final GlobalKey aboutKey;
  final GlobalKey projectsKey;
  final GlobalKey experienceKey;
  final GlobalKey contactKey;
  final Function(GlobalKey) onSectionTap;
  final bool isScrolled;
  final int currentSection;
  final Animation<double> animation;

  const CustomNavbar({
    super.key,
    required this.homeKey,
    required this.aboutKey,
    required this.projectsKey,
    required this.experienceKey,
    required this.contactKey,
    required this.onSectionTap,
    required this.isScrolled,
    required this.currentSection,
    required this.animation,
  });

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  // ---------------------------------------------------------------------------
  // Data
  // ---------------------------------------------------------------------------

  final List<String> _sections = [
    'Home',
    'About',
    'Projects',
    'Experience',
    'Contact'
  ];

  late final List<GlobalKey> _keys;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _keys = [
      widget.homeKey,
      widget.aboutKey,
      widget.projectsKey,
      widget.experienceKey,
      widget.contactKey,
    ];
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 80,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.isScrolled ? 10 : 0,
            sigmaY: widget.isScrolled ? 10 : 0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: widget.isScrolled
                  ? Colors.white.withOpacity(0.8)
                  : Colors.transparent,
              border: widget.isScrolled
                  ? Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildLogo(),
                    const Spacer(),
                    if (isDesktop) ..._buildDesktopNavItems(),
                    if (!isDesktop) _buildMobileMenuButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  Widget _buildLogo() {
    return GestureDetector(
      onTap: () => widget.onSectionTap(widget.homeKey),
      child: AnimatedContainer(
        height: 40,
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6366F1), // Indigo
              Color(0xFF10B981), // Green (Coding theme)
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: widget.isScrolled
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: const Text(
          'D. S',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDesktopNavItems() {
    return _sections.asMap().entries.map((entry) {
      final index = entry.key;
      final section = entry.value;
      final isActive = widget.currentSection == index;

      return Padding(
        padding: const EdgeInsets.only(left: 32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: TextButton(
            onPressed: () => widget.onSectionTap(_keys[index]),
            style: TextButton.styleFrom(
              foregroundColor:
                  isActive ? const Color(0xFF6366F1) : Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  section,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: -0.25,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 2,
                  width: isActive ? 20 : 0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMobileMenuButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: IconButton(
        onPressed: _showMobileMenu,
        icon: const Icon(Icons.menu_rounded),
        color: widget.isScrolled ? Colors.grey[800] : Colors.white,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile menu
  // ---------------------------------------------------------------------------

  void _showMobileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ..._sections.asMap().entries.map((entry) {
                final index = entry.key;
                final section = entry.value;

                return ListTile(
                  title: Text(
                    section,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSectionTap(_keys[index]);
                  },
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6366F1),
                          Color(0xFF8B5CF6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIconForSection(index),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  IconData _getIconForSection(int index) {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.person_rounded;
      case 2:
        return Icons.work_rounded;
      case 3:
        return Icons.timeline_rounded;
      case 4:
        return Icons.contact_mail_rounded;
      default:
        return Icons.circle;
    }
  }
}
