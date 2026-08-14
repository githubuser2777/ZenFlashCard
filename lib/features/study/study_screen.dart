import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/deck.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/components/progress_bar.dart';
import '../../shared/components/flip_card_3d.dart';
import '../../shared/components/empty_state.dart';
import 'study_viewmodel.dart';
import '../deck/deck_viewmodel.dart';

class StudyScreen extends StatefulWidget {
  final Deck deck;

  const StudyScreen({super.key, required this.deck});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  bool _isBackSide = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyViewModel>().loadDueCards(widget.deck.id);
    });
  }

  void _onRate(int quality) async {
    final studyVM = context.read<StudyViewModel>();
    HapticFeedback.lightImpact();

    await studyVM.answerCard(quality);

    if (mounted) {
      context.read<DeckViewModel>().loadDecks();
    }

    setState(() {
      _isBackSide = false;
    });

    if (studyVM.isFinished && mounted) {
      context.pushReplacement('/session_result', extra: {
        'correctCount': studyVM.correctCount,
        'totalCount': studyVM.studiedCount,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          label: 'Close study session',
          child: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () => context.pop(),
          ),
        ),
        title: Consumer<StudyViewModel>(
          builder: (context, studyVM, _) {
            final total = studyVM.dueCards.length;
            final current =
                (studyVM.currentIndex + 1).clamp(1, total == 0 ? 1 : total);
            return Text(
              '$current / ${total == 0 ? 1 : total}',
              style: AppTypography.title.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ),
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Consumer<StudyViewModel>(
            builder: (context, studyVM, _) {
              final progress = studyVM.dueCards.isEmpty
                  ? 0.0
                  : (studyVM.currentIndex / studyVM.dueCards.length);
              return ProgressBar(
                progress: progress,
                height: 3.5,
              );
            },
          ),
        ),
      ),
      body: Consumer<StudyViewModel>(
        builder: (context, studyVM, child) {
          if (studyVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final card = studyVM.currentCard;
          if (card == null) {
            return const EmptyState(
              message:
                  "You're all caught up!\nNo cards due for review right now.",
              illustration: Icon(
                LucideIcons.partyPopper,
                size: 56,
                color: AppColors.rateEasy,
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.95, end: 1.0)
                                .animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: FlipCard3D(
                        key: ValueKey(card.id),
                        onFlip: (isBack) {
                          setState(() {
                            _isBackSide = isBack;
                          });
                        },
                        front: _buildCardSide(
                          card.front,
                          widget.deck.languageFront,
                          isFront: true,
                        ),
                        back: _buildCardSide(
                          card.back,
                          widget.deck.languageBack,
                          isFront: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Rating Action Area
                  SizedBox(
                    height: 64,
                    child: AnimatedOpacity(
                      opacity: _isBackSide ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: IgnorePointer(
                        ignoring: !_isBackSide,
                        child: AnimatedSlide(
                          offset:
                              _isBackSide ? Offset.zero : const Offset(0, 0.3),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildRatingBtn(
                                  label: 'Hard',
                                  subtitle: 'Reset',
                                  color: AppColors.rateHard,
                                  onTap: () => _onRate(0),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildRatingBtn(
                                  label: 'OK',
                                  subtitle: 'Good',
                                  color: AppColors.rateOk,
                                  onTap: () => _onRate(3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildRatingBtn(
                                  label: 'Easy',
                                  subtitle: 'Mastered',
                                  color: AppColors.rateEasy,
                                  onTap: () => _onRate(5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardSide(String text, String lang, {required bool isFront}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurface : AppColors.lightBgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.divider.withValues(alpha: 0.4)
              : AppColors.divider.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              lang.toUpperCase(),
              style: AppTypography.label.copyWith(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
            ),
          ),
          const Spacer(),
          Text(
            text,
            textAlign: TextAlign.center,
            style: isFront
                ? AppTypography.display.copyWith(
                    fontSize: 28,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                  )
                : AppTypography.headline.copyWith(
                    fontSize: 22,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                  ),
          ),
          const Spacer(),
          if (isFront && !_isBackSide)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.pointer,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Tap to flip',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRatingBtn({
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: 'Rate $label ($subtitle)',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.45),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.label.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
