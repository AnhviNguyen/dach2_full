class VocabularyItem {
  final String korean;
  final String vietnamese;
  final String pronunciation;
  final String? example;

  VocabularyItem({
    required this.korean,
    required this.vietnamese,
    required this.pronunciation,
    this.example,
  });
}

