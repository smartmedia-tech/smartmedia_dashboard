
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartmedia_campaign_manager/config/theme/theme_controller.dart';

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

class _SideBarState extends State<SideBar> {
  bool isExpanded = false;

  final menuItems = [
    {'title': 'Dashboard', 'icon': FontAwesomeIcons.tachometerAlt},
    {'title': 'Merchants', 'icon': FontAwesomeIcons.store},
    {'title': 'Orders', 'icon': FontAwesomeIcons.boxOpen},
    {'title': 'Categories', 'icon': FontAwesomeIcons.thList},
    {'title': 'Brands', 'icon': FontAwesomeIcons.tags},
    {'title': ' Drink Requests', 'icon': FontAwesomeIcons.clipboardList},
    {'title': 'Products', 'icon': FontAwesomeIcons.productHunt},
    {'title': 'Promotions', 'icon': FontAwesomeIcons.productHunt},
  ];

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    return widget.isMobile
        ? _buildMobileDrawer(context, isDarkMode)
        : _buildDesktopSidebar(isDarkMode, themeController);
  }

  Widget _buildDesktopSidebar(
      bool isDarkMode, ThemeController themeController) {
    return MouseRegion(
      onEnter: (_) => setState(() => isExpanded = true),
      onExit: (_) => setState(() => isExpanded = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isExpanded ? 250 : 70,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black12 : Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
              offset: Offset(2, 0),
            )
          ],
        ),
        child: Column(
          children: [
            _buildToggleButton(isDarkMode),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: menuItems.asMap().entries.map((entry) {
                  return _buildAnimatedListTile(
                      entry.key, entry.value, isDarkMode);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 40,
      width: isExpanded ? 200 : 40,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isExpanded ? 10 : 20),
      ),
      child: IconButton(
        icon: FaIcon(
          isExpanded
              ? FontAwesomeIcons.chevronLeft
              : FontAwesomeIcons.chevronRight,
          color: Colors.red,
        ),
        onPressed: () => setState(() => isExpanded = !isExpanded),
      ),
    );
  }

  Widget _buildAnimatedListTile(
      int idx, Map<String, dynamic> item, bool isDarkMode) {
    final isSelected = widget.selectedIndex == idx;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isExpanded ? 16 : 8,
          vertical: 0,
        ),
        leading: FaIcon(
          item['icon'],
          color: isSelected
              ? Colors.red
              : (isDarkMode ? Colors.white70 : Colors.black87),
          size: 22,
        ),
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isExpanded ? 1.0 : 0.0,
          child: isExpanded
              ? Text(
                  item['title'],
                  style: GoogleFonts.poppins(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.red
                        : (isDarkMode ? Colors.white70 : Colors.black87),
                  ),
                )
              : null,
        ),
        onTap: () => widget.onItemSelected(idx),
        selected: isSelected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        selectedTileColor: Colors.red.withOpacity(0.1),
        hoverColor: Colors.grey.withOpacity(0.1),
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context, bool isDarkMode) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.red,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(
                  FontAwesomeIcons.userShield,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin Panel',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...menuItems.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isSelected = widget.selectedIndex == idx;

            return ListTile(
              leading: FaIcon(
                item['icon'] as IconData,
                color: isSelected
                    ? Colors.red
                    : (isDarkMode ? Colors.white70 : Colors.black87),
              ),
              title: Text(
                item['title'] as String,
                style: GoogleFonts.poppins(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.red
                      : (isDarkMode ? Colors.white70 : Colors.black87),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onItemSelected(idx);
              },
              selected: isSelected,
              selectedTileColor: Colors.red.withOpacity(0.1),
            );
          }),
          // _buildThemeSwitch(
          //     Provider.of<ThemeController>(context, listen: false), isDarkMode),
        ],
      ),
    );
  }
}
