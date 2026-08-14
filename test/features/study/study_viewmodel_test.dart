import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zen_flash_cards/core/models/flashcard.dart';
import 'package:zen_flash_cards/core/models/review_history.dart';
import 'package:zen_flash_cards/core/models/study_log.dart';
import 'package:zen_flash_cards/core/repositories/study_repository.dart';
import 'package:zen_flash_cards/core/utils/failure.dart';
import 'package:zen_flash_cards/features/study/study_viewmodel.dart';

class MockStudyRepository extends Mock implements StudyRepository {}

class FakeFlashcard extends Fake implements Flashcard {}

class FakeReviewHistory extends Fake implements ReviewHistory {}

class FakeStudyLog extends Fake implements StudyLog {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFlashcard());
    registerFallbackValue(FakeReviewHistory());
    registerFallbackValue(FakeStudyLog());
  });

  late StudyViewModel viewModel;
  late MockStudyRepository mockRepository;

  final testCard1 = Flashcard(
    id: 'card-1',
    deckId: 'deck-1',
    front: 'Hello',
    back: 'Xin chào',
    repetition: 0,
    easiness: 2.5,
    interval: 1,
    nextReview: DateTime.now().millisecondsSinceEpoch,
    createdAt: 1000,
  );

  final testCard2 = Flashcard(
    id: 'card-2',
    deckId: 'deck-1',
    front: 'Goodbye',
    back: 'Tạm biệt',
    repetition: 1,
    easiness: 2.5,
    interval: 1,
    nextReview: DateTime.now().millisecondsSinceEpoch,
    createdAt: 1001,
  );

  setUp(() {
    mockRepository = MockStudyRepository();
    viewModel = StudyViewModel(repository: mockRepository);
  });

  group('StudyViewModel Tests', () {
    test('loadDueCards success loads cards and resets state', () async {
      when(() => mockRepository.getCardsDueToday('deck-1'))
          .thenAnswer((_) async => Right([testCard1, testCard2]));

      await viewModel.loadDueCards('deck-1');

      expect(viewModel.isLoading, false);
      expect(viewModel.dueCards.length, 2);
      expect(viewModel.currentIndex, 0);
      expect(viewModel.currentCard?.id, 'card-1');
      expect(viewModel.isFinished, false);
      expect(viewModel.error, isNull);
    });

    test('loadDueCards failure sets error message', () async {
      when(() => mockRepository.getCardsDueToday('deck-1'))
          .thenAnswer((_) async => Left(Failure('DB Error')));

      await viewModel.loadDueCards('deck-1');

      expect(viewModel.isLoading, false);
      expect(viewModel.dueCards, isEmpty);
      expect(viewModel.error, 'DB Error');
    });

    test('answerCard awaits all repository operations and advances currentIndex synchronously', () async {
      when(() => mockRepository.getCardsDueToday('deck-1'))
          .thenAnswer((_) async => Right([testCard1]));
      when(() => mockRepository.updateCard(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockRepository.logReview(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockRepository.finishStudySession(any()))
          .thenAnswer((_) async => const Right(null));

      await viewModel.loadDueCards('deck-1');

      // Answer the only card with Easy (5)
      await viewModel.answerCard(5);

      // Verify that after await answerCard, everything is already completed
      expect(viewModel.currentIndex, 1);
      expect(viewModel.studiedCount, 1);
      expect(viewModel.correctCount, 1);
      expect(viewModel.isFinished, true);
      expect(viewModel.currentCard, isNull);

      verify(() => mockRepository.updateCard(any())).called(1);
      verify(() => mockRepository.logReview(any())).called(1);
      verify(() => mockRepository.finishStudySession(any())).called(1);
    });

    test('answerCard with quality < 3 does not increment correctCount', () async {
      when(() => mockRepository.getCardsDueToday('deck-1'))
          .thenAnswer((_) async => Right([testCard1]));
      when(() => mockRepository.updateCard(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockRepository.logReview(any()))
          .thenAnswer((_) async => const Right(null));
      when(() => mockRepository.finishStudySession(any()))
          .thenAnswer((_) async => const Right(null));

      await viewModel.loadDueCards('deck-1');

      await viewModel.answerCard(0); // Hard / Fail

      expect(viewModel.currentIndex, 1);
      expect(viewModel.studiedCount, 1);
      expect(viewModel.correctCount, 0);
      expect(viewModel.isFinished, true);
    });
  });
}
