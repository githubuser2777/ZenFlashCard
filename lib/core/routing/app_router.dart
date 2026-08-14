import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/deck/deck_detail_screen.dart';
import '../../features/deck/deck_form.dart';
import '../../features/card/card_form.dart';
import '../../features/study/study_screen.dart';
import '../../features/study/quiz_screen.dart';
import '../../features/study/session_result_screen.dart';
import '../../core/models/deck.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/deck_form',
      builder: (context, state) => const DeckForm(),
    ),
    GoRoute(
      path: '/deck/:id',
      builder: (context, state) {
        final deck = state.extra as Deck;
        return DeckDetailScreen(deck: deck);
      },
    ),
    GoRoute(
      path: '/deck/:id/add_card',
      builder: (context, state) {
        final deckId = state.pathParameters['id']!;
        return CardForm(deckId: deckId);
      },
    ),
    GoRoute(
      path: '/deck/:id/study',
      builder: (context, state) {
        final deck = state.extra as Deck;
        return StudyScreen(deck: deck);
      },
    ),
    GoRoute(
      path: '/deck/:id/quiz',
      builder: (context, state) {
        final deck = state.extra as Deck;
        return QuizScreen(deck: deck);
      },
    ),
    GoRoute(
      path: '/session_result',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final correctCount = data['correctCount'] as int;
        final totalCount = data['totalCount'] as int;
        return SessionResultScreen(
            correctCount: correctCount, totalCount: totalCount);
      },
    ),
  ],
);
