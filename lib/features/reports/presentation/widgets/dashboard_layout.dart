// lib/core/presentation/widgets/dashboard_layout.dart
import 'package:flutter/material.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;
  final String pageTitle; // Title for the current section of the dashboard

  const DashboardLayout({
    Key? key,
    required this.child,
    required this.pageTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Light background for the overall dashboard
      body: Row(
        children: [
          // --- Left Sidebar (Conceptual - can be a StatefulWidget with navigation) ---
          Container(
            width: 250, // Fixed width for sidebar
            color: Colors.white,
            child: Column(
              children: [
                // Logo/App Title
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.analytics_rounded,
                          color: Theme.of(context).primaryColor, size: 30),
                      const SizedBox(width: 8),
                      Text(
                        'SmartMedia',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    children: [
                      _buildSidebarItem(context, Icons.dashboard, 'Dashboard',
                          () {
                        /* navigate to dashboard home */
                      }, isActive: pageTitle == 'Dashboard'),
                      _buildSidebarItem(context, Icons.campaign, 'Campaigns',
                          () {
                        /* navigate to campaigns */
                      }, isActive: pageTitle == 'Campaigns'),
                      _buildSidebarItem(context, Icons.analytics, 'Reports',
                          () {
                        /* navigate to reports */
                      }, isActive: pageTitle.contains('Reports')),
                      _buildSidebarItem(context, Icons.store, 'Stores', () {
                        /* navigate to stores */
                      }, isActive: pageTitle == 'Stores'),
                      _buildSidebarItem(context, Icons.settings, 'Settings',
                          () {/* navigate to settings */}),
                    ],
                  ),
                ),
                const Divider(),
                _buildSidebarItem(context, Icons.logout, 'Logout', () {
                  /* handle logout */
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // --- Main Content Area ---
          Expanded(
            child: Column(
              children: [
                // Top Bar / Header for the current page
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pageTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      // Global search, user avatar, notifications etc.
                      Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.search,
                                  color: Color(0xFF666666)),
                              onPressed: () {}),
                          IconButton(
                              icon: const Icon(Icons.notifications,
                                  color: Color(0xFF666666)),
                              onPressed: () {}),
                          const SizedBox(width: 16),
                          const CircleAvatar(
                            backgroundColor:
                                Color(0xFF42A5F5), // Secondary blue
                            child: Text('JD',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(
                        24), // Global padding for main content
                    child: child, // This is where ReportsScreen will go
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap,
      {bool isActive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            isActive ? Theme.of(context).primaryColor : const Color(0xFF666666),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive
              ? Theme.of(context).primaryColor
              : const Color(0xFF333333),
        ),
      ),
      selected: isActive,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }
}
