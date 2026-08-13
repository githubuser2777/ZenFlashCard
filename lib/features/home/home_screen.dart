import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/components/custom_bottom_nav.dart';
import '../../shared/components/deck_card.dart';
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
            icon: const Icon(Icons.search),
            onPressed: () {},
          )
        ],
      ) : null,
      body: _buildBody(),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const DeckForm()));
        },
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
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
          return const Center(
            child: Text('No decks yet. Tap + to add one.'),
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
