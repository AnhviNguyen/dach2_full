import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition_category.dart';

class CompetitionMockData {
  static final List<CompetitionCategory> categories = const [
    CompetitionCategory(id: 'all', name: 'Tất cả', icon: Icons.emoji_events),
    CompetitionCategory(id: 'speaking', name: 'Nói', icon: Icons.mic),
    CompetitionCategory(id: 'writing', name: 'Viết', icon: Icons.edit),
    CompetitionCategory(id: 'listening', name: 'Nghe', icon: Icons.headphones),
    CompetitionCategory(id: 'reading', name: 'Đọc', icon: Icons.menu_book),
  ];
}

