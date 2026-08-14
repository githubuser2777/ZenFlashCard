import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/models/deck.dart';
import '../theme/app_colors.dart';

/// Interactive deck card with tactile spring touch feedback and clear due-badge
class DeckCard extends StatefulWidget {
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
  State<DeckCard> createState() => _DeckCardState();
}

class _DeckCardState extends State<DeckCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = widget.dueCardsCount == 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: '${widget.deck.name} deck, ${widget.dueCardsCount} cards due',
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onTapCancel: () => _scaleController.reverse(),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          widget.onLongPress();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgSurface : AppColors.lightBgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.divider.withValues(alpha: 0.4)
                    : AppColors.divider.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon indicator
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.bookMarked,
                      color: AppColors.primaryLight,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Deck Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.deck.name,
                          style: AppTypography.title.copyWith(
                            color: isDark
                                ? AppColors.textPrimary
                                : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${widget.deck.languageFront.toUpperCase()} → ${widget.deck.languageBack.toUpperCase()}',
                              style: AppTypography.label.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Due Status Indicator
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.rateEasy.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.checkCheck,
                        color: AppColors.rateEasy,
                        size: 20,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.dueCardsCount.toString(),
                        style: AppTypography.label.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
