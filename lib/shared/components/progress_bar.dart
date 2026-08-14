import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Smooth animated progress bar with subtle gradient, rounded capsule, and a11y support
class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final Duration animationDuration;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 4.0,
    this.color,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Progress bar',
      value: '${(clampedProgress * 100).round()}%',
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isDark
                  ? AppColors.divider.withValues(alpha: 0.6)
                  : AppColors.divider.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: clampedProgress),
          duration: animationDuration,
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: animatedValue.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color ?? AppColors.primary,
                      color ?? AppColors.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: (color ?? AppColors.primaryLight)
                          .withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
