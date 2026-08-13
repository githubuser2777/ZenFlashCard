class Deck {
  final String id;
  final String name;
  final String? description;
  final String languageFront;
  final String languageBack;
  final int createdAt;

  Deck({
    required this.id,
    required this.name,
    this.description,
    required this.languageFront,
    required this.languageBack,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'language_front': languageFront,
      'language_back': languageBack,
      'created_at': createdAt,
    };
  }

  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      languageFront: map['language_front'],
      languageBack: map['language_back'],
      createdAt: map['created_at'],
    );
  }
}
