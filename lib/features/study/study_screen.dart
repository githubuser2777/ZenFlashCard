import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/models/deck.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/components/progress_bar.dart';
import '../../shared/components/flip_card_3d.dart';
import 'study_viewmodel.dart';
import '../deck/deck_viewmodel.dart';
import 'session_result_screen.dart';

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
    await studyVM.answerCard(quality);
    
    // Refresh deck counts
    if (mounted) {
      context.read<DeckViewModel>().loadDecks();
    }
    
    setState(() {
      _isBackSide = false;
    });

    if (studyVM.isFinished && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionResultScreen(
            correctCount: studyVM.correctCount,
            totalCount: studyVM.studiedCount,
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
          label: 'Close study session',
          child: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Consumer<StudyViewModel>(
          builder: (context, studyVM, _) {
            final total = studyVM.dueCards.length;
            final current = studyVM.currentIndex + 1;
            return Text('$current / ${total == 0 ? 1 : total}', style: const TextStyle(fontSize: 16));
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Consumer<StudyViewModel>(
            builder: (context, studyVM, _) {
              final progress = studyVM.dueCards.isEmpty ? 0.0 : studyVM.currentIndex / studyVM.dueCards.length;
              return ProgressBar(progress: progress);
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
            return const Center(child: Text('Session completed! 🎉'));
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: FlipCard3D(
                    key: ValueKey(card.id),
                    onFlip: (isBack) {
                      setState(() {
                        _isBackSide = isBack;
                      });
                    },
                    front: _buildCardSide(card.front, widget.deck.languageFront, isFront: true),
                    back: _buildCardSide(card.back, widget.deck.languageBack, isFront: false),
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  flex: 1,
                  child: AnimatedOpacity(
                    opacity: _isBackSide ? 1.0 : 0.0, // Zen: completely hidden before flip
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !_isBackSide,
                      child: AnimatedSlide(
                        offset: _isBackSide ? Offset.zero : const Offset(0, 0.4),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRatingBtn('Hard', AppColors.rateHard, () => _onRate(0)),
                            _buildRatingBtn('OK', AppColors.rateOk, () => _onRate(3)),
                            _buildRatingBtn('Easy', AppColors.rateEasy, () => _onRate(5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardSide(String text, String lang, {required bool isFront}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(lang.toUpperCase(), style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: isFront ? AppTypography.display : AppTypography.headline.copyWith(color: AppColors.textSecondary),
          ),
          if (isFront && !_isBackSide) ...[
            const Spacer(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.pointer, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Text('Tap to flip', style: AppTypography.caption),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildRatingBtn(String label, Color color, VoidCallback onTap) {
    return Semantics(
      label: 'Rate $label',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(label, style: AppTypography.label.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
