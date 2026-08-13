import 'package:sqflite/sqflite.dart';
import '../../models/study_log.dart';
import '../database_helper.dart';

class StudyLogDao {
  final dbHelper = DatabaseHelper.instance;

  Future<StudyLog> create(StudyLog log) async {
    final db = await dbHelper.database;
    await db.insert('study_logs', log.toMap());
    return log;
  }

  Future<List<StudyLog>> getLogsForDeck(String deckId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'study_logs',
      where: 'deck_id = ?',
      whereArgs: [deckId],
      orderBy: 'studied_at ASC',
    );
    return result.map((json) => StudyLog.fromMap(json)).toList();
  }

  Future<List<StudyLog>> getLogsForLastNDays(int days) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final threshold = now.subtract(Duration(days: days)).millisecondsSinceEpoch;
    final result = await db.query(
      'study_logs',
      where: 'studied_at >= ?',
      whereArgs: [threshold],
      orderBy: 'studied_at ASC',
    );
    return result.map((json) => StudyLog.fromMap(json)).toList();
  }
}
