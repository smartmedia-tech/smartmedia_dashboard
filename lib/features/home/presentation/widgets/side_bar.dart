import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmedia_campaign_manager/config/theme/theme_controller.dart';
import 'package:smartmedia_campaign_manager/core/utils/colors.dart';
import 'package:smartmedia_campaign_manager/features/auth/presentation/widgets/logout_button_widget.dart';

class SideBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isMobile;

  const SideBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isMobile = false,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin {
  bool isExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final menuItems = [
    {'title': 'Dashboard', 'icon': FontAwesomeIcons.gauge},
    {'title': 'Campaigns', 'icon': FontAwesomeIcons.bullhorn},
    {'title': 'Stores', 'icon': FontAwesomeIcons.store},
  
    {'title': 'Reports', 'icon': FontAwesomeIcons.chartLine},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    if (!isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.isDarkMode;

    return widget.isMobile
        ? _buildMobileDrawer(context, isDark)
        : _buildDesktopSidebar(isDark);
  }

  Widget _buildDesktopSidebar(bool isDark) {
    final bgColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    const accentColor = Color(0xFF3E64FF);
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final width =
            Tween<double>(begin: 220.0, end: 70.0).evaluate(_animation);

        return Container(
          width: width,
          decoration: BoxDecoration(
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          // Logo and toggle
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (isExpanded)
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.bolt,
                        color: Color(0xFF3E64FF),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'SmartMedia',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  )
                else
                  const Icon(
                    FontAwesomeIcons.bolt,
                    color: Color(0xFF3E64FF),
                    size: 20,
                  ),
                if (isExpanded)
                  IconButton(
                    onPressed: _toggleExpanded,
                    icon: AnimatedRotation(
                      turns: isExpanded ? 0 : 0.5,
                      duration: const Duration(milliseconds: 350),
                      child: const Icon(
                        Icons.keyboard_double_arrow_left,
                        color: Color(0xFF3E64FF),
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          AnimatedOpacity(
            opacity: isExpanded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(height: 1, thickness: 0.5),
            ),
          ),

          const SizedBox(height: 16),

          // Menu Items
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = widget.selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => widget.onItemSelected(index),
                      borderRadius: BorderRadius.circular(12),
                      splashColor: accentColor.withOpacity(0.1),
                      hoverColor: accentColor.withOpacity(0.05),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: isExpanded ? 16 : 0,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    accentColor.withOpacity(0.1),
                                    accentColor.withOpacity(0.05),
                                  ],
                                )
                              : null,
                          border: isSelected
                              ? Border.all(
                                  color: accentColor.withOpacity(0.3),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: isExpanded
                            ? Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? accentColor
                                          : accentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      item['icon'] as IconData?,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : accentColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['title'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? accentColor
                                            : textColor,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: accentColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              )
                            : Center(
                                child: Tooltip(
                                  message: item['title'] as String,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? accentColor
                                          : accentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      item['icon'] as IconData?,
                                      size: 16,
                                      color: isSelected
                                          ? AppColors.background
                                          : accentColor,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Toggle button when collapsed
          if (!isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: IconButton(
                onPressed: _toggleExpanded,
                icon: const Icon(
                  Icons.keyboard_double_arrow_right,
                  color: Color(0xFF3E64FF),
                  size: 20,
                ),
                tooltip: "Expand menu",
              ),
            ),

          // logout button - only visible when expanded
          if (isExpanded)
            const Padding(padding: EdgeInsets.all(6.0), child: LogOutButton()),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: AppColors.accentColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentColor,
                  AppColors.accentColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.bolt,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'SmartMedia',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = widget.selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onItemSelected(index);
                      },
                      borderRadius: BorderRadius.circular(12),
                      splashColor: AppColors.accentColor.withOpacity(0.1),
                      hoverColor: AppColors.accentColor.withOpacity(0.05),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    AppColors.accentColor.withOpacity(0.1),
                                    AppColors.accentColor.withOpacity(0.05),
                                  ],
                                )
                              : null,
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.accentColor.withOpacity(0.3),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accentColor
                                    : AppColors.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item['icon'] as IconData?,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.accentColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.accentColor
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(
                                Icons.circle,
                                size: 8,
                                color: AppColors.accentColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer with logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
            ),
            child: const Row(
              children: [LogOutButton()],
            ),
          ),
        ],
      ),
    );
  }
}
