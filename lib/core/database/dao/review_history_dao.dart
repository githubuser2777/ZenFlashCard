import '../../models/review_history.dart';
import '../database_helper.dart';

class ReviewHistoryDao {
  final dbHelper = DatabaseHelper.instance;

  Future<ReviewHistory> create(ReviewHistory log) async {
    final db = await dbHelper.database;
    await db.insert('review_history', log.toMap());
    return log;
  }

  Future<List<ReviewHistory>> getHistoryForDeck(String deckId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'review_history',
      where: 'deck_id = ?',
      whereArgs: [deckId],
      orderBy: 'reviewed_at DESC',
    );
    return result.map((json) => ReviewHistory.fromMap(json)).toList();
  }

  Future<Map<int, int>> getQualityDistribution() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT quality, COUNT(*) as count FROM review_history GROUP BY quality');
    
    Map<int, int> distribution = {0: 0, 3: 0, 5: 0};
    for (var row in result) {
      final quality = row['quality'] as int;
      final count = row['count'] as int;
      distribution[quality] = count;
    }
    return distribution;
  }
}
