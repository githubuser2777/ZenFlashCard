import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/deck/deck_detail_screen.dart';
import '../../features/deck/deck_form.dart';
import '../../features/deck/deck_viewmodel.dart';
import '../../features/card/card_form.dart';
import '../../features/study/study_screen.dart';
import '../../features/study/quiz_screen.dart';
import '../../features/study/session_result_screen.dart';
import '../../core/models/deck.dart';

CustomTransitionPage<void> _buildZenTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

Deck _resolveDeck(BuildContext context, GoRouterState state) {
  if (state.extra is Deck) {
    return state.extra as Deck;
  }
  final deckId = state.pathParameters['id'] ?? '';
  try {
    final deckVM = Provider.of<DeckViewModel>(context, listen: false);
    for (final d in deckVM.decks) {
      if (d.id == deckId) return d;
    }
  } catch (_) {}

  return Deck(
    id: deckId,
    name: 'Deck',
    languageFront: 'en',
    languageBack: 'vi',
    createdAt: DateTime.now().millisecondsSinceEpoch,
  );
}

final appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      pageBuilder: (context, state) => _buildZenTransition(
        context: context,
        state: state,
        child: const WelcomeScreen(),
      ),
    ),
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildZenTransition(
        context: context,
        state: state,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/deck_form',
      pageBuilder: (context, state) => _buildZenTransition(
        context: context,
        state: state,
        child: const DeckForm(),
      ),
    ),
    GoRoute(
      path: '/deck/:id',
      pageBuilder: (context, state) {
        final deck = _resolveDeck(context, state);
        return _buildZenTransition(
          context: context,
          state: state,
          child: DeckDetailScreen(deck: deck),
        );
      },
    ),
    GoRoute(
      path: '/deck/:id/add_card',
      pageBuilder: (context, state) {
        final deckId = state.pathParameters['id']!;
        return _buildZenTransition(
          context: context,
          state: state,
          child: CardForm(deckId: deckId),
        );
      },
    ),
    GoRoute(
      path: '/deck/:id/study',
      pageBuilder: (context, state) {
        final deck = _resolveDeck(context, state);
        return _buildZenTransition(
          context: context,
          state: state,
          child: StudyScreen(deck: deck),
        );
      },
    ),
    GoRoute(
      path: '/deck/:id/quiz',
      pageBuilder: (context, state) {
        final deck = _resolveDeck(context, state);
        return _buildZenTransition(
          context: context,
          state: state,
          child: QuizScreen(deck: deck),
        );
      },
    ),
    GoRoute(
      path: '/session_result',
      pageBuilder: (context, state) {
        int correctCount = 0;
        int totalCount = 0;
        if (state.extra is Map<String, dynamic>) {
          final data = state.extra as Map<String, dynamic>;
          correctCount = data['correctCount'] as int? ?? 0;
          totalCount = data['totalCount'] as int? ?? 0;
        }
        return _buildZenTransition(
          context: context,
          state: state,
          child: SessionResultScreen(
            correctCount: correctCount,
            totalCount: totalCount,
          ),
        );
      },
    ),
  ],
);
