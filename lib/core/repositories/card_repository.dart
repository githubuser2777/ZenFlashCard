import 'package:fpdart/fpdart.dart';
import '../utils/failure.dart';
import '../models/flashcard.dart';

abstract class CardRepository {
  Future<Either<Failure, List<Flashcard>>> getCardsForDeck(String deckId);
  Future<Either<Failure, void>> create(Flashcard card);
  Future<Either<Failure, void>> update(Flashcard card);
  Future<Either<Failure, void>> delete(String id);
}

class LocalCardRepository implements CardRepository {
  final dynamic _cardDao;

  LocalCardRepository(this._cardDao);

  @override
  Future<Either<Failure, List<Flashcard>>> getCardsForDeck(
      String deckId) async {
    try {
      final cards = await _cardDao.getCardsForDeck(deckId);
      return Right(cards);
    } catch (e) {
      return Left(Failure('Failed to load cards: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> create(Flashcard card) async {
    try {
      await _cardDao.create(card);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to create card: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> update(Flashcard card) async {
    try {
      await _cardDao.update(card);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to update card: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await _cardDao.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to delete card: $e'));
    }
  }
}
