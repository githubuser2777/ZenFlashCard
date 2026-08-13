class Flashcard {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final int repetition;
  final double easiness;
  final int interval;
  final int nextReview;
  final int createdAt;

  Flashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.repetition = 0,
    this.easiness = 2.5,
    this.interval = 1,
    required this.nextReview,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deck_id': deckId,
      'front': front,
      'back': back,
      'repetition': repetition,
      'easiness': easiness,
      'interval': interval,
      'next_review': nextReview,
      'created_at': createdAt,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      deckId: map['deck_id'],
      front: map['front'],
      back: map['back'],
      repetition: map['repetition'] ?? 0,
      easiness: map['easiness'] ?? 2.5,
      interval: map['interval'] ?? 1,
      nextReview: map['next_review'],
      createdAt: map['created_at'],
    );
  }
}
