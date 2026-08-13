import 'package:flutter/material.dart';
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
    if (quizVM.selectedOption != null) return;

    quizVM.answerQuestion(option);

    // Auto-advance after 1.2s
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    
    quizVM.nextQuestion();

    if (quizVM.isFinished) {
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
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
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

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select the correct meaning',
                          style: AppTypography.label,
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
        backgroundColor = AppColors.rateEasy.withOpacity(0.2);
        borderColor = AppColors.rateEasy;
        trailingIcon = const Icon(Icons.check, color: AppColors.rateEasy);
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.rateHard.withOpacity(0.2);
        borderColor = AppColors.rateHard;
        trailingIcon = const Icon(Icons.close, color: AppColors.rateHard);
      }
    }

    return InkWell(
      onTap: () => _onOptionSelected(option),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
    );
  }
}
