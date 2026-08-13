import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/models/deck.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/components/zen_button.dart';
import '../card/card_viewmodel.dart';
import '../card/card_form.dart';
import '../study/study_screen.dart';
import '../study/quiz_screen.dart';

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
        final importResult = await cardVM.importCsv(widget.deck.id, platformFile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported ${importResult['imported']} cards. Skipped ${importResult['skipped']} duplicates.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
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
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('${widget.deck.languageFront} → ${widget.deck.languageBack} · ${cards.length} cards', style: AppTypography.body),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ZenButton(
                        label: 'Study Now',
                        icon: const Icon(Icons.auto_stories, size: 18),
                        onPressed: cards.isEmpty ? null : () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => StudyScreen(deck: widget.deck)));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ZenButton(
                        label: 'Quiz',
                        variant: ZenButtonVariant.outlined,
                        icon: const Icon(Icons.psychology, size: 18),
                        onPressed: cards.length < 4 ? null : () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(deck: widget.deck)));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ZenButton(
                label: 'Import CSV',
                variant: ZenButtonVariant.text,
                icon: const Icon(Icons.download),
                onPressed: () => _importCsv(context),
              ),
              const Divider(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: cards.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return ListTile(
                      title: Text(card.front, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(card.back, style: const TextStyle(color: AppColors.textSecondary)),
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => CardForm(deckId: widget.deck.id)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
