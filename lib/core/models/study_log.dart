class StudyLog {
  final String id;
  final String deckId;
  final int cardsStudied;
  final int correct;
  final int studiedAt;

  StudyLog({
    required this.id,
    required this.deckId,
    required this.cardsStudied,
    required this.correct,
    required this.studiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deck_id': deckId,
      'cards_studied': cardsStudied,
      'correct': correct,
      'studied_at': studiedAt,
    };
  }

  factory StudyLog.fromMap(Map<String, dynamic> map) {
    return StudyLog(
      id: map['id'],
      deckId: map['deck_id'],
      cardsStudied: map['cards_studied'],
      correct: map['correct'],
      studiedAt: map['studied_at'],
    );
  }
}
