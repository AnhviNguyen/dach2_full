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
  final bool isParticipated;
  final int? userScore;
  final int? userRank;

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
    this.isParticipated = false,
    this.userScore,
    this.userRank,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    String status = json['status'] as String? ?? 'upcoming';
    DateTime? startDate = json['startDate'] != null ? parseDateTime(json['startDate']) : null;
    DateTime? endDate = json['endDate'] != null ? parseDateTime(json['endDate']) : null;
    
    // Map categoryId to category name
    String category = json['categoryName'] as String? ?? json['categoryId'] as String? ?? 'general';
    
    // Determine difficulty from prize or other fields (default to medium)
    String difficulty = 'Trung bình';
    
    // Calculate time limit from start and end dates
    String timeLimit = '60 phút';
    if (startDate != null && endDate != null) {
      final duration = endDate.difference(startDate);
      final hours = duration.inHours;
      if (hours > 0) {
        timeLimit = '$hours giờ';
      } else {
        final minutes = duration.inMinutes;
        timeLimit = '$minutes phút';
      }
    }

    return Competition(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: category,
      difficulty: difficulty,
      timeLimit: timeLimit,
      entryFee: 0, // Not in backend response
      totalPrize: 0, // Parse from prize string if needed
      participants: json['participants'] as int? ?? 0,
      deadline: endDate ?? DateTime.now().add(const Duration(days: 7)),
      status: status,
      tags: [], // Not in backend response
      image: json['image'] as String?,
      mySubmission: json['isParticipated'] == true && json['userScore'] != null
          ? CompetitionSubmission(
              submitted: true,
              score: json['userScore'] as int?,
              rank: json['userRank'] as int?,
              submittedAt: json['createdAt'] != null ? parseDateTime(json['createdAt']) : null,
            )
          : null,
      stats: null, // Not in backend response
      isParticipated: json['isParticipated'] as bool? ?? false,
      userScore: json['userScore'] as int?,
      userRank: json['userRank'] as int?,
    );
  }
}

