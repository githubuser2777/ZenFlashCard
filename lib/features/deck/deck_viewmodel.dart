import 'package:flutter/foundation.dart';
import '../../core/models/deck.dart';
import '../../core/database/dao/deck_dao.dart';
import '../../core/database/dao/card_dao.dart';

class DeckViewModel extends ChangeNotifier {
  final DeckDao _deckDao = DeckDao();
  final CardDao _cardDao = CardDao();

  List<Deck> _decks = [];
  Map<String, int> _dueCounts = {};
  bool _isLoading = false;

  List<Deck> get decks => _decks;
  bool get isLoading => _isLoading;

  Future<void> loadDecks() async {
    _isLoading = true;
    notifyListeners();

    _decks = await _deckDao.readAll();
    
    // Load due counts for each deck
    for (var deck in _decks) {
      _dueCounts[deck.id] = await _cardDao.getDueCardCountForDeck(deck.id);
    }

    _isLoading = false;
    notifyListeners();
  }

  int getDueCount(String deckId) {
    return _dueCounts[deckId] ?? 0;
  }

  Future<void> addDeck(Deck deck) async {
    await _deckDao.create(deck);
    await loadDecks();
  }

  Future<void> updateDeck(Deck deck) async {
    await _deckDao.update(deck);
    await loadDecks();
  }

  Future<void> deleteDeck(String id) async {
    await _deckDao.delete(id);
    await loadDecks();
  }
}
