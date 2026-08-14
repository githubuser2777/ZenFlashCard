import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/components/zen_button.dart';

class SessionResultScreen extends StatelessWidget {
  final int correctCount;
  final int totalCount;

  const SessionResultScreen({
    super.key,
    required this.correctCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = totalCount == 0 ? 0 : (correctCount / totalCount);

    String message = "Keep it up!";
    IconData messageIcon = LucideIcons.sprout;
    if (percentage >= 0.8) {
      message = "Excellent!";
      messageIcon = LucideIcons.partyPopper;
    } else if (percentage >= 0.5) {
      message = "Good job!";
      messageIcon = LucideIcons.dumbbell;
    }

    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          label: 'Close result',
          child: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () => context.go('/'),
          ),
        ),
        title: const Text('Session Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: percentage),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 16,
                        backgroundColor: AppColors.divider,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '$correctCount / $totalCount',
                      style: AppTypography.display,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(message, style: AppTypography.headline),
                const SizedBox(width: 12),
                Icon(messageIcon, color: AppColors.textPrimary, size: 28),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.checkCircle2, color: AppColors.rateEasy),
                const SizedBox(width: 8),
                Text('Correct: $correctCount',
                    style: AppTypography.title
                        .copyWith(color: AppColors.rateEasy)),
                const SizedBox(width: 32),
                const Icon(LucideIcons.xCircle, color: AppColors.rateHard),
                const SizedBox(width: 8),
                Text('Incorrect: ${totalCount - correctCount}',
                    style: AppTypography.title
                        .copyWith(color: AppColors.rateHard)),
              ],
            ),
            const SizedBox(height: 60),
            ZenButton(
              label: 'Done',
              onPressed: () {
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
