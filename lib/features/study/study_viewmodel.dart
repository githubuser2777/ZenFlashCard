import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/flashcard.dart';
import '../../core/models/study_log.dart';
import '../../core/models/review_history.dart';
import '../../core/repositories/study_repository.dart';
import '../../core/algorithms/sm2.dart';

class StudyViewModel extends ChangeNotifier {
  final StudyRepository _repository;
  final Uuid _uuid = const Uuid();

  StudyViewModel({required StudyRepository repository})
      : _repository = repository;

  List<Flashcard> _dueCards = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _studiedCount = 0;
  bool _isLoading = false;
  String? _error;

  List<Flashcard> get dueCards => _dueCards;
  int get currentIndex => _currentIndex;
  int get correctCount => _correctCount;
  int get studiedCount => _studiedCount;
  bool get isLoading => _isLoading;
  bool get isFinished =>
      _currentIndex >= _dueCards.length && _dueCards.isNotEmpty;
  String? get error => _error;

  Flashcard? get currentCard =>
      isFinished || _dueCards.isEmpty ? null : _dueCards[_currentIndex];

  Future<void> loadDueCards(String deckId) async {
    _isLoading = true;
    _currentIndex = 0;
    _correctCount = 0;
    _studiedCount = 0;
    _error = null;
    notifyListeners();

    final result = await _repository.getCardsDueToday(deckId);
    result.fold(
      (failure) => _error = failure.message,
      (data) => _dueCards = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> answerCard(int quality) async {
    if (currentCard == null) return;

    final card = currentCard!;

    // Update SM-2
    final result = calculateNextReview(
      repetition: card.repetition,
      easiness: card.easiness,
      intervalDays: card.interval,
      quality: quality,
    );

    final updatedCard = Flashcard(
      id: card.id,
      deckId: card.deckId,
      front: card.front,
      back: card.back,
      repetition: result.repetition,
      easiness: result.easiness,
      interval: result.intervalDays,
      nextReview: result.nextReviewMs,
      createdAt: card.createdAt,
    );

    final updateResult = await _repository.updateCard(updatedCard);
    if (updateResult.isLeft()) {
      _error = updateResult.getLeft().toNullable()?.message;
      notifyListeners();
      return;
    }

    final history = ReviewHistory(
      id: _uuid.v4(),
      cardId: card.id,
      deckId: card.deckId,
      quality: quality,
      reviewedAt: DateTime.now().millisecondsSinceEpoch,
    );
    final logResult = await _repository.logReview(history);
    if (logResult.isLeft()) {
      _error = logResult.getLeft().toNullable()?.message;
    }

    _studiedCount++;
    if (quality >= 3) {
      _correctCount++;
    }

    _currentIndex++;

    if (isFinished) {
      await _finishSession(card.deckId);
    }

    notifyListeners();
  }

  Future<void> _finishSession(String deckId) async {
    final log = StudyLog(
      id: _uuid.v4(),
      deckId: deckId,
      cardsStudied: _studiedCount,
      correct: _correctCount,
      studiedAt: DateTime.now().millisecondsSinceEpoch,
    );
    final result = await _repository.finishStudySession(log);
    result.fold(
      (failure) => _error = failure.message,
      (_) => null,
    );
  }
}
