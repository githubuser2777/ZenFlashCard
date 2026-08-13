import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/flashcard.dart';
import '../../core/database/dao/card_dao.dart';

class CardViewModel extends ChangeNotifier {
  final CardDao _cardDao = CardDao();
  final Uuid _uuid = const Uuid();

  List<Flashcard> _cards = [];
  bool _isLoading = false;

  List<Flashcard> get cards => _cards;
  bool get isLoading => _isLoading;

  Future<void> loadCards(String deckId) async {
    _isLoading = true;
    notifyListeners();

    _cards = await _cardDao.getCardsForDeck(deckId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCard(Flashcard card) async {
    await _cardDao.create(card);
    await loadCards(card.deckId);
  }

  Future<void> updateCard(Flashcard card) async {
    await _cardDao.update(card);
    await loadCards(card.deckId);
  }

  Future<void> deleteCard(String id, String deckId) async {
    await _cardDao.delete(id);
    await loadCards(deckId);
  }

  Future<bool> checkDuplicate(String deckId, String front, String back) async {
    final allCards = await _cardDao.getCardsForDeck(deckId);
    return allCards.any((c) => c.front == front && c.back == back);
  }

  Future<String> readCsvContent(PlatformFile file) async {
    if (file.path != null) {
      return await File(file.path!).readAsString();
    } else if (file.bytes != null) {
      return utf8.decode(file.bytes!); // Safe SAF Fallback
    } else {
      throw Exception('Cannot access CSV file data');
    }
  }

  Future<Map<String, int>> importCsv(String deckId, PlatformFile file) async {
    try {
      final csvString = await readCsvContent(file);
      final List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvString);
      
      int imported = 0;
      int skipped = 0;
      
      final existingCards = await _cardDao.getCardsForDeck(deckId);
      final existingSet = existingCards.map((c) => '${c.front}|${c.back}').toSet();

      for (var row in rowsAsListOfValues) {
        if (row.length >= 2) {
          final front = row[0].toString().trim();
          final back = row[1].toString().trim();
          
          if (front.isEmpty || back.isEmpty) continue;
          
          final key = '$front|$back';
          if (existingSet.contains(key)) {
            skipped++;
          } else {
            final newCard = Flashcard(
              id: _uuid.v4(),
              deckId: deckId,
              front: front,
              back: back,
              nextReview: DateTime.now().millisecondsSinceEpoch,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            );
            await _cardDao.create(newCard);
            existingSet.add(key);
            imported++;
          }
        }
      }
      
      await loadCards(deckId);
      return {'imported': imported, 'skipped': skipped};
    } catch (e) {
      throw Exception('Failed to import CSV: $e');
    }
  }
}
