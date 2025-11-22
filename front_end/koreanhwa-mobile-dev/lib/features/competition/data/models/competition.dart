import 'package:koreanhwa_flutter/features/competition/data/models/competition_submission.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition_stats.dart';

class Competition {
  final int id;
  final String title;
  final String description;
  final String category; // 'speaking', 'writing', 'listening', 'reading'
  final String difficulty; // 'Dễ', 'Trung bình', 'Khó'
  final String timeLimit;
  final int entryFee;
  final int totalPrize;
  final int participants;
  final DateTime deadline;
  final String status; // 'active', 'upcoming', 'completed'
  final List<String> tags;
  final String? image;
  final CompetitionSubmission? mySubmission;
  final CompetitionStats? stats;

  Competition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.timeLimit,
    required this.entryFee,
    required this.totalPrize,
    required this.participants,
    required this.deadline,
    required this.status,
    required this.tags,
    this.image,
    this.mySubmission,
    this.stats,
  });
}

