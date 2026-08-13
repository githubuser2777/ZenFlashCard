import 'package:flutter/material.dart';
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
    String message = "Keep it up! 🌱";
    if (percentage >= 0.8) {
      message = "Excellent! 🎉";
    } else if (percentage >= 0.5) {
      message = "Good job! 💪";
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: const Text('Session Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: percentage,
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
            ),
            const SizedBox(height: 40),
            Text(message, style: AppTypography.headline),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppColors.rateEasy),
                const SizedBox(width: 8),
                Text('Correct: $correctCount', style: AppTypography.title),
                const SizedBox(width: 32),
                const Icon(Icons.cancel, color: AppColors.rateHard),
                const SizedBox(width: 8),
                Text('Incorrect: ${totalCount - correctCount}', style: AppTypography.title),
              ],
            ),
            const SizedBox(height: 60),
            ZenButton(
              label: 'Done',
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
