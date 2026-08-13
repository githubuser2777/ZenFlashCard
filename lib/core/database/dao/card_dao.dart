import 'package:sqflite/sqflite.dart';
import '../../models/flashcard.dart';
import '../database_helper.dart';

class CardDao {
  final dbHelper = DatabaseHelper.instance;

  Future<Flashcard> create(Flashcard card) async {
    final db = await dbHelper.database;
    await db.insert('flashcards', card.toMap());
    return card;
  }

  Future<Flashcard?> read(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'flashcards',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Flashcard.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Flashcard>> getCardsForDeck(String deckId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'flashcards',
      where: 'deck_id = ?',
      whereArgs: [deckId],
      orderBy: 'created_at DESC',
    );
    return result.map((json) => Flashcard.fromMap(json)).toList();
  }

  Future<List<Flashcard>> getCardsDueToday(String deckId) async {
    final db = await dbHelper.database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final result = await db.query(
      'flashcards',
      where: 'deck_id = ? AND next_review <= ?',
      whereArgs: [deckId, nowMs],
      orderBy: 'next_review ASC',
    );
    return result.map((json) => Flashcard.fromMap(json)).toList();
  }

  Future<int> getCardCountForDeck(String deckId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM flashcards WHERE deck_id = ?', [deckId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getDueCardCountForDeck(String deckId) async {
    final db = await dbHelper.database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final result = await db.rawQuery('SELECT COUNT(*) FROM flashcards WHERE deck_id = ? AND next_review <= ?', [deckId, nowMs]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> update(Flashcard card) async {
    final db = await dbHelper.database;
    return db.update(
      'flashcards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'flashcards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
