import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../core/models/flashcard.dart';
import '../../core/repositories/card_repository.dart';

class QuizViewModel extends ChangeNotifier {
  final CardRepository _repository;

  QuizViewModel({required CardRepository repository})
      : _repository = repository;

  List<Flashcard> _allCards = [];
  List<Flashcard> _quizCards = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  bool _isLoading = false;
  String? _error;

  List<String> _currentOptions = [];
  String? _selectedOption;
  String? _correctOption;

  List<Flashcard> get quizCards => _quizCards;
  int get currentIndex => _currentIndex;
  int get correctCount => _correctCount;
  bool get isLoading => _isLoading;
  bool get isFinished =>
      _currentIndex >= _quizCards.length && _quizCards.isNotEmpty;
  String? get error => _error;

  Flashcard? get currentCard =>
      isFinished || _quizCards.isEmpty ? null : _quizCards[_currentIndex];
  List<String> get currentOptions => _currentOptions;
  String? get selectedOption => _selectedOption;
  String? get correctOption => _correctOption;

  Future<void> loadQuiz(String deckId) async {
    _isLoading = true;
    _currentIndex = 0;
    _correctCount = 0;
    _selectedOption = null;
    _correctOption = null;
    _error = null;
    notifyListeners();

    final result = await _repository.getCardsForDeck(deckId);
    result.fold((failure) => _error = failure.message, (cards) {
      _allCards = cards;
      // Select up to 10 random cards for the quiz
      _allCards.shuffle(Random());
      _quizCards = _allCards.take(10).toList();

      _generateOptions();
    });

    _isLoading = false;
    notifyListeners();
  }

  void _generateOptions() {
    if (isFinished || currentCard == null) return;

    final correct = currentCard!.back;
    _correctOption = correct;

    final otherCards = _allCards.where((c) => c.id != currentCard!.id).toList();
    otherCards.shuffle(Random());

    final wrongOptions = otherCards.take(3).map((c) => c.back).toList();

    _currentOptions = [correct, ...wrongOptions];
    _currentOptions.shuffle(Random());
    _selectedOption = null;
  }

  void answerQuestion(String option) {
    if (_selectedOption != null) return; // Already answered

    _selectedOption = option;
    if (option == _correctOption) {
      _correctCount++;
    }
    notifyListeners();
  }

  void nextQuestion() {
    _currentIndex++;
    if (!isFinished) {
      _generateOptions();
    }
    notifyListeners();
  }
}
