import 'package:fpdart/fpdart.dart';
import '../utils/failure.dart';
import '../models/deck.dart';
import '../models/study_log.dart';
import '../database/dao/deck_dao.dart';
import '../database/dao/card_dao.dart';
import '../database/dao/study_log_dao.dart';
import '../database/dao/review_history_dao.dart';

abstract class StatsRepository {
  Future<Either<Failure, List<Deck>>> getAllDecks();
  Future<Either<Failure, int>> getCardCountForDeck(String deckId);
  Future<Either<Failure, Map<int, int>>> getQualityDistribution();
  Future<Either<Failure, List<StudyLog>>> getLogsForLastNDays(int days);
}

class LocalStatsRepository implements StatsRepository {
  final DeckDao _deckDao;
  final CardDao _cardDao;
  final StudyLogDao _studyLogDao;
  final ReviewHistoryDao _reviewHistoryDao;

  LocalStatsRepository(
      this._deckDao, this._cardDao, this._studyLogDao, this._reviewHistoryDao);

  @override
  Future<Either<Failure, List<Deck>>> getAllDecks() async {
    try {
      final decks = await _deckDao.readAll();
      return Right(decks);
    } catch (e) {
      return Left(Failure('Failed to load decks: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getCardCountForDeck(String deckId) async {
    try {
      final count = await _cardDao.getCardCountForDeck(deckId);
      return Right(count);
    } catch (e) {
      return Left(Failure('Failed to load card count: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<int, int>>> getQualityDistribution() async {
    try {
      final distribution = await _reviewHistoryDao.getQualityDistribution();
      return Right(distribution);
    } catch (e) {
      return Left(Failure('Failed to load quality distribution: $e'));
    }
  }

  @override
  Future<Either<Failure, List<StudyLog>>> getLogsForLastNDays(int days) async {
    try {
      final logs = await _studyLogDao.getLogsForLastNDays(days);
      return Right(logs);
    } catch (e) {
      return Left(Failure('Failed to load study logs: $e'));
    }
  }
}
