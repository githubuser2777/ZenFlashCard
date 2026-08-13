import 'package:flutter/foundation.dart';
import '../../core/models/study_log.dart';
import '../../core/database/dao/study_log_dao.dart';
import '../../core/database/dao/review_history_dao.dart';
import '../../core/database/dao/deck_dao.dart';
import '../../core/database/dao/card_dao.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';

class StatsViewModel extends ChangeNotifier {
  final StudyLogDao _studyLogDao = StudyLogDao();
  final ReviewHistoryDao _reviewHistoryDao = ReviewHistoryDao();
  final DeckDao _deckDao = DeckDao();
  final CardDao _cardDao = CardDao();

  int _streak = 0;
  List<int> _last7DaysActivity = List.filled(7, 0);
  Map<int, int> _qualityDistribution = {0: 0, 3: 0, 5: 0};
  int _totalDecks = 0;
  int _totalCards = 0;
  bool _isLoading = false;

  int get streak => _streak;
  List<int> get last7DaysActivity => _last7DaysActivity;
  Map<int, int> get qualityDistribution => _qualityDistribution;
  int get totalDecks => _totalDecks;
  int get totalCards => _totalCards;
  bool get isLoading => _isLoading;

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();

    await _calculateTotals();
    await _calculateQualityDistribution();
    await _calculate7DaysActivityAndStreak();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _calculateTotals() async {
    final decks = await _deckDao.readAll();
    _totalDecks = decks.length;
    
    _totalCards = 0;
    for (var deck in decks) {
      _totalCards += await _cardDao.getCardCountForDeck(deck.id);
    }
  }

  Future<void> _calculateQualityDistribution() async {
    _qualityDistribution = await _reviewHistoryDao.getQualityDistribution();
  }

  Future<void> _calculate7DaysActivityAndStreak() async {
    final logs = await _studyLogDao.getLogsForLastNDays(365); // load enough for streak
    if (logs.isEmpty) {
      _streak = 0;
      _last7DaysActivity = List.filled(7, 0);
      return;
    }

    // Group logs by date (midnight)
    Map<DateTime, int> cardsPerDay = {};
    for (var log in logs) {
      final date = DateTime.fromMillisecondsSinceEpoch(log.studiedAt);
      final midnight = DateTime(date.year, date.month, date.day);
      cardsPerDay[midnight] = (cardsPerDay[midnight] ?? 0) + log.cardsStudied;
    }

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    // Calculate 7 days activity
    _last7DaysActivity = List.filled(7, 0);
    for (int i = 0; i < 7; i++) {
      final targetDate = todayMidnight.subtract(Duration(days: 6 - i));
      _last7DaysActivity[i] = cardsPerDay[targetDate] ?? 0;
    }

    // Calculate streak
    int currentStreak = 0;
    DateTime checkDate = todayMidnight;
    
    if (cardsPerDay.containsKey(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else if (cardsPerDay.containsKey(checkDate.subtract(const Duration(days: 1)))) {
      // Allow 1 day skip (streak maintains if they studied yesterday)
      checkDate = checkDate.subtract(const Duration(days: 1));
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (cardsPerDay.containsKey(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    _streak = currentStreak;
  }
}
