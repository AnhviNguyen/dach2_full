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

  factory VocabularyFolder.fromJson(Map<String, dynamic> json) {
    List<VocabularyWord> words = [];
    if (json['words'] != null && json['words'] is List) {
      words = (json['words'] as List<dynamic>)
          .map((w) => VocabularyWord.fromJson(w as Map<String, dynamic>))
          .toList();
    }

    return VocabularyFolder(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '📁',
      words: words,
    );
  }
}

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

  VocabularyWord copyWith({
    int? id,
    String? korean,
    String? vietnamese,
    String? pronunciation,
    String? example,
    bool? isLearned,
  }) {
    return VocabularyWord(
      id: id ?? this.id,
      korean: korean ?? this.korean,
      vietnamese: vietnamese ?? this.vietnamese,
      pronunciation: pronunciation ?? this.pronunciation,
      example: example ?? this.example,
      isLearned: isLearned ?? this.isLearned,
    );
  }

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

