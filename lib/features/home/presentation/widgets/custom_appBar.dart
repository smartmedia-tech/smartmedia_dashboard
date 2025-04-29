import 'package:smartmedia_campaign_manager/config/theme/theme_controller.dart';
import 'package:smartmedia_campaign_manager/features/auth/domain/usecases/auth_usecases.dart';
import 'package:smartmedia_campaign_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smartmedia_campaign_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:smartmedia_campaign_manager/features/auth/presentation/widgets/signUp_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/widgets/profile_dialog.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;
  final ThemeController themeController;

  const CustomAppBar({
    required this.isMobile,
    required this.themeController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 2,
      backgroundColor:
          themeController.isDarkMode ? Colors.grey[900] : Colors.white,
      title: Row(
        children: [
          if (isMobile) ...[
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFE74C3C), Color(0xFFF39C12)],
              ).createShader(bounds),
              child: Text(
                'AlkoHut Admin',
                style: GoogleFonts.acme(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ] else ...[
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFE74C3C), Color(0xFFF39C12)],
              ).createShader(bounds),
              child: Text(
                'AlkoHut Admin',
                style: GoogleFonts.acme(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (!isMobile)
            Flexible(
              child: Text(
                DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                style: TextStyle(
                  color:
                      themeController.isDarkMode ? Colors.white : Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      actions: [
        // Profile Button
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                final user = state.user;

                return GestureDetector(
                  onTap: () => showProfileDialog(context,
                      authUseCases: context.read<AuthUseCases>()),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        backgroundImage: user?.profileImage.isNotEmpty == true
                            ? NetworkImage(user!.profileImage)
                            : null,
                        child: user?.profileImage.isEmpty ?? true
                            ? Icon(
                                Icons.person_outline,
                                color: themeController.isDarkMode
                                    ? Colors.white
                                    : Colors.red,
                              )
                            : null,
                      ),
                      if (!isMobile) const SizedBox(width: 8),
                      if (!isMobile)
                        Text(
                          user?.firstName ?? 'User',
                          style: GoogleFonts.tangerine(
                            fontSize: 25,
                            color: themeController.isDarkMode
                                ? Colors.grey
                                : Colors.grey.shade700,
                          ),
                        ),
                      if (!isMobile) const SizedBox(width: 4),
                      if (!isMobile)
                        Icon(
                          Icons.arrow_drop_down,
                          color: themeController.isDarkMode
                              ? Colors.grey
                              : Colors.grey.shade700,
                        ),
                    ],
                  ),
                );
              }

              return GestureDetector(
                onTap: () => showSignupDialog(context),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: Icon(
                        Icons.person_outline,
                        color: themeController.isDarkMode
                            ? Colors.white
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        color: themeController.isDarkMode
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: themeController.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Theme Toggle Button with Animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: themeController.isDarkMode
                ? Colors.grey[800]?.withOpacity(0.5)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return RotationTransition(
                  turns: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: themeController.isDarkMode
                  ? const Icon(
                      Icons.dark_mode_rounded,
                      key: ValueKey('dark'),
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.light_mode_rounded,
                      key: ValueKey('light'),
                      color: Colors.orange,
                    ),
            ),
            onPressed: themeController.toggleTheme,
            tooltip: themeController.isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
