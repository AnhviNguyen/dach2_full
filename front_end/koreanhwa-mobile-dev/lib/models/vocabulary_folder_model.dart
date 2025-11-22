class VocabularyFolder {
  final int id;
  final String name;
  final String icon;
  final List<VocabularyWord> words;

  VocabularyFolder({
    required this.id,
    required this.name,
    required this.icon,
    required this.words,
  });

  VocabularyFolder copyWith({
    int? id,
    String? name,
    String? icon,
    List<VocabularyWord>? words,
  }) {
    return VocabularyFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      words: words ?? this.words,
    );
  }
}

class VocabularyWord {
  final int id;
  final String korean;
  final String vietnamese;
  final String pronunciation;
  final String example;

  VocabularyWord({
    required this.id,
    required this.korean,
    required this.vietnamese,
    required this.pronunciation,
    required this.example,
  });

  VocabularyWord copyWith({
    int? id,
    String? korean,
    String? vietnamese,
    String? pronunciation,
    String? example,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      korean: korean ?? this.korean,
      vietnamese: vietnamese ?? this.vietnamese,
      pronunciation: pronunciation ?? this.pronunciation,
      example: example ?? this.example,
    );
  }
}

