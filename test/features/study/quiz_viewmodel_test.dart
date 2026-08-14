import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zen_flash_cards/core/models/flashcard.dart';
import 'package:zen_flash_cards/core/repositories/card_repository.dart';
import 'package:zen_flash_cards/core/utils/failure.dart';
import 'package:zen_flash_cards/features/study/quiz_viewmodel.dart';

class MockCardRepository extends Mock implements CardRepository {}

void main() {
  late QuizViewModel viewModel;
  late MockCardRepository mockRepository;

  final testCardsWithDuplicates = [
    Flashcard(
      id: '1',
      deckId: 'deck-1',
      front: 'Start',
      back: 'Bắt đầu',
      nextReview: 1000,
      createdAt: 1000,
    ),
    Flashcard(
      id: '2',
      deckId: 'deck-1',
      front: 'Begin',
      back: 'Bắt đầu', // Same back as card 1
      nextReview: 1000,
      createdAt: 1001,
    ),
    Flashcard(
      id: '3',
      deckId: 'deck-1',
      front: 'Initiate',
      back: 'Bắt đầu', // Same back as card 1
      nextReview: 1000,
      createdAt: 1002,
    ),
    Flashcard(
      id: '4',
      deckId: 'deck-1',
      front: 'Finish',
      back: 'Kết thúc',
      nextReview: 1000,
      createdAt: 1003,
    ),
    Flashcard(
      id: '5',
      deckId: 'deck-1',
      front: 'End',
      back: 'Chấm dứt',
      nextReview: 1000,
      createdAt: 1004,
    ),
    Flashcard(
      id: '6',
      deckId: 'deck-1',
      front: 'Pause',
      back: 'Tạm dừng',
      nextReview: 1000,
      createdAt: 1005,
    ),
  ];

  setUp(() {
    mockRepository = MockCardRepository();
    viewModel = QuizViewModel(repository: mockRepository);
  });

  group('QuizViewModel Tests', () {
    test('loadQuiz success generates unique options with no duplicate choices', () async {
      when(() => mockRepository.getCardsForDeck('deck-1'))
          .thenAnswer((_) async => Right(testCardsWithDuplicates));

      await viewModel.loadQuiz('deck-1');

      expect(viewModel.isLoading, false);
      expect(viewModel.quizCards.isNotEmpty, true);
      expect(viewModel.currentOptions.isNotEmpty, true);

      // Verify that all generated options in currentOptions are distinct
      final uniqueOptionsSet = viewModel.currentOptions.toSet();
      expect(uniqueOptionsSet.length, viewModel.currentOptions.length,
          reason: 'Quiz options must not contain duplicate answer strings');
      expect(viewModel.currentOptions.contains(viewModel.correctOption), true);
    });

    test('answerQuestion updates correct count and prevents duplicate answers', () async {
      when(() => mockRepository.getCardsForDeck('deck-1'))
          .thenAnswer((_) async => Right(testCardsWithDuplicates));

      await viewModel.loadQuiz('deck-1');

      final correct = viewModel.correctOption!;
      viewModel.answerQuestion(correct);

      expect(viewModel.selectedOption, correct);
      expect(viewModel.correctCount, 1);

      // Subsequent answer calls should be ignored
      viewModel.answerQuestion('Wrong Answer');
      expect(viewModel.selectedOption, correct);
      expect(viewModel.correctCount, 1);
    });

    test('nextQuestion advances to next question and regenerates options', () async {
      when(() => mockRepository.getCardsForDeck('deck-1'))
          .thenAnswer((_) async => Right(testCardsWithDuplicates));

      await viewModel.loadQuiz('deck-1');

      final initialCard = viewModel.currentCard;
      expect(viewModel.currentIndex, 0);

      viewModel.nextQuestion();

      expect(viewModel.currentIndex, 1);
      expect(viewModel.selectedOption, isNull);
      expect(viewModel.currentCard?.id, isNot(initialCard?.id));
    });

    test('loadQuiz failure sets error message', () async {
      when(() => mockRepository.getCardsForDeck('deck-1'))
          .thenAnswer((_) async => Left(Failure('Failed to load quiz')));

      await viewModel.loadQuiz('deck-1');

      expect(viewModel.isLoading, false);
      expect(viewModel.quizCards, isEmpty);
      expect(viewModel.error, 'Failed to load quiz');
    });
  });
}
