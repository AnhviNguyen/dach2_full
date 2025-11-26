import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition.dart';
import 'package:koreanhwa_flutter/features/competition/data/services/competition_api_service.dart';
import 'package:koreanhwa_flutter/features/competition/data/competition_mock_data.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/widgets/competition_card.dart';
import 'package:koreanhwa_flutter/features/competition/presentation/widgets/competition_status_tab.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';

class CompetitionScreen extends ConsumerStatefulWidget {
  const CompetitionScreen({super.key});

  @override
  ConsumerState<CompetitionScreen> createState() => _CompetitionScreenState();
}

class _CompetitionScreenState extends ConsumerState<CompetitionScreen> {
  String _selectedCategory = 'all';
  String _selectedStatus = 'active';
  String _sortBy = 'recent';
  String _searchQuery = '';
  final CompetitionApiService _apiService = CompetitionApiService();
  List<Competition> _competitions = [];
  List<Competition> _activeCompetitions = [];
  List<Competition> _upcomingCompetitions = [];
  List<Competition> _completedCompetitions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCompetitions();
  }

  Future<void> _loadCompetitions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = ref.read(authProvider).user?.id;

      // Load all statuses
      final activeResponse = await _apiService.getCompetitionsByStatus('active', currentUserId: userId, size: 100);
      final upcomingResponse = await _apiService.getCompetitionsByStatus('upcoming', currentUserId: userId, size: 100);
      final completedResponse = await _apiService.getCompetitionsByStatus('completed', currentUserId: userId, size: 100);

      // Remove duplicates by ID within each status list
      final List<Competition> uniqueActive = [];
      final List<Competition> uniqueUpcoming = [];
      final List<Competition> uniqueCompleted = [];
      
      final Set<int> activeIds = {};
      final Set<int> upcomingIds = {};
      final Set<int> completedIds = {};

      // Remove duplicates in active list
      for (var comp in activeResponse.content) {
        if (!activeIds.contains(comp.id)) {
          activeIds.add(comp.id);
          uniqueActive.add(comp);
        }
      }

      // Remove duplicates in upcoming list
      for (var comp in upcomingResponse.content) {
        if (!upcomingIds.contains(comp.id)) {
          upcomingIds.add(comp.id);
          uniqueUpcoming.add(comp);
        }
      }

      // Remove duplicates in completed list
      for (var comp in completedResponse.content) {
        if (!completedIds.contains(comp.id)) {
          completedIds.add(comp.id);
          uniqueCompleted.add(comp);
        }
      }

      setState(() {
        _activeCompetitions = uniqueActive;
        _upcomingCompetitions = uniqueUpcoming;
        _completedCompetitions = uniqueCompleted;
        _updateFilteredCompetitions();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _updateFilteredCompetitions() {
    List<Competition> source = [];
    switch (_selectedStatus) {
      case 'active':
        source = _activeCompetitions;
        break;
      case 'upcoming':
        source = _upcomingCompetitions;
        break;
      case 'completed':
        source = _completedCompetitions;
        break;
      default:
        source = _activeCompetitions;
    }

    _competitions = source.where((c) {
      // Filter by category
      if (_selectedCategory != 'all' && c.category != _selectedCategory) {
        return false;
      }
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        return c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'popular':
        _competitions.sort((a, b) => b.participants.compareTo(a.participants));
        break;
      case 'deadline':
        _competitions.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      case 'prize':
        _competitions.sort((a, b) => b.totalPrize.compareTo(a.totalPrize));
        break;
      case 'recent':
      default:
        _competitions.sort((a, b) => b.deadline.compareTo(a.deadline));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

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
                    _updateFilteredCompetitions();
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
                          _updateFilteredCompetitions();
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
                          if (value != null) {
                            setState(() => _sortBy = value);
                            _updateFilteredCompetitions();
                          }
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
                  count: _activeCompetitions.length,
                  isSelected: _selectedStatus == 'active',
                  onTap: () {
                    setState(() => _selectedStatus = 'active');
                    _updateFilteredCompetitions();
                  },
                ),
                const SizedBox(width: 8),
                CompetitionStatusTab(
                  value: 'upcoming',
                  label: 'Sắp diễn ra',
                  icon: Icons.schedule,
                  count: _upcomingCompetitions.length,
                  isSelected: _selectedStatus == 'upcoming',
                  onTap: () {
                    setState(() => _selectedStatus = 'upcoming');
                    _updateFilteredCompetitions();
                  },
                ),
                const SizedBox(width: 8),
                CompetitionStatusTab(
                  value: 'completed',
                  label: 'Đã kết thúc',
                  icon: Icons.check_circle,
                  count: _completedCompetitions.length,
                  isSelected: _selectedStatus == 'completed',
                  onTap: () {
                    setState(() => _selectedStatus = 'completed');
                    _updateFilteredCompetitions();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppColors.primaryBlack),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadCompetitions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryYellow,
                                foregroundColor: AppColors.primaryBlack,
                              ),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _competitions.isEmpty
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
                            itemCount: _competitions.length,
                            itemBuilder: (context, index) {
                              return CompetitionCard(competition: _competitions[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

