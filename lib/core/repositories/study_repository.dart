import 'package:fpdart/fpdart.dart';
import '../utils/failure.dart';
import '../models/flashcard.dart';
import '../models/study_log.dart';
import '../models/review_history.dart';
import '../database/dao/card_dao.dart';
import '../database/dao/study_log_dao.dart';
import '../database/dao/review_history_dao.dart';

abstract class StudyRepository {
  Future<Either<Failure, List<Flashcard>>> getCardsDueToday(String deckId);
  Future<Either<Failure, void>> updateCard(Flashcard card);
  Future<Either<Failure, void>> logReview(ReviewHistory history);
  Future<Either<Failure, void>> finishStudySession(StudyLog log);
}

class LocalStudyRepository implements StudyRepository {
  final CardDao _cardDao;
  final StudyLogDao _studyLogDao;
  final ReviewHistoryDao _reviewHistoryDao;

  LocalStudyRepository(
      this._cardDao, this._studyLogDao, this._reviewHistoryDao);

  @override
  Future<Either<Failure, List<Flashcard>>> getCardsDueToday(
      String deckId) async {
    try {
      final cards = await _cardDao.getCardsDueToday(deckId);
      return Right(cards);
    } catch (e) {
      return Left(Failure('Failed to load due cards: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCard(Flashcard card) async {
    try {
      await _cardDao.update(card);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to update card: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logReview(ReviewHistory history) async {
    try {
      await _reviewHistoryDao.create(history);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to log review: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> finishStudySession(StudyLog log) async {
    try {
      await _studyLogDao.create(log);
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to finish study session: $e'));
    }
  }
}
