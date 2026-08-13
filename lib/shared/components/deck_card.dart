import 'package:flutter/material.dart';
import '../../core/models/deck.dart';
import '../theme/app_colors.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  final int dueCardsCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const DeckCard({
    super.key,
    required this.deck,
    required this.dueCardsCount,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = dueCardsCount == 0;

    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.name,
                      style: AppTypography.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deck.languageFront} → ${deck.languageBack}',
                      style: AppTypography.label,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.rateEasy,
                  size: 24,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dueCardsCount.toString(),
                    style: AppTypography.label.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
