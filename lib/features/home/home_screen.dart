import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../shared/components/custom_bottom_nav.dart';
import '../../shared/components/deck_card.dart';
import '../../shared/components/empty_state.dart';
import '../deck/deck_viewmodel.dart';
import '../stats/stats_screen.dart';
import '../settings/settings_screen.dart';
import '../deck/deck_detail_screen.dart';
import '../deck/deck_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? AppBar(
        title: const Text('ZenFlashCards'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {},
          )
        ],
      ) : null,
      body: _buildBody(),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DeckForm()));
        },
        child: const Icon(LucideIcons.plus),
      ) : null,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDeckList();
      case 1:
        return const StatsScreen();
      case 2:
        return const SettingsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDeckList() {
    return Consumer<DeckViewModel>(
      builder: (context, deckVM, child) {
        if (deckVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final decks = deckVM.decks;
        if (decks.isEmpty) {
          return const EmptyState(
            message: 'No decks available\nTap + to create your first deck',
            illustration: Icon(LucideIcons.library, size: 80, color: Colors.grey),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: decks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final deck = decks[index];
            final dueCount = deckVM.getDueCount(deck.id);
            return DeckCard(
              deck: deck,
              dueCardsCount: dueCount,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => DeckDetailScreen(deck: deck)));
              },
              onLongPress: () {
                // Show context menu
              },
            );
          },
        );
      },
    );
  }
}
