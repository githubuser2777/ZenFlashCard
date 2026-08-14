import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/flashcard.dart';
import '../../core/repositories/card_repository.dart';

class CardViewModel extends ChangeNotifier {
  final CardRepository _repository;
  final Uuid _uuid = const Uuid();

  CardViewModel({required CardRepository repository})
      : _repository = repository;

  List<Flashcard> _cards = [];
  bool _isLoading = false;
  String? _error;

  List<Flashcard> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCards(String deckId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getCardsForDeck(deckId);

    result.fold(
      (failure) => _error = failure.message,
      (data) => _cards = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCard(Flashcard card) async {
    final result = await _repository.create(card);
    result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
      },
      (_) => loadCards(card.deckId),
    );
  }

  Future<void> updateCard(Flashcard card) async {
    final result = await _repository.update(card);
    result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
      },
      (_) => loadCards(card.deckId),
    );
  }

  Future<void> deleteCard(String id, String deckId) async {
    final result = await _repository.delete(id);
    result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
      },
      (_) => loadCards(deckId),
    );
  }

  Future<bool> checkDuplicate(String deckId, String front, String back) async {
    final result = await _repository.getCardsForDeck(deckId);
    return result.fold(
      (failure) => false,
      (allCards) => allCards.any((c) => c.front == front && c.back == back),
    );
  }

  Future<String> readCsvContent(PlatformFile file) async {
    const maxCsvSizeBytes = 10 * 1024 * 1024; // 10 MB limit
    if (file.size > maxCsvSizeBytes) {
      throw Exception('File too large (max 10MB allowed)');
    }

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
      final List<List<dynamic>> rowsAsListOfValues =
          const CsvToListConverter().convert(csvString);

      const maxRows = 5000;
      if (rowsAsListOfValues.length > maxRows) {
        throw Exception('CSV has too many rows (max $maxRows allowed)');
      }

      int imported = 0;
      int skipped = 0;

      final result = await _repository.getCardsForDeck(deckId);
      final existingCards = result.getOrElse((_) => []);
      // Use unit separator character to avoid collision with pipe '|' in content
      final existingSet =
          existingCards.map((c) => '${c.front}\u001F${c.back}').toSet();

      for (var row in rowsAsListOfValues) {
        if (row.length >= 2) {
          final front = row[0].toString().trim();
          final back = row[1].toString().trim();

          if (front.isEmpty || back.isEmpty) {
            continue;
          }
          if (front.length > 1000 || back.length > 2000) {
            continue; // Length limit
          }

          final key = '$front\u001F$back';
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
            await _repository.create(newCard);
            existingSet.add(key);
            imported++;
          }
        }
      }

      await loadCards(deckId);
      return {'imported': imported, 'skipped': skipped};
    } catch (e) {
      if (e is Exception && e.toString().contains('(max ')) {
        rethrow;
      }
      debugPrint('CSV import error: $e');
      throw Exception('Failed to import CSV. Please verify file format.');
    }
  }
}
