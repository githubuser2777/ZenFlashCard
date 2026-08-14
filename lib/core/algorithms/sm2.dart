/// Result object returned by SM-2 algorithm calculation
class SM2Result {
  final int repetition;
  final double easiness;
  final int intervalDays;
  final int nextReviewMs; // Unix milliseconds

  const SM2Result({
    required this.repetition,
    required this.easiness,
    required this.intervalDays,
    required this.nextReviewMs,
  });
}

/// SM-2 Spaced Repetition Algorithm Implementation
/// Quality scale: 0 = Hard/Blackout, 3 = OK, 5 = Easy/Perfect
SM2Result calculateNextReview({
  required int repetition,
  required double easiness,
  required int intervalDays,
  required int quality,
}) {
  // Validate and clamp quality to standard SM-2 0-5 range
  final clampedQuality = quality.clamp(0, 5);

  // If quality < 3, reset repetition count to 0
  int newRep = clampedQuality < 3 ? 0 : repetition + 1;

  // Calculate new interval in days
  int newInterval;
  if (newRep <= 1) {
    newInterval = 1;
  } else if (newRep == 2) {
    newInterval = 6;
  } else {
    newInterval = (intervalDays * easiness).round();
  }

  // Calculate new easiness factor
  double newEasiness = easiness +
      (0.1 - (5 - clampedQuality) * (0.08 + (5 - clampedQuality) * 0.02));
  if (newEasiness < 1.3) newEasiness = 1.3; // Minimum boundary for EF

  final nextMs =
      DateTime.now().add(Duration(days: newInterval)).millisecondsSinceEpoch;

  return SM2Result(
    repetition: newRep,
    easiness: newEasiness,
    intervalDays: newInterval,
    nextReviewMs: nextMs,
  );
}
