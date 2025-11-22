import 'package:koreanhwa_flutter/models/vocabulary_folder_model.dart';

class VocabularyFolderService {
  static List<VocabularyFolder> _folders = [
    VocabularyFolder(
      id: 1,
      name: 'Từ vựng thường dùng',
      icon: '💬',
      words: [
        VocabularyWord(
          id: 1,
          korean: '물',
          vietnamese: 'Nước',
          pronunciation: 'mul',
          example: '물 한 잔 주세요.',
        ),
        VocabularyWord(
          id: 2,
          korean: '밥',
          vietnamese: 'Cơm',
          pronunciation: 'bap',
          example: '밥 먹었어요?',
        ),
        VocabularyWord(
          id: 3,
          korean: '집',
          vietnamese: 'Nhà',
          pronunciation: 'jip',
          example: '집에 가요.',
        ),
        VocabularyWord(
          id: 4,
          korean: '친구',
          vietnamese: 'Bạn bè',
          pronunciation: 'chingu',
          example: '친구를 만나요.',
        ),
      ],
    ),
    VocabularyFolder(
      id: 2,
      name: 'Gia đình',
      icon: '👨‍👩‍👧‍👦',
      words: [
        VocabularyWord(
          id: 5,
          korean: '가족',
          vietnamese: 'Gia đình',
          pronunciation: 'gajok',
          example: '우리 가족은 네 명입니다.',
        ),
        VocabularyWord(
          id: 6,
          korean: '어머니',
          vietnamese: 'Mẹ',
          pronunciation: 'eomeoni',
          example: '어머니는 요리를 잘해요.',
        ),
        VocabularyWord(
          id: 7,
          korean: '아버지',
          vietnamese: 'Bố',
          pronunciation: 'abeoji',
          example: '아버지는 회사에 가요.',
        ),
      ],
    ),
    VocabularyFolder(
      id: 3,
      name: 'Đi du lịch',
      icon: '✈️',
      words: [
        VocabularyWord(
          id: 8,
          korean: '공항',
          vietnamese: 'Sân bay',
          pronunciation: 'gonghang',
          example: '공항에 가요.',
        ),
        VocabularyWord(
          id: 9,
          korean: '호텔',
          vietnamese: 'Khách sạn',
          pronunciation: 'hotel',
          example: '호텔을 예약했어요.',
        ),
      ],
    ),
  ];

  static List<VocabularyFolder> getFolders() {
    return _folders;
  }

  static VocabularyFolder? getFolderById(int id) {
    try {
      return _folders.firstWhere((folder) => folder.id == id);
    } catch (e) {
      return null;
    }
  }

  static void addFolder(VocabularyFolder folder) {
    _folders.add(folder);
  }

  static void deleteFolder(int id) {
    _folders.removeWhere((folder) => folder.id == id);
  }

  static void updateFolder(VocabularyFolder updatedFolder) {
    final index = _folders.indexWhere((folder) => folder.id == updatedFolder.id);
    if (index != -1) {
      _folders[index] = updatedFolder;
    }
  }

  static void addWordToFolder(int folderId, VocabularyWord word) {
    final folder = getFolderById(folderId);
    if (folder != null) {
      final updatedWords = [...folder.words, word];
      updateFolder(folder.copyWith(words: updatedWords));
    }
  }

  static void deleteWordFromFolder(int folderId, int wordId) {
    final folder = getFolderById(folderId);
    if (folder != null) {
      final updatedWords = folder.words.where((word) => word.id != wordId).toList();
      updateFolder(folder.copyWith(words: updatedWords));
    }
  }

  static void updateWordInFolder(int folderId, VocabularyWord updatedWord) {
    final folder = getFolderById(folderId);
    if (folder != null) {
      final updatedWords = folder.words.map((word) {
        return word.id == updatedWord.id ? updatedWord : word;
      }).toList();
      updateFolder(folder.copyWith(words: updatedWords));
    }
  }
}

