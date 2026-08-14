import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/deck/deck_detail_screen.dart';
import '../../features/deck/deck_form.dart';
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
        final deck = state.extra as Deck;
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
        final deck = state.extra as Deck;
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
        final deck = state.extra as Deck;
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
        final data = state.extra as Map<String, dynamic>;
        final correctCount = data['correctCount'] as int;
        final totalCount = data['totalCount'] as int;
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
