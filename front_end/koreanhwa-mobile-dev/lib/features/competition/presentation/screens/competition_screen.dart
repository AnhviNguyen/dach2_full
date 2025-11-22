import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/models/competition_model.dart';
import 'package:koreanhwa_flutter/services/competition_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class CompetitionScreen extends StatefulWidget {
  const CompetitionScreen({super.key});

  @override
  State<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends State<CompetitionScreen> {
  String _selectedCategory = 'all';
  String _selectedStatus = 'active';
  String _sortBy = 'recent';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'Tất cả', 'icon': Icons.emoji_events},
    {'id': 'speaking', 'name': 'Nói', 'icon': Icons.mic},
    {'id': 'writing', 'name': 'Viết', 'icon': Icons.edit},
    {'id': 'listening', 'name': 'Nghe', 'icon': Icons.headphones},
    {'id': 'reading', 'name': 'Đọc', 'icon': Icons.menu_book},
  ];

  @override
  Widget build(BuildContext context) {
    final competitions = CompetitionService.getCompetitions(
      category: _selectedCategory == 'all' ? null : _selectedCategory,
      status: _selectedStatus,
      sortBy: _sortBy,
    ).where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        title: const Text(
          'Cuộc thi',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events, color: AppColors.primaryBlack),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.primaryBlack),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryWhite,
            child: Column(
              children: [
                // Search
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm cuộc thi...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.grayLight),
                    filled: true,
                    fillColor: AppColors.whiteGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),
                // Category Filter
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category['id'];
                      return FilterChip(
                        label: Text(category['name']),
                        avatar: Icon(category['icon'], size: 18),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category['id']);
                        },
                        selectedColor: AppColors.primaryYellow,
                        checkmarkColor: AppColors.primaryBlack,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primaryBlack : AppColors.primaryBlack,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // Sort
                Row(
                  children: [
                    const Text('Sắp xếp: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        underline: Container(),
                        items: const [
                          DropdownMenuItem(value: 'recent', child: Text('Mới nhất')),
                          DropdownMenuItem(value: 'popular', child: Text('Phổ biến')),
                          DropdownMenuItem(value: 'deadline', child: Text('Hạn chót')),
                          DropdownMenuItem(value: 'prize', child: Text('Giải thưởng')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _sortBy = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status Tabs
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStatusTab('active', 'Đang diễn ra', Icons.trending_up, 8),
                const SizedBox(width: 8),
                _buildStatusTab('upcoming', 'Sắp diễn ra', Icons.calendar_today, 3),
                const SizedBox(width: 8),
                _buildStatusTab('completed', 'Đã kết thúc', Icons.check_circle, 15),
                const SizedBox(width: 8),
                _buildStatusTab('my', 'Của tôi', Icons.favorite, 5),
              ],
            ),
          ),
          // Competitions List
          Expanded(
            child: competitions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.grayLight),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy cuộc thi nào',
                          style: TextStyle(color: AppColors.grayLight),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: competitions.length,
                    itemBuilder: (context, index) {
                      return _buildCompetitionCard(competitions[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(String status, String label, IconData icon, int count) {
    final isSelected = _selectedStatus == status;
    return InkWell(
      onTap: () => setState(() => _selectedStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryYellow : AppColors.whiteGray,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryYellow : AppColors.grayLight.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primaryBlack),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitionCard(Competition competition) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryYellow,
                  AppColors.primaryYellow.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        competition.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        competition.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryBlack.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: competition.status == 'active'
                        ? AppColors.success
                        : competition.status == 'upcoming'
                            ? AppColors.info
                            : AppColors.grayLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    competition.status == 'active'
                        ? 'Đang diễn ra'
                        : competition.status == 'upcoming'
                            ? 'Sắp diễn ra'
                            : 'Đã kết thúc',
                    style: const TextStyle(
                      color: AppColors.primaryWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: competition.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        Icons.people,
                        '${competition.participants}',
                        'Tham gia',
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        Icons.emoji_events,
                        '${(competition.totalPrize / 1000000).toStringAsFixed(0)}M',
                        'Giải thưởng',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Details
                _buildDetailRow('Độ khó:', _getDifficultyBadge(competition.difficulty)),
                const SizedBox(height: 8),
                _buildDetailRow('Thời gian:', Text(competition.timeLimit)),
                const SizedBox(height: 8),
                _buildDetailRow('Phí tham gia:', Text(competition.entryFee == 0 ? 'Miễn phí' : '${_formatNumber(competition.entryFee)}đ')),
                const SizedBox(height: 8),
                _buildDetailRow('Hạn chót:', Text(_formatDate(competition.deadline))),
                // My Submission
                if (competition.mySubmission?.submitted == true) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryYellow),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bài nộp của bạn',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Điểm: ${competition.mySubmission!.score}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                          ],
                        ),
                        if (competition.mySubmission!.rank != null) ...[
                          const SizedBox(height: 8),
                          Text('Xếp hạng: #${competition.mySubmission!.rank}'),
                        ],
                        if (competition.mySubmission!.feedback != null) ...[
                          const SizedBox(height: 8),
                          Text(competition.mySubmission!.feedback!),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.whiteGray,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.grayLight),
                    ),
                    child: const Center(
                      child: Text(
                        'Chưa tham gia',
                        style: TextStyle(color: AppColors.grayLight),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/competition/info', extra: competition);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlack,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      competition.mySubmission?.submitted == true ? 'Xem chi tiết' : 'Tham gia ngay',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryYellow, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grayLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.grayLight,
            fontSize: 14,
          ),
        ),
        value,
      ],
    );
  }

  Widget _getDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty) {
      case 'Dễ':
        color = AppColors.success;
        break;
      case 'Trung bình':
        color = AppColors.primaryYellow;
        break;
      case 'Khó':
        color = AppColors.error;
        break;
      default:
        color = AppColors.grayLight;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        difficulty,
        style: const TextStyle(
          color: AppColors.primaryWhite,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatNumber(int number) {
    final numberStr = number.toString();
    final reversed = numberStr.split('').reversed.join();
    final chunks = <String>[];
    for (int i = 0; i < reversed.length; i += 3) {
      chunks.add(reversed.substring(i, (i + 3 > reversed.length) ? reversed.length : i + 3));
    }
    return chunks.join('.').split('').reversed.join();
  }
}

