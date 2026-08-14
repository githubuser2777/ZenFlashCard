import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zen_flash_cards/core/models/deck.dart';
import 'package:zen_flash_cards/core/repositories/deck_repository.dart';
import 'package:zen_flash_cards/core/utils/failure.dart';
import 'package:zen_flash_cards/features/deck/deck_viewmodel.dart';

class MockDeckRepository extends Mock implements DeckRepository {}

void main() {
  late DeckViewModel viewModel;
  late MockDeckRepository mockRepository;

  setUp(() {
    mockRepository = MockDeckRepository();
    viewModel = DeckViewModel(mockRepository);
  });

  final testDeck = Deck(
    id: '1',
    name: 'Test Deck',
    languageFront: 'en',
    languageBack: 'vi',
    createdAt: 123456789,
  );

  group('DeckViewModel Tests', () {
    test('loadDecks success updates decks list and due counts', () async {
      when(() => mockRepository.getAllDecks())
          .thenAnswer((_) async => Right([testDeck]));
      when(() => mockRepository.getDueCount('1'))
          .thenAnswer((_) async => const Right(5));

      expect(viewModel.isLoading, false);
      expect(viewModel.decks, isEmpty);

      final future = viewModel.loadDecks();
      expect(viewModel.isLoading, true);

      await future;

      expect(viewModel.isLoading, false);
      expect(viewModel.decks.length, 1);
      expect(viewModel.decks.first.name, 'Test Deck');
      expect(viewModel.getDueCount('1'), 5);
      expect(viewModel.error, isNull);
    });

    test('loadDecks failure sets error message', () async {
      when(() => mockRepository.getAllDecks())
          .thenAnswer((_) async => Left(Failure('Failed to load decks')));

      await viewModel.loadDecks();

      expect(viewModel.isLoading, false);
      expect(viewModel.decks, isEmpty);
      expect(viewModel.error, 'Failed to load decks');
    });

    test('addDeck success calls loadDecks', () async {
      when(() => mockRepository.addDeck(testDeck))
          .thenAnswer((_) async => Right(testDeck));
      when(() => mockRepository.getAllDecks())
          .thenAnswer((_) async => Right([testDeck]));
      when(() => mockRepository.getDueCount('1'))
          .thenAnswer((_) async => const Right(0));

      await viewModel.addDeck(testDeck);

      verify(() => mockRepository.addDeck(testDeck)).called(1);
      verify(() => mockRepository.getAllDecks()).called(1);
    });
  });
}
