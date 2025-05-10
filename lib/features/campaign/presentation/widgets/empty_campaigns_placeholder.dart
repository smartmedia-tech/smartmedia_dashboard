// empty_campaigns_placeholder.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmptyCampaignsPlaceholder extends StatelessWidget {
  final double iconSize;
  final String title;
  final String subtitle;
  final bool showFloatingBells;

  const EmptyCampaignsPlaceholder({
    super.key,
    this.iconSize = 70,
    this.title = 'No campaigns created yet',
    this.subtitle = 'Create your first campaign using the button below',
    this.showFloatingBells = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        if (showFloatingBells) ...[
          // Floating bell icons for decoration
          for (int i = 0; i < 8; i++)
            _buildFloatingBell(context, i, isDarkMode),
        ],

        // Centered content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimatedImage(context),
              const SizedBox(height: 16),
              _buildAnimatedText(
                context,
                text: title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              _buildAnimatedText(
                context,
                text: subtitle,
                style: TextStyle(color: Colors.grey[500]),
                delay: 200,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBell(BuildContext context, int index, bool isDarkMode) {
    final isSmall = index % 2 == 0;
    final xOffset = (index * 25 - 120).toDouble();
    final startY = index * 35 - 180.0;

    return Positioned(
      left: MediaQuery.of(context).size.width / 2 + xOffset,
      top: startY,
      child: _AnimatedBellIcon(
        isDarkMode: isDarkMode,
        isSmall: isSmall,
        index: index,
      ),
    );
  }

  Widget _buildAnimatedImage(BuildContext context) {
    return FaIcon(
      FontAwesomeIcons.bullhorn,
      size: iconSize,
      color: Colors.grey[400],
    )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.elasticOut,
        )
        .shake(
          hz: 2,
          delay: 300.ms,
        );
  }

  Widget _buildAnimatedText(
    BuildContext context, {
    required String text,
    required TextStyle? style,
    int delay = 0,
  }) {
    return Text(text, style: style)
        .animate()
        .fadeIn(duration: 600.ms, delay: Duration(milliseconds: delay))
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.elasticOut,
        );
  }
}

class _AnimatedBellIcon extends StatelessWidget {
  final bool isDarkMode;
  final bool isSmall;
  final int index;

  const _AnimatedBellIcon({
    required this.isDarkMode,
    required this.isSmall,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      FontAwesomeIcons.solidBell,
      color: isDarkMode
          ? Colors.cyan.withOpacity(0.5 + (index % 5) * 0.1)
          : Colors.cyan.withOpacity(0.5 + (index % 5) * 0.1),
      size: isSmall ? 16.0 : 24.0,
    )
        .animate(onPlay: (controller) => controller.repeat())
        .moveY(
          begin: 0,
          end: 500,
          duration: Duration(seconds: isSmall ? 6 + index % 4 : 8 + index % 5),
          curve: Curves.easeInOut,
        )
        .fadeIn(duration: 600.ms)
        .then()
        .fadeOut(
          begin: 0.7,
          delay: Duration(seconds: isSmall ? 5 + index % 3 : 7 + index % 4),
        );
  }
}
