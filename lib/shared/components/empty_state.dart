import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';

/// Animated empty state with subtle floating icon and clear guidance
class EmptyState extends StatelessWidget {
  final String message;
  final Widget? illustration;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.message,
    this.illustration,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.bgSurface.withValues(alpha: 0.6)
                    : AppColors.lightBgSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.2),
                ),
              ),
              child: illustration ??
                  const Icon(
                    LucideIcons.bookOpen,
                    size: 56,
                    color: AppColors.primaryLight,
                  ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .slideY(
                    begin: 0,
                    end: -0.08,
                    duration: 2200.ms,
                    curve: Curves.easeInOutSine),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!.animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}
