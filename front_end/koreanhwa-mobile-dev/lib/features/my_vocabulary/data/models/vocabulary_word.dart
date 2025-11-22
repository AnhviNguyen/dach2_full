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
}

