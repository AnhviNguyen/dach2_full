import 'package:koreanhwa_flutter/features/ranking/data/models/ranking_entry.dart';

class RankingMockData {
  static final List<RankingEntry> rankingEntries = [
    RankingEntry(
      position: 1,
      name: 'Thành Tô',
      points: 2320,
      days: 10,
      isCurrentUser: false,
    ),
    RankingEntry(
      position: 2,
      name: 'Linh Kế',
      points: 2100,
      days: 8,
      isCurrentUser: false,
    ),
    RankingEntry(
      position: 3,
      name: 'Trang Tô C',
      points: 2000,
      days: 7,
      isCurrentUser: false,
    ),
    RankingEntry(
      position: 4,
      name: 'Minh Nguyễn',
      points: 1950,
      days: 9,
      isCurrentUser: false,
    ),
    RankingEntry(
      position: 5,
      name: 'Livia Vaccaro',
      points: 1800,
      days: 6,
      isCurrentUser: true,
    ),
    RankingEntry(
      position: 6,
      name: 'Hoa Lê',
      points: 1750,
      days: 8,
      isCurrentUser: false,
    ),
    RankingEntry(
      position: 7,
      name: 'Anh Đỗ',
      points: 1700,
      days: 5,
      isCurrentUser: false,
    ),
    RankingEntry(
      position: 8,
      name: 'Bình Trần',
      points: 1650,
      days: 7,
      isCurrentUser: false,
    ),
  ];
}

