class VocabularyService {
  static final Map<String, List<Map<String, String>>> vocabData = {
    '1-1': [
      {
        'korean': '안녕하세요',
        'vietnamese': 'Xin chào',
        'pronunciation': 'annyeonghaseyo',
        'example': '안녕하세요! 저는 민수입니다.'
      },
      {
        'korean': '감사합니다',
        'vietnamese': 'Cảm ơn',
        'pronunciation': 'gamsahamnida',
        'example': '도와주셔서 감사합니다.'
      },
      {
        'korean': '미안합니다',
        'vietnamese': 'Xin lỗi',
        'pronunciation': 'mianhamnida',
        'example': '늦어서 미안합니다.'
      },
      {
        'korean': '네',
        'vietnamese': 'Vâng/Có',
        'pronunciation': 'ne',
        'example': '네, 알겠습니다.'
      },
      {
        'korean': '아니요',
        'vietnamese': 'Không',
        'pronunciation': 'aniyo',
        'example': '아니요, 괜찮아요.'
      },
      {
        'korean': '이름',
        'vietnamese': 'Tên',
        'pronunciation': 'ireum',
        'example': '당신의 이름은 무엇입니까?'
      },
      {
        'korean': '학생',
        'vietnamese': 'Học sinh',
        'pronunciation': 'haksaeng',
        'example': '저는 대학생입니다.'
      },
      {
        'korean': '선생님',
        'vietnamese': 'Giáo viên',
        'pronunciation': 'seonsaengnim',
        'example': '김 선생님은 친절합니다.'
      },
    ],
  };

  static List<Map<String, String>> getVocabularyList(int bookId, int lessonId) {
    final key = '$bookId-$lessonId';
    return vocabData[key] ?? vocabData['1-1']!;
  }
}

