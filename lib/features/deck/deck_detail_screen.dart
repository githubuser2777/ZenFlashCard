import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/deck.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/components/zen_button.dart';
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
              // Add edit/delete logic later
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'import',
                  child: Row(
                    children: [
                      const Icon(LucideIcons.download, size: 20),
                      const SizedBox(width: 12),
                      Text('Import CSV',
                          style: AppTypography.body
                              .copyWith(color: AppColors.textPrimary)),
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
                    horizontal: 20.0, vertical: 12.0),
                child: Text(
                    '${widget.deck.languageFront} → ${widget.deck.languageBack} · ${cards.length} cards',
                    style: AppTypography.body),
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
              ),
              const Divider(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: cards.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return ListTile(
                      title: Text(card.front, style: AppTypography.title),
                      trailing: Text(card.back, style: AppTypography.body),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/deck/${widget.deck.id}/add_card');
        },
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
