import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zen_flash_cards/core/models/deck.dart';
import 'package:zen_flash_cards/core/models/study_log.dart';
import 'package:zen_flash_cards/core/repositories/stats_repository.dart';
import 'package:zen_flash_cards/features/stats/stats_viewmodel.dart';

class MockStatsRepository extends Mock implements StatsRepository {}

void main() {
  late StatsViewModel viewModel;
  late MockStatsRepository mockRepository;

  final testDeck1 = Deck(
    id: 'deck-1',
    name: 'English',
    languageFront: 'en',
    languageBack: 'vi',
    createdAt: 1000,
  );

  final testDeck2 = Deck(
    id: 'deck-2',
    name: 'Japanese',
    languageFront: 'ja',
    languageBack: 'vi',
    createdAt: 1001,
  );

  setUp(() {
    mockRepository = MockStatsRepository();
    viewModel = StatsViewModel(repository: mockRepository);
  });

  group('StatsViewModel Tests', () {
    test('loadStats success calculates total decks, total cards, quality distribution and streak', () async {
      when(() => mockRepository.getAllDecks())
          .thenAnswer((_) async => Right([testDeck1, testDeck2]));
      when(() => mockRepository.getCardCountForDeck('deck-1'))
          .thenAnswer((_) async => const Right(15));
      when(() => mockRepository.getCardCountForDeck('deck-2'))
          .thenAnswer((_) async => const Right(25));
      when(() => mockRepository.getQualityDistribution())
          .thenAnswer((_) async => const Right({0: 2, 3: 5, 5: 10}));

      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);
      final yesterdayMidnight = DateTime(now.year, now.month, now.day - 1);
      final twoDaysAgoMidnight = DateTime(now.year, now.month, now.day - 2);

      final logs = [
        StudyLog(
          id: 'log-1',
          deckId: 'deck-1',
          cardsStudied: 10,
          correct: 8,
          studiedAt: todayMidnight.millisecondsSinceEpoch + 3600000,
        ),
        StudyLog(
          id: 'log-2',
          deckId: 'deck-1',
          cardsStudied: 15,
          correct: 12,
          studiedAt: yesterdayMidnight.millisecondsSinceEpoch + 7200000,
        ),
        StudyLog(
          id: 'log-3',
          deckId: 'deck-2',
          cardsStudied: 20,
          correct: 18,
          studiedAt: twoDaysAgoMidnight.millisecondsSinceEpoch + 1800000,
        ),
      ];

      when(() => mockRepository.getLogsForLastNDays(any()))
          .thenAnswer((_) async => Right(logs));

      await viewModel.loadStats();

      expect(viewModel.isLoading, false);
      expect(viewModel.totalDecks, 2);
      expect(viewModel.totalCards, 40); // 15 + 25
      expect(viewModel.qualityDistribution, {0: 2, 3: 5, 5: 10});
      expect(viewModel.streak, 3);
      expect(viewModel.last7DaysActivity.length, 7);
      expect(viewModel.last7DaysActivity.last, 10); // Today's activity
      expect(viewModel.error, isNull);
    });

    test('loadStats handles empty logs with 0 streak', () async {
      when(() => mockRepository.getAllDecks())
          .thenAnswer((_) async => const Right([]));
      when(() => mockRepository.getQualityDistribution())
          .thenAnswer((_) async => const Right({0: 0, 3: 0, 5: 0}));
      when(() => mockRepository.getLogsForLastNDays(any()))
          .thenAnswer((_) async => const Right([]));

      await viewModel.loadStats();

      expect(viewModel.isLoading, false);
      expect(viewModel.totalDecks, 0);
      expect(viewModel.totalCards, 0);
      expect(viewModel.streak, 0);
      expect(viewModel.last7DaysActivity, List.filled(7, 0));
    });
  });
}
