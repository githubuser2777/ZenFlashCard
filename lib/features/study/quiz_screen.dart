import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/models/deck.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/components/progress_bar.dart';
import 'quiz_viewmodel.dart';
import 'session_result_screen.dart';

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
      // If already selected and waiting, tapping again forces next question (Tap to continue)
      if (mounted && quizVM.selectedOption != quizVM.correctOption) {
        _goToNextQuestion(quizVM);
      }
      return;
    }

    quizVM.answerQuestion(option);

    final isCorrect = option == quizVM.correctOption;

    if (isCorrect) {
      HapticFeedback.mediumImpact();
      // Auto-advance after 1.2s
      await Future.delayed(const Duration(milliseconds: 1200));
    } else {
      HapticFeedback.heavyImpact();
      // Auto-advance after 2.5s or manual tap
      await Future.delayed(const Duration(milliseconds: 2500));
    }

    if (!mounted) return;
    
    // Check if we are still on the same question (meaning user hasn't manually tapped)
    if (quizVM.selectedOption != null) {
      _goToNextQuestion(quizVM);
    }
  }

  void _goToNextQuestion(QuizViewModel quizVM) {
    quizVM.nextQuestion();

    if (quizVM.isFinished && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionResultScreen(
            correctCount: quizVM.correctCount,
            totalCount: quizVM.quizCards.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          label: 'Close quiz',
          child: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Consumer<QuizViewModel>(
          builder: (context, quizVM, _) {
            final total = quizVM.quizCards.length;
            final current = quizVM.currentIndex + 1;
            return Text('Quiz $current / ${total == 0 ? 1 : total}', style: const TextStyle(fontSize: 16));
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Consumer<QuizViewModel>(
            builder: (context, quizVM, _) {
              final progress = quizVM.quizCards.isEmpty ? 0.0 : quizVM.currentIndex / quizVM.quizCards.length;
              return ProgressBar(progress: progress);
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
            return const Center(child: Text('Not enough cards for a quiz.'));
          }

          return GestureDetector(
            // Tap anywhere to continue if answered incorrectly
            onTap: () {
              if (quizVM.selectedOption != null && quizVM.selectedOption != quizVM.correctOption) {
                _goToNextQuestion(quizVM);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Select the correct meaning',
                              style: AppTypography.label.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              card.front,
                              style: AppTypography.display,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 2,
                    child: ListView.separated(
                      itemCount: quizVM.currentOptions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final option = quizVM.currentOptions[index];
                        return _buildChoiceButton(option, quizVM);
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

    Color backgroundColor = AppColors.bgSurface;
    Color borderColor = AppColors.divider;
    Widget? trailingIcon;

    if (showFeedback) {
      if (isCorrect) {
        backgroundColor = AppColors.rateEasy.withValues(alpha: 0.2);
        borderColor = AppColors.rateEasy;
        trailingIcon = const Icon(LucideIcons.checkCircle2, color: AppColors.rateEasy);
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.rateHard.withValues(alpha: 0.2);
        borderColor = AppColors.rateHard;
        trailingIcon = const Icon(LucideIcons.xCircle, color: AppColors.rateHard);
      }
    }

    return Semantics(
      label: 'Option: $option',
      button: true,
      child: InkWell(
        onTap: () => _onOptionSelected(option),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48), // A11y touch target
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: AppTypography.title.copyWith(color: AppColors.textPrimary),
                ),
              ),
              if (trailingIcon != null) trailingIcon,
            ],
          ),
        ),
      ),
    );
  }
}
