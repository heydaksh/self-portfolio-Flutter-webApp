import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/responsive_utils.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  int selectedCategory = 0;
  final List<String> categories = ['All', 'Mobile', 'Web'];

  // [FIX] Declare stream variable
  late Stream<QuerySnapshot> _projectsStream;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // [FIX] Initialize stream once
    _projectsStream = FirebaseFirestore.instance
        .collection('projects')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: ResponsiveUtils.sectionPadding(context),
        child: Column(
          children: [
            _buildSectionHeader(context),
            ResponsiveUtils.verticalSpace(
              context,
              ResponsiveUtils.isDesktop(context) ? 50 : 40,
            ),
            _buildCategoryFilter(context),
            ResponsiveUtils.verticalSpace(
              context,
              ResponsiveUtils.isDesktop(context) ? 50 : 40,
            ),
            _buildProjectsGrid(context),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header & Filters
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 768 && size.width <= 1024;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Text(
            'My Work',
            style: TextStyle(
              color: Color(0xFF6366F1),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Featured Projects',
          style: TextStyle(
            fontSize: isDesktop ? 36 : (isTablet ? 28 : 24),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : double.infinity,
          ),
          child: Text(
            'A collection of projects that showcase my skills and passion for development',
            style: TextStyle(
              fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
              color: Colors.grey[600],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(categories.length, (index) {
            final isSelected = selectedCategory == index;

            return GestureDetector(
              onTap: () => setState(() => selectedCategory = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(
                  right: index < categories.length - 1 ? 12 : 0,
                  left: index == 0 ? (isMobile ? 16 : 0) : 0,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF6366F1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Grid
  // ---------------------------------------------------------------------------

  Widget _buildProjectsGrid(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _projectsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No projects added yet. Go to Admin Dashboard to add one!",
            ),
          );
        }

        final allProjects = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Project.fromMap(data);
        }).toList();

        final filteredProjects = selectedCategory == 0
            ? allProjects
            : allProjects
                .where((p) => p.category == categories[selectedCategory])
                .toList();

        if (filteredProjects.isEmpty) {
          return const Center(child: Text("No projects in this category."));
        }

        final width = MediaQuery.of(context).size.width;

        int crossAxisCount;
        double crossAxisSpacing;
        double mainAxisSpacing;
        double mainAxisExtent;

        if (width >= 1200) {
          crossAxisCount = 3;
          crossAxisSpacing = 32;
          mainAxisSpacing = 32;
          mainAxisExtent = 560;
        } else if (width >= 1024) {
          crossAxisCount = 2;
          crossAxisSpacing = 24;
          mainAxisSpacing = 28;
          mainAxisExtent = 560;
        } else if (width >= 768) {
          crossAxisCount = 2;
          crossAxisSpacing = 20;
          mainAxisSpacing = 26;
          mainAxisExtent = 560;
        } else {
          crossAxisCount = 1;
          crossAxisSpacing = 16;
          mainAxisSpacing = 28;
          mainAxisExtent = 600;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            mainAxisExtent: mainAxisExtent,
          ),
          itemCount: filteredProjects.length,
          itemBuilder: (context, index) {
            return ProjectCard(project: filteredProjects[index]);
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Models
// -----------------------------------------------------------------------------

class Project {
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final List<String> technologies;
  final String githubUrl;
  final String liveUrl;
  final Color color;

  Project({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.technologies,
    required this.githubUrl,
    required this.liveUrl,
    required this.color,
  });

  factory Project.fromMap(Map<String, dynamic> data) {
    Color parseColor(String? hexString) {
      if (hexString == null || hexString.isEmpty) {
        return const Color(0xFF6366F1);
      }
      try {
        final buffer = StringBuffer();
        if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
        buffer.write(hexString.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      } catch (e) {
        return const Color(0xFF6366F1);
      }
    }

    return Project(
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'Mobile',
      technologies: List<String>.from(data['technologies'] ?? []),
      githubUrl: data['githubUrl'] ?? '',
      liveUrl: data['liveUrl'] ?? '',
      color: parseColor(data['color']),
    );
  }
}

// -----------------------------------------------------------------------------
// Card
// -----------------------------------------------------------------------------

class ProjectCard extends StatefulWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  bool _isHovered = false;
  late ScrollController _scrollController;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;

    final double verticalGap = isMobile ? size.height / 55 : size.height / 70;

    return GestureDetector(
      onTapDown: (_) {
        if (isMobile) setState(() => _isHovered = true);
      },
      onTapUp: (_) {
        if (isMobile) setState(() => _isHovered = false);
      },
      onTapCancel: () {
        if (isMobile) setState(() => _isHovered = false);
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.02 : 1.0)
            ..translate(0.0, _isHovered ? -5.0 : 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.project.color.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: _isHovered ? 25 : 30,
                offset: Offset(0, _isHovered ? 20 : 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          color: Colors.grey[100],
                          child: AnimatedScale(
                            scale: _isHovered ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            child: _buildProjectImage(
                              widget.project.imageUrl,
                              isMobile,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 8 : 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.project.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 18 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.project.title,
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 18,
                            fontWeight: FontWeight.bold,
                            color: _isHovered
                                ? widget.project.color
                                : const Color(0xFF1E293B),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: verticalGap),
                        Expanded(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                                thumbColor: MaterialStateProperty.all(
                                  widget.project.color.withOpacity(0.3),
                                ),
                                thickness: MaterialStateProperty.all(4),
                                radius: const Radius.circular(10),
                              ),
                            ),
                            child: Scrollbar(
                              controller: _scrollController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    widget.project.description,
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                      color: Colors.grey[600],
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: verticalGap),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                widget.project.technologies.take(5).map((tech) {
                              return Container(
                                margin: EdgeInsets.only(
                                  right: size.width / 90,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 6 : 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.project.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tech,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: widget.project.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: verticalGap),
                        SizedBox(
                          width: double.infinity,
                          height: isMobile ? 45 : 46,
                          child: _buildActionButton(
                            'Source Code',
                            Icons.code,
                            widget.project.color,
                            () async {
                              if (widget.project.githubUrl.isEmpty) {
                                return;
                              }

                              final Uri url =
                                  Uri.parse(widget.project.githubUrl);

                              if (!await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              )) {
                                throw 'Could not launch $url';
                              }
                            },
                            isMobile,
                          ),
                        ),
                        SizedBox(height: verticalGap),
                        SizedBox(
                          width: double.infinity,
                          height: isMobile ? 45 : 46,
                          child: _buildActionButton(
                            'Live Link',
                            Icons.mobile_screen_share_rounded,
                            widget.project.color,
                            () async {
                              if (widget.project.liveUrl.isEmpty) {
                                return;
                              }

                              final Uri url = Uri.parse(widget.project.liveUrl);

                              if (!await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              )) {
                                throw 'Could not launch $url';
                              }
                            },
                            isMobile,
                          ),
                        ),
                      ],
                    ),
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
  // Helpers
  // ---------------------------------------------------------------------------

  Widget _buildProjectImage(String imageUrl, bool isMobile) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _errorPlaceholder(isMobile),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _errorPlaceholder(isMobile),
      );
    }
  }

  Widget _errorPlaceholder(bool isMobile) {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.image_not_supported,
        size: isMobile ? 40 : 60,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    Future<void> Function()? onTap,
    bool isMobile,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _isHovered ? Colors.white : color,
              size: isMobile ? 14 : 16,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: _isHovered ? Colors.white : color,
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
