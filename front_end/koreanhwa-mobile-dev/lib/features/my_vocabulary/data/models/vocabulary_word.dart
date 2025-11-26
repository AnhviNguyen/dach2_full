class VocabularyWord {
  final int id;
  final String korean;
  final String vietnamese;
  final String pronunciation;
  final String? example;
  final bool isLearned;

  VocabularyWord({
    required this.id,
    required this.korean,
    required this.vietnamese,
    required this.pronunciation,
    this.example,
    this.isLearned = false,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] as int,
      korean: json['korean'] as String? ?? '',
      vietnamese: json['vietnamese'] as String? ?? '',
      pronunciation: json['pronunciation'] as String? ?? '',
      example: json['example'] as String?,
      isLearned: json['isLearned'] as bool? ?? false,
    );
  }
}

