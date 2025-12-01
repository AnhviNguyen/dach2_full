import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/topik/data/services/exam_result_service.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/screen/exam_result_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class ExamStatisticsScreen extends StatefulWidget {
  const ExamStatisticsScreen({super.key});

  @override
  State<ExamStatisticsScreen> createState() => _ExamStatisticsScreenState();
}

class _ExamStatisticsScreenState extends State<ExamStatisticsScreen> {
  List<ExamResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await ExamResultService.getExamResults();
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Tính toán thống kê tổng quan
  Map<String, dynamic> get _overallStats {
    if (_results.isEmpty) {
      return {
        'totalExams': 0,
        'totalQuestions': 0,
        'totalCorrect': 0,
        'totalWrong': 0,
        'totalSkipped': 0,
        'averageAccuracy': 0.0,
        'totalTimeSpent': 0,
      };
    }

    int totalExams = _results.length;
    int totalQuestions = 0;
    int totalCorrect = 0;
    int totalWrong = 0;
    int totalSkipped = 0;
    int totalTimeSpent = 0;
    double totalAccuracy = 0.0;

    for (var result in _results) {
      totalQuestions += result.questions.length;
      totalCorrect += result.correctCount;
      totalWrong += result.wrongCount;
      totalSkipped += result.skippedCount;
      totalTimeSpent += result.timeSpent;
      totalAccuracy += result.accuracy;
    }

    return {
      'totalExams': totalExams,
      'totalQuestions': totalQuestions,
      'totalCorrect': totalCorrect,
      'totalWrong': totalWrong,
      'totalSkipped': totalSkipped,
      'averageAccuracy': totalAccuracy / totalExams,
      'totalTimeSpent': totalTimeSpent,
    };
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${secs}s';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final stats = _overallStats;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack)),
        ),
        title: Text(
          'Thống kê kết quả',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assessment_outlined,
                        size: 64,
                        color: AppColors.primaryBlack.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có kết quả nào',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryBlack.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hoàn thành bài thi để xem thống kê',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryBlack.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overall Stats Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryYellow.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tổng quan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatItem(
                                    'Số bài thi',
                                    '${stats['totalExams']}',
                                    Icons.quiz,
                                    AppColors.primaryYellow,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatItem(
                                    'Tổng câu hỏi',
                                    '${stats['totalQuestions']}',
                                    Icons.help_outline,
                                    AppColors.primaryBlack,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatItem(
                                    'Độ chính xác',
                                    '${(stats['averageAccuracy'] * 100).toStringAsFixed(1)}%',
                                    Icons.trending_up,
                                    AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatItem(
                                    'Thời gian',
                                    _formatTime(stats['totalTimeSpent']),
                                    Icons.access_time,
                                    const Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Chart
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryYellow.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Phân bố kết quả',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 180,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      value: stats['totalCorrect'].toDouble(),
                                      color: AppColors.success,
                                      title: 'Đúng\n${stats['totalCorrect']}',
                                      radius: 60,
                                      titleStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: stats['totalWrong'].toDouble(),
                                      color: const Color(0xFFF44336),
                                      title: 'Sai\n${stats['totalWrong']}',
                                      radius: 60,
                                      titleStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                    if (stats['totalSkipped'] > 0)
                                      PieChartSectionData(
                                        value: stats['totalSkipped'].toDouble(),
                                        color: AppColors.primaryBlack.withOpacity(0.4),
                                        title: 'Bỏ qua\n${stats['totalSkipped']}',
                                        radius: 60,
                                        titleStyle: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).cardColor,
                                        ),
                                      ),
                                  ],
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Results List
                      const Text(
                        'Lịch sử làm bài',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._results.map((result) {
                        return _buildResultCard(result);
                      }).toList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(ExamResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryYellow.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExamResultScreen(
                examId: result.examId,
                examTitle: result.examTitle,
                answers: result.answers,
                questions: result.questions,
                timeSpent: result.timeSpent,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    result.examTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(result.accuracy * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMiniStat(
                  'Đúng',
                  result.correctCount.toString(),
                  AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildMiniStat(
                  'Sai',
                  result.wrongCount.toString(),
                  const Color(0xFFF44336),
                ),
                const SizedBox(width: 8),
                _buildMiniStat(
                  'Bỏ qua',
                  result.skippedCount.toString(),
                  AppColors.primaryBlack.withOpacity(0.4),
                ),
                const Spacer(),
                Text(
                  _formatDate(result.completedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryBlack.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.primaryBlack.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(result.timeSpent),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlack.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.help_outline,
                  size: 14,
                  color: AppColors.primaryBlack.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '${result.questions.length} câu',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlack.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Answer preview
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: result.questions.take(10).map((question) {
                final questionId = question['id'] as int;
                final userAnswer = result.answers[questionId];
                final correctAnswer = 'B'; // Tạm thời
                final isCorrect = userAnswer != null && userAnswer == correctAnswer;
                
                Color color;
                if (userAnswer == null) {
                  color = AppColors.primaryBlack.withOpacity(0.4);
                } else if (isCorrect) {
                  color = AppColors.success;
                } else {
                  color = const Color(0xFFF44336);
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color, width: 1),
                  ),
                  child: Text(
                    questionId.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

