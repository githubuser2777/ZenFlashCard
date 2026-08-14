import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Progress',
      value: '${(progress * 100).round()}%',
      child: Container(
        height: 4,
        width: double.infinity,
        color: AppColors.divider,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: constraints.maxWidth * progress,
                  height: 4,
                  color: AppColors.primary,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
