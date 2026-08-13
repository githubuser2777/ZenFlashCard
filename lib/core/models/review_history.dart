class ReviewHistory {
  final String id;
  final String cardId;
  final String deckId;
  final int quality;
  final int reviewedAt;

  ReviewHistory({
    required this.id,
    required this.cardId,
    required this.deckId,
    required this.quality,
    required this.reviewedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_id': cardId,
      'deck_id': deckId,
      'quality': quality,
      'reviewed_at': reviewedAt,
    };
  }

  factory ReviewHistory.fromMap(Map<String, dynamic> map) {
    return ReviewHistory(
      id: map['id'],
      cardId: map['card_id'],
      deckId: map['deck_id'],
      quality: map['quality'],
      reviewedAt: map['reviewed_at'],
    );
  }
}
