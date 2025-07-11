import 'package:smartmedia_campaign_manager/config/theme/theme_controller.dart';
import 'package:smartmedia_campaign_manager/core/utils/colors.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/pages/campaigns_screen.dart';
import 'package:smartmedia_campaign_manager/features/home/presentation/widgets/custom_appBar.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmedia_campaign_manager/features/home/presentation/pages/dashBoard-screen.dart';
import 'package:smartmedia_campaign_manager/features/home/presentation/widgets/side_bar.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/pages/reports_screen.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/pages/stores_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CampaignScreen(),
    const StoresScreen(),
    const ReportsScreen(),
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(
        isMobile: isMobile,
        themeController: themeController,
      ),
      drawer: isMobile
          ? SideBar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemSelected,
              isMobile: true,
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SideBar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemSelected,
            ),
          Expanded(
            child: Container(
              color: themeController.isDarkMode
                  ? AppColors.surfaceDark
                  : AppColors.surface,
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
