import 'package:koreanhwa_flutter/features/my_vocabulary/data/models/vocabulary_word.dart';

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
}

