import 'package:flutter_test/flutter_test.dart';
import 'package:zenflashcards/core/algorithms/sm2.dart';

void main() {
  group('SM-2 Spaced Repetition Algorithm Unit Tests', () {
    test('quality < 3 resets repetition to 0 and interval to 1', () {
      final result = calculateNextReview(
        repetition: 5,
        easiness: 2.5,
        intervalDays: 30,
        quality: 2,
      );
      expect(result.repetition, 0);
      expect(result.intervalDays, 1);
    });

    test('first correct review (rep 0 -> 1) yields interval = 1 day', () {
      final result = calculateNextReview(
        repetition: 0,
        easiness: 2.5,
        intervalDays: 1,
        quality: 5,
      );
      expect(result.repetition, 1);
      expect(result.intervalDays, 1);
    });

    test('second correct review (rep 1 -> 2) yields interval = 6 days', () {
      final result = calculateNextReview(
        repetition: 1,
        easiness: 2.5,
        intervalDays: 1,
        quality: 5,
      );
      expect(result.repetition, 2);
      expect(result.intervalDays, 6);
    });

    test('perfect quality (5) increases easiness factor above 2.5', () {
      final result = calculateNextReview(
        repetition: 2,
        easiness: 2.5,
        intervalDays: 6,
        quality: 5,
      );
      expect(result.easiness, greaterThan(2.5));
    });

    test('easiness factor never drops below 1.3 minimum boundary', () {
      final result = calculateNextReview(
        repetition: 3,
        easiness: 1.3,
        intervalDays: 10,
        quality: 0,
      );
      expect(result.easiness, greaterThanOrEqualTo(1.3));
    });

    test('nextReviewMs is always a future timestamp', () {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final result = calculateNextReview(
        repetition: 2,
        easiness: 2.5,
        intervalDays: 6,
        quality: 4,
      );
      expect(result.nextReviewMs, greaterThan(nowMs));
    });
  });
}
