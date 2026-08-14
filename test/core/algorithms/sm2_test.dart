import 'package:flutter_test/flutter_test.dart';
import 'package:zen_flash_cards/core/algorithms/sm2.dart';

void main() {
  group('SM-2 Algorithm Tests', () {
    test('quality < 3 resets repetition to 0 and interval to 1', () {
      final result = calculateNextReview(
        repetition: 5,
        easiness: 2.5,
        intervalDays: 14,
        quality: 0,
      );

      expect(result.repetition, 0);
      expect(result.intervalDays, 1);
      expect(result.easiness, closeTo(1.7, 0.01));
    });

    test('1st correct review sets interval to 1', () {
      final result = calculateNextReview(
        repetition: 0,
        easiness: 2.5,
        intervalDays: 1,
        quality: 3,
      );

      expect(result.repetition, 1);
      expect(result.intervalDays, 1);
    });

    test('2nd correct review sets interval to 6', () {
      final result = calculateNextReview(
        repetition: 1,
        easiness: 2.5,
        intervalDays: 1,
        quality: 3, // OK
      );

      expect(result.repetition, 2);
      expect(result.intervalDays, 6);
    });

    test('quality = 5 (Easy) increases easiness > 2.5', () {
      final result = calculateNextReview(
        repetition: 2,
        easiness: 2.5,
        intervalDays: 6,
        quality: 5,
      );

      expect(result.repetition, 3);
      expect(result.intervalDays, 15);
      expect(result.easiness, closeTo(2.6, 0.01));
    });

    test('Sharp EF decrease never drops below 1.3', () {
      final result = calculateNextReview(
        repetition: 0,
        easiness: 1.5,
        intervalDays: 1,
        quality: 0, // Hard
      );

      expect(result.easiness, greaterThanOrEqualTo(1.3));
    });

    test('next_review is always a future date', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final result = calculateNextReview(
        repetition: 2,
        easiness: 2.5,
        intervalDays: 6,
        quality: 3,
      );

      expect(result.nextReviewMs, greaterThan(now));
    });

    test('out-of-range quality is safely clamped to 0..5', () {
      final negativeRes = calculateNextReview(
        repetition: 2,
        easiness: 2.5,
        intervalDays: 6,
        quality: -99,
      );
      expect(negativeRes.repetition, 0); // Treated as 0 (Hard)

      final excessRes = calculateNextReview(
        repetition: 2,
        easiness: 2.5,
        intervalDays: 6,
        quality: 99,
      );
      expect(excessRes.repetition, 3); // Treated as 5 (Easy)
      expect(excessRes.easiness, closeTo(2.6, 0.01));
    });
  });
}
