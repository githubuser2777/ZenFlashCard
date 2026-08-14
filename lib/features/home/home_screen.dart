import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/custom_bottom_nav.dart';
import '../../shared/components/deck_card.dart';
import '../../shared/components/empty_state.dart';
import '../../shared/theme/app_colors.dart';
import '../deck/deck_viewmodel.dart';
import '../stats/stats_screen.dart';
import '../settings/settings_screen.dart';

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
      appBar: _currentIndex == 0
          ? AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.sparkles,
                      size: 16,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('ZenFlashCards'),
                ],
              ),
              centerTitle: false,
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _buildBody(),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              heroTag: 'home_add_deck_fab',
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/deck_form');
              },
              child: const Icon(LucideIcons.plus),
            )
              .animate()
              .scale(
                duration: 350.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 250.ms)
          : null,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index) {
            HapticFeedback.lightImpact();
            setState(() {
              _currentIndex = index;
            });
          }
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
            message:
                'No decks available yet.\nTap + below to create your first deck.',
            illustration: Icon(
              LucideIcons.library,
              size: 56,
              color: AppColors.primaryLight,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            await deckVM.loadDecks();
          },
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: decks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final deck = decks[index];
              final dueCount = deckVM.getDueCount(deck.id);

              return DeckCard(
                deck: deck,
                dueCardsCount: dueCount,
                onTap: () {
                  context.push('/deck/${deck.id}', extra: deck);
                },
                onLongPress: () {
                  _showDeckOptions(context, deck);
                },
              )
                  .animate()
                  .fadeIn(
                    duration: 350.ms,
                    delay: (index * 60).clamp(0, 400).ms,
                  )
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    duration: 350.ms,
                    delay: (index * 60).clamp(0, 400).ms,
                    curve: Curves.easeOutCubic,
                  );
            },
          ),
        );
      },
    );
  }

  void _showDeckOptions(BuildContext context, dynamic deck) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(deck.name, style: AppTypography.headline),
              const SizedBox(height: 16),
              ListTile(
                leading:
                    const Icon(LucideIcons.trash2, color: AppColors.rateHard),
                title: Text(
                  'Delete Deck',
                  style: AppTypography.body.copyWith(color: AppColors.rateHard),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Delete Deck?'),
                      content: Text(
                          'Are you sure you want to delete "${deck.name}" and all its cards?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, true),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.rateHard),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await context.read<DeckViewModel>().deleteDeck(deck.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
