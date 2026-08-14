import 'package:flutter/foundation.dart';
import '../../core/repositories/stats_repository.dart';

class StatsViewModel extends ChangeNotifier {
  final StatsRepository _repository;

  StatsViewModel({required StatsRepository repository}) : _repository = repository;

  int _streak = 0;
  List<int> _last7DaysActivity = List.filled(7, 0);
  Map<int, int> _qualityDistribution = {0: 0, 3: 0, 5: 0};
  int _totalDecks = 0;
  int _totalCards = 0;
  bool _isLoading = false;
  String? _error;

  int get streak => _streak;
  List<int> get last7DaysActivity => _last7DaysActivity;
  Map<int, int> get qualityDistribution => _qualityDistribution;
  int get totalDecks => _totalDecks;
  int get totalCards => _totalCards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _calculateTotals();
    await _calculateQualityDistribution();
    await _calculate7DaysActivityAndStreak();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _calculateTotals() async {
    final decksResult = await _repository.getAllDecks();
    await decksResult.fold(
      (failure) async => _error = failure.message,
      (decks) async {
        _totalDecks = decks.length;
        _totalCards = 0;
        for (var deck in decks) {
          final countResult = await _repository.getCardCountForDeck(deck.id);
          countResult.fold(
            (_) => null,
            (count) => _totalCards += count,
          );
        }
      }
    );
  }

  Future<void> _calculateQualityDistribution() async {
    final result = await _repository.getQualityDistribution();
    result.fold(
      (failure) => _error = failure.message,
      (data) => _qualityDistribution = data,
    );
  }

  Future<void> _calculate7DaysActivityAndStreak() async {
    final logsResult = await _repository.getLogsForLastNDays(365); // load enough for streak
    
    logsResult.fold(
      (failure) => _error = failure.message,
      (logs) {
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
    );
  }
}
