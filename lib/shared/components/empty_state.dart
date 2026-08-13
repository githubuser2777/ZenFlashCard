import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final Widget? illustration;

  const EmptyState({
    super.key,
    required this.message,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (illustration != null)
            illustration!
          else
            const Icon(Icons.menu_book, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
