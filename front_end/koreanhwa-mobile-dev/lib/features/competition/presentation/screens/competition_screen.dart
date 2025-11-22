import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/services/competition_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition.dart';
import 'package:koreanhwa_flutter/features/competition/data/competition_mock_data.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/widgets/competition_card.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/widgets/competition_status_tab.dart';

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

    final activeCount = CompetitionService.getCompetitions(status: 'active').length;
    final upcomingCount = CompetitionService.getCompetitions(status: 'upcoming').length;
    final completedCount = CompetitionService.getCompetitions(status: 'completed').length;

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
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryWhite,
            child: Column(
              children: [
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
                SizedBox(
                  height: 50,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: CompetitionMockData.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = CompetitionMockData.categories[index];
                      final isSelected = _selectedCategory == category.id;
                      return FilterChip(
                        label: Text(category.name),
                        avatar: Icon(category.icon, size: 18),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category.id);
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
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                CompetitionStatusTab(
                  value: 'active',
                  label: 'Đang diễn ra',
                  icon: Icons.trending_up,
                  count: activeCount,
                  isSelected: _selectedStatus == 'active',
                  onTap: () => setState(() => _selectedStatus = 'active'),
                ),
                const SizedBox(width: 8),
                CompetitionStatusTab(
                  value: 'upcoming',
                  label: 'Sắp diễn ra',
                  icon: Icons.schedule,
                  count: upcomingCount,
                  isSelected: _selectedStatus == 'upcoming',
                  onTap: () => setState(() => _selectedStatus = 'upcoming'),
                ),
                const SizedBox(width: 8),
                CompetitionStatusTab(
                  value: 'completed',
                  label: 'Đã kết thúc',
                  icon: Icons.check_circle,
                  count: completedCount,
                  isSelected: _selectedStatus == 'completed',
                  onTap: () => setState(() => _selectedStatus = 'completed'),
                ),
              ],
            ),
          ),
          Expanded(
            child: competitions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 64,
                          color: AppColors.primaryBlack.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy cuộc thi',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryBlack.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: competitions.length,
                    itemBuilder: (context, index) {
                      return CompetitionCard(competition: competitions[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

