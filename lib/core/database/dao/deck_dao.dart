import '../../models/deck.dart';
import '../database_helper.dart';

class DeckDao {
  final dbHelper = DatabaseHelper.instance;

  Future<Deck> create(Deck deck) async {
    final db = await dbHelper.database;
    await db.insert('decks', deck.toMap());
    return deck;
  }

  Future<Deck?> read(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'decks',
      columns: [
        'id',
        'name',
        'description',
        'language_front',
        'language_back',
        'created_at'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Deck.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Deck>> readAll() async {
    final db = await dbHelper.database;
    const orderBy = 'created_at DESC';
    final result = await db.query('decks', orderBy: orderBy);
    return result.map((json) => Deck.fromMap(json)).toList();
  }

  Future<int> update(Deck deck) async {
    final db = await dbHelper.database;
    return db.update(
      'decks',
      deck.toMap(),
      where: 'id = ?',
      whereArgs: [deck.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'decks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
