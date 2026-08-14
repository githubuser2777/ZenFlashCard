import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/deck.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/components/zen_button.dart';
import '../../shared/components/empty_state.dart';
import '../card/card_viewmodel.dart';

class DeckDetailScreen extends StatefulWidget {
  final Deck deck;

  const DeckDetailScreen({super.key, required this.deck});

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardViewModel>().loadCards(widget.deck.id);
    });
  }

  void _importCsv(BuildContext context) async {
    final cardVM = context.read<CardViewModel>();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        final importResult =
            await cardVM.importCsv(widget.deck.id, platformFile);
        if (mounted && context.mounted) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Imported ${importResult['imported']} cards. Skipped ${importResult['skipped']} duplicates.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.rateHard),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.name),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical),
            onSelected: (value) {
              if (value == 'import') {
                _importCsv(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'import',
                  child: Row(
                    children: [
                      const Icon(LucideIcons.download, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Import CSV',
                        style: AppTypography.body.copyWith(
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: Consumer<CardViewModel>(
        builder: (context, cardVM, child) {
          if (cardVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final cards = cardVM.cards;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.deck.languageFront.toUpperCase()} → ${widget.deck.languageBack.toUpperCase()}',
                        style: AppTypography.label.copyWith(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '·  ${cards.length} cards total',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ZenButton(
                        label: 'Study Now',
                        icon: const Icon(LucideIcons.bookOpen, size: 18),
                        onPressed: cards.isEmpty
                            ? null
                            : () {
                                context.push('/deck/${widget.deck.id}/study',
                                    extra: widget.deck);
                              },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ZenButton(
                        label: 'Quiz',
                        variant: ZenButtonVariant.outlined,
                        icon: const Icon(LucideIcons.target, size: 18),
                        onPressed: cards.length < 4
                            ? null
                            : () {
                                if (cards.length < 4) {
                                  HapticFeedback.heavyImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Need at least 4 cards to start a quiz')),
                                  );
                                  return;
                                }
                                context.push('/deck/${widget.deck.id}/quiz',
                                    extra: widget.deck);
                              },
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1, end: 0),
              const Divider(height: 24),
              Expanded(
                child: cards.isEmpty
                    ? const EmptyState(
                        message:
                            'No cards in this deck yet.\nTap + or import CSV to add flashcards.',
                        illustration: Icon(
                          LucideIcons.copyPlus,
                          size: 52,
                          color: AppColors.primaryLight,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: cards.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return ListTile(
                            title: Text(
                              card.front,
                              style: AppTypography.title.copyWith(
                                color: isDark
                                    ? AppColors.textPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            trailing: Text(
                              card.back,
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(
                                duration: 250.ms,
                                delay: (index * 30).clamp(0, 300).ms,
                              )
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                duration: 250.ms,
                                delay: (index * 30).clamp(0, 300).ms,
                                curve: Curves.easeOutCubic,
                              );
                        },
                      ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'deck_add_card_fab',
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/deck/${widget.deck.id}/add_card');
        },
        child: const Icon(LucideIcons.plus),
      )
          .animate()
          .scale(duration: 300.ms, curve: Curves.easeOutBack)
          .fadeIn(duration: 200.ms),
    );
  }
}
