import 'package:fpdart/fpdart.dart';
import '../models/deck.dart';
import '../utils/failure.dart';
import '../database/dao/deck_dao.dart';
import '../database/dao/card_dao.dart';

abstract class DeckRepository {
  Future<Either<Failure, List<Deck>>> getAllDecks();
  Future<Either<Failure, int>> getDueCount(String deckId);
  Future<Either<Failure, Deck>> addDeck(Deck deck);
  Future<Either<Failure, void>> updateDeck(Deck deck);
  Future<Either<Failure, void>> deleteDeck(String id);
}

class LocalDeckRepository implements DeckRepository {
  final DeckDao _deckDao;
  final CardDao _cardDao;

  LocalDeckRepository(this._deckDao, this._cardDao);

  @override
  Future<Either<Failure, List<Deck>>> getAllDecks() async {
    try {
      final decks = await _deckDao.readAll();
      return Right(decks);
    } catch (e, stackTrace) {
      return Left(
          Failure('Failed to load decks', error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, int>> getDueCount(String deckId) async {
    try {
      final count = await _cardDao.getDueCardCountForDeck(deckId);
      return Right(count);
    } catch (e, stackTrace) {
      return Left(Failure('Failed to get due count for deck',
          error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Deck>> addDeck(Deck deck) async {
    try {
      final newDeck = await _deckDao.create(deck);
      return Right(newDeck);
    } catch (e, stackTrace) {
      return Left(
          Failure('Failed to add deck', error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> updateDeck(Deck deck) async {
    try {
      await _deckDao.update(deck);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
          Failure('Failed to update deck', error: e, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeck(String id) async {
    try {
      await _deckDao.delete(id);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(
          Failure('Failed to delete deck', error: e, stackTrace: stackTrace));
    }
  }
}
