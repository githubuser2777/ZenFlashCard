import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('zen_flashcards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // 1. decks table
    await db.execute('''
      CREATE TABLE decks (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        language_front TEXT NOT NULL,
        language_back TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // 2. flashcards table
    await db.execute('''
      CREATE TABLE flashcards (
        id TEXT PRIMARY KEY,
        deck_id TEXT NOT NULL,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        repetition INTEGER DEFAULT 0,
        easiness REAL DEFAULT 2.5,
        interval INTEGER DEFAULT 1,
        next_review INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (deck_id) REFERENCES decks(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_flashcards_deck ON flashcards(deck_id)');
    await db.execute('CREATE INDEX idx_flashcards_next_review ON flashcards(next_review)');

    // 3. study_logs table
    await db.execute('''
      CREATE TABLE study_logs (
        id TEXT PRIMARY KEY,
        deck_id TEXT NOT NULL,
        cards_studied INTEGER NOT NULL,
        correct INTEGER NOT NULL,
        studied_at INTEGER NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_study_logs_date ON study_logs(studied_at)');

    // 4. review_history table
    await db.execute('''
      CREATE TABLE review_history (
        id TEXT PRIMARY KEY,
        card_id TEXT NOT NULL,
        deck_id TEXT NOT NULL,
        quality INTEGER NOT NULL,
        reviewed_at INTEGER NOT NULL,
        FOREIGN KEY (card_id) REFERENCES flashcards(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_review_history_card ON review_history(card_id)');
    await db.execute('CREATE INDEX idx_review_history_deck ON review_history(deck_id)');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
