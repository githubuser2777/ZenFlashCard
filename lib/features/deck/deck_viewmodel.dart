import 'package:flutter/foundation.dart';
import '../../core/models/deck.dart';
import '../../core/repositories/deck_repository.dart';

class DeckViewModel extends ChangeNotifier {
  final DeckRepository _repository;

  DeckViewModel(this._repository);

  List<Deck> _decks = [];
  final Map<String, int> _dueCounts = {};
  bool _isLoading = false;
  String? _error;

  List<Deck> get decks => _decks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setError(String? message) {
    _error = message;
  }

  Future<void> loadDecks() async {
    _isLoading = true;
    _setError(null);
    notifyListeners();

    final result = await _repository.getAllDecks();
    
    await result.fold(
      (failure) async {
        _setError(failure.message);
      },
      (decks) async {
        _decks = decks;
        // Load due counts for each deck
        for (var deck in _decks) {
          final countResult = await _repository.getDueCount(deck.id);
          countResult.fold(
            (failure) => _dueCounts[deck.id] = 0,
            (count) => _dueCounts[deck.id] = count,
          );
        }
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  int getDueCount(String deckId) {
    return _dueCounts[deckId] ?? 0;
  }

  Future<void> addDeck(Deck deck) async {
    _setError(null);
    final result = await _repository.addDeck(deck);
    result.fold(
      (failure) {
        _setError(failure.message);
        notifyListeners();
      },
      (_) => loadDecks(),
    );
  }

  Future<void> updateDeck(Deck deck) async {
    _setError(null);
    final result = await _repository.updateDeck(deck);
    result.fold(
      (failure) {
        _setError(failure.message);
        notifyListeners();
      },
      (_) => loadDecks(),
    );
  }

  Future<void> deleteDeck(String id) async {
    _setError(null);
    final result = await _repository.deleteDeck(id);
    result.fold(
      (failure) {
        _setError(failure.message);
        notifyListeners();
      },
      (_) => loadDecks(),
    );
  }
}
