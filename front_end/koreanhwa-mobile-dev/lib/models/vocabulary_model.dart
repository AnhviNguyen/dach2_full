class VocabularyItem {
  final String korean;
  final String vietnamese;
  final String pronunciation;
  final String example;

  VocabularyItem({
    required this.korean,
    required this.vietnamese,
    required this.pronunciation,
    required this.example,
  });

  Map<String, String> toMap() {
    return {
      'korean': korean,
      'vietnamese': vietnamese,
      'pronunciation': pronunciation,
      'example': example,
    };
  }

  factory VocabularyItem.fromMap(Map<String, String> map) {
    return VocabularyItem(
      korean: map['korean'] ?? '',
      vietnamese: map['vietnamese'] ?? '',
      pronunciation: map['pronunciation'] ?? '',
      example: map['example'] ?? '',
    );
  }
}

class MatchCard {
  final String id;
  final String text;
  final String type; // 'korean' or 'vietnamese'
  final int matchId;

  MatchCard({
    required this.id,
    required this.text,
    required this.type,
    required this.matchId,
  });
}

