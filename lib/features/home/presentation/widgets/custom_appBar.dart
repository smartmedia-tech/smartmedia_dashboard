import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smartmedia_campaign_manager/config/theme/theme_controller.dart';
import 'package:smartmedia_campaign_manager/features/auth/domain/usecases/auth_usecases.dart';
import 'package:smartmedia_campaign_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smartmedia_campaign_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:smartmedia_campaign_manager/features/auth/presentation/widgets/signup_dialog.dart';
import 'package:smartmedia_campaign_manager/features/auth/presentation/widgets/profile_dialog.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isMobile;
  final ThemeController themeController;

  const CustomAppBar({
    required this.isMobile,
    required this.themeController,
    super.key,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _themeIconAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _themeIconAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;
    const accentColor = Color(0xFF3E64FF);

    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 16 : 24,
          vertical: 8,
        ),
        child: Row(
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Image.asset('assets/smart.png', height: 45),
            ),

            // Date display
            if (!widget.isMobile && screenWidth > 800)
              Expanded(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.calendar,
                          size: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMM d, yyyy')
                              .format(DateTime.now()),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const Spacer(),

            // Search Bar (only for larger screens)
            if (!widget.isMobile && screenWidth > 1000)
              Container(
                width: 250,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? Colors.white38 : Colors.black38,
                      size: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),

            // Action Buttons
            Row(
              children: [
                // Notifications Button
                if (!widget.isMobile || screenWidth > 500)
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          FontAwesomeIcons.bell,
                          size: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1A1A2E)
                                    : Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Profile Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is Authenticated) {
                      final user = state.user;

                      return GestureDetector(
                        onTap: () => showProfileDialog(
                          context,
                          authUseCases: context.read<AuthUseCases>(),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: isDark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accentColor.withOpacity(0.2),
                                  image: user?.profileImage.isNotEmpty == true
                                      ? DecorationImage(
                                          image:
                                              NetworkImage(user!.profileImage),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: user?.profileImage.isEmpty ?? true
                                    ? const Center(
                                        child: Icon(
                                          FontAwesomeIcons.user,
                                          size: 14,
                                          color: accentColor,
                                        ),
                                      )
                                    : null,
                              ),
                              if (!widget.isMobile && screenWidth > 900) ...[
                                const SizedBox(width: 8),
                                Text(
                                  user?.firstName ?? 'User',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: () => showSignupDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: isDark
                              ? Colors.black.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor.withOpacity(0.2),
                              ),
                              child: const Center(
                                child: Icon(
                                  FontAwesomeIcons.user,
                                  size: 14,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            if (!widget.isMobile && screenWidth > 900) ...[
                              const SizedBox(width: 8),
                              Text(
                                'Sign Up',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 16),

                // Theme Toggle
                GestureDetector(
                  onTap: () {
                    widget.themeController.toggleTheme();
                    if (isDark) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.black.withOpacity(0.2)
                          : accentColor.withOpacity(0.1),
                    ),
                    child: AnimatedBuilder(
                      animation: _themeIconAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _themeIconAnimation.value * 2 * 3.14159,
                          child: Center(
                            child: Icon(
                              isDark ? Icons.light_mode : Icons.dark_mode,
                              size: 16,
                              color: isDark ? Colors.white70 : accentColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
