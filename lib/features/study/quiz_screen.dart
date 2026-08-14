import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/deck.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/components/empty_state.dart';
import 'quiz_viewmodel.dart';

class QuizScreen extends StatefulWidget {
  final Deck deck;

  const QuizScreen({super.key, required this.deck});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizViewModel>().loadQuiz(widget.deck.id);
    });
  }

  void _onOptionSelected(String option) async {
    final quizVM = context.read<QuizViewModel>();
    if (quizVM.selectedOption != null) {
      if (mounted && quizVM.selectedOption != quizVM.correctOption) {
        _goToNextQuestion(quizVM);
      }
      return;
    }

    quizVM.answerQuestion(option);

    final isCorrect = option == quizVM.correctOption;

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 1100));
    } else {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 2200));
    }

    if (!mounted) return;

    if (quizVM.selectedOption != null) {
      _goToNextQuestion(quizVM);
    }
  }

  void _goToNextQuestion(QuizViewModel quizVM) {
    quizVM.nextQuestion();

    if (quizVM.isFinished && mounted) {
      context.pushReplacement('/session_result', extra: {
        'correctCount': quizVM.correctCount,
        'totalCount': quizVM.quizCards.length,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          label: 'Close quiz',
          child: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () => context.pop(),
          ),
        ),
        title: Consumer<QuizViewModel>(
          builder: (context, quizVM, _) {
            final total = quizVM.quizCards.length;
            final current =
                (quizVM.currentIndex + 1).clamp(1, total == 0 ? 1 : total);
            return Text(
              'Quiz $current / ${total == 0 ? 1 : total}',
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
          child: Consumer<QuizViewModel>(
            builder: (context, quizVM, _) {
              final progress = quizVM.quizCards.isEmpty
                  ? 0.0
                  : (quizVM.currentIndex / quizVM.quizCards.length);
              return LinearProgressIndicator(
                value: progress,
                minHeight: 3.5,
              );
            },
          ),
        ),
      ),
      body: Consumer<QuizViewModel>(
        builder: (context, quizVM, child) {
          if (quizVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final card = quizVM.currentCard;
          if (card == null) {
            return const EmptyState(
              message:
                  'Not enough cards to start a quiz.\nAdd at least 4 cards to this deck.',
              illustration: Icon(
                LucideIcons.target,
                size: 56,
                color: AppColors.primaryLight,
              ),
            );
          }

          return GestureDetector(
            onTap: () {
              if (quizVM.selectedOption != null &&
                  quizVM.selectedOption != quizVM.correctOption) {
                _goToNextQuestion(quizVM);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question Card
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 28),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.bgSurface
                              : AppColors.lightBgSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppColors.divider.withValues(alpha: 0.4)
                                : AppColors.divider.withValues(alpha: 0.15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.25 : 0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'SELECT CORRECT MEANING',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              card.front,
                              style: AppTypography.display.copyWith(
                                fontSize: 28,
                                color: isDark
                                    ? AppColors.textPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate(key: ValueKey('question_${card.id}'))
                      .fadeIn(duration: 300.ms)
                      .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic),
                  const SizedBox(height: 16),
                  // Choices List
                  Expanded(
                    flex: 3,
                    child: ListView.separated(
                      key: ValueKey('options_${card.id}'),
                      itemCount: quizVM.currentOptions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final option = quizVM.currentOptions[index];
                        return _buildChoiceButton(option, quizVM)
                            .animate()
                            .fadeIn(
                              duration: 250.ms,
                              delay: (index * 50).ms,
                            )
                            .slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 250.ms,
                              delay: (index * 50).ms,
                              curve: Curves.easeOutCubic,
                            );
                      },
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

  Widget _buildChoiceButton(String option, QuizViewModel quizVM) {
    final isSelected = quizVM.selectedOption == option;
    final isCorrect = option == quizVM.correctOption;
    final showFeedback = quizVM.selectedOption != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor =
        isDark ? AppColors.bgSurface : AppColors.lightBgSurface;
    Color borderColor = isDark
        ? AppColors.divider.withValues(alpha: 0.4)
        : AppColors.divider.withValues(alpha: 0.15);
    Widget? trailingIcon;

    if (showFeedback) {
      if (isCorrect) {
        backgroundColor = AppColors.rateEasy.withValues(alpha: 0.18);
        borderColor = AppColors.rateEasy;
        trailingIcon = const Icon(
          LucideIcons.checkCircle2,
          color: AppColors.rateEasy,
          size: 20,
        );
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.rateHard.withValues(alpha: 0.18);
        borderColor = AppColors.rateHard;
        trailingIcon = const Icon(
          LucideIcons.xCircle,
          color: AppColors.rateHard,
          size: 20,
        );
      }
    }

    return Semantics(
      label: 'Option: $option',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onOptionSelected(option),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: borderColor, width: isSelected ? 2.0 : 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: AppTypography.title.copyWith(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                if (trailingIcon != null) trailingIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
