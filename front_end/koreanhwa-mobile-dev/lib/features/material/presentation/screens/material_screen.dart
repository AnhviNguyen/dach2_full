import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/material/data/models/learning_material.dart';
import 'package:koreanhwa_flutter/features/material/data/services/material_api_service.dart';
import 'package:koreanhwa_flutter/features/material/presentation/widgets/material_stat_card.dart';
import 'package:koreanhwa_flutter/features/material/presentation/widgets/material_card.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';

class MaterialScreen extends ConsumerStatefulWidget {
  const MaterialScreen({super.key});

  @override
  ConsumerState<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends ConsumerState<MaterialScreen> {
  String _searchQuery = '';
  String _selectedLevel = 'all';
  String _selectedSkill = 'all';
  String _selectedType = 'all';
  final MaterialApiService _apiService = MaterialApiService();
  List<LearningMaterial> _materials = [];
  List<LearningMaterial> _featured = [];
  int _downloadedCount = 0;
  int _totalCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = ref.read(authProvider).user?.id;
      final userPoints = ref.read(authProvider).user?.points ?? 0;

      // Load featured materials
      final featured = await _apiService.getFeaturedMaterials(currentUserId: userId);

      // Load downloaded count
      if (userId != null) {
        _downloadedCount = await _apiService.getDownloadedMaterialsCount(userId);
      }

      // Load total count
      _totalCount = await _apiService.getTotalMaterialsCount();

      // Load filtered materials
      await _loadFilteredMaterials();

      setState(() {
        _featured = featured;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFilteredMaterials() async {
    try {
      final userId = ref.read(authProvider).user?.id;
      final response = await _apiService.getMaterialsByFilters(
        level: _selectedLevel == 'all' ? null : _selectedLevel,
        skill: _selectedSkill == 'all' ? null : _selectedSkill,
        type: _selectedType == 'all' ? null : _selectedType,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        currentUserId: userId,
        size: 100,
      );
      setState(() {
        _materials = response.content;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
      });
    }
  }

  Future<void> _handleDownload(LearningMaterial material) async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để tải tài liệu')),
      );
      return;
    }

    final userPoints = ref.read(authProvider).user?.points ?? 0;
    if (userPoints < material.points) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bạn không đủ điểm! Cần ${material.points} điểm')),
      );
      return;
    }

    try {
      await _apiService.downloadMaterial(material.id, userId);
      await _loadMaterials(); // Reload to update downloaded status
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tải tài liệu thành công!')),
      );
      if (material.type == 'pdf' && material.pdfUrl != null) {
        context.push('/material/detail?id=${material.id}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPoints = ref.read(authProvider).user?.points ?? 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
        elevation: 0,
        title: Text(
          'Tài liệu học tập',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: AppColors.primaryBlack, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$userPoints điểm',
                  style: const TextStyle(
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter section - không scroll
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm tài liệu...',
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
                      _loadFilteredMaterials();
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedLevel,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Tất cả cấp độ')),
                            DropdownMenuItem(value: 'beginner', child: Text('Sơ cấp')),
                            DropdownMenuItem(value: 'intermediate', child: Text('Trung cấp')),
                            DropdownMenuItem(value: 'advanced', child: Text('Cao cấp')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedLevel = value);
                              _loadFilteredMaterials();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedSkill,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Tất cả kỹ năng')),
                            DropdownMenuItem(value: 'listening', child: Text('Nghe')),
                            DropdownMenuItem(value: 'speaking', child: Text('Nói')),
                            DropdownMenuItem(value: 'reading', child: Text('Đọc')),
                            DropdownMenuItem(value: 'writing', child: Text('Viết')),
                            DropdownMenuItem(value: 'vocabulary', child: Text('Từ vựng')),
                            DropdownMenuItem(value: 'grammar', child: Text('Ngữ pháp')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedSkill = value);
                              _loadFilteredMaterials();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('Tất cả loại')),
                            DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                            DropdownMenuItem(value: 'video', child: Text('Video')),
                            DropdownMenuItem(value: 'audio', child: Text('Audio')),
                            DropdownMenuItem(value: 'lesson', child: Text('Bài giảng')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedType = value);
                              _loadFilteredMaterials();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content section - có scroll
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
                      onPressed: _loadMaterials,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.primaryBlack,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MaterialStatCard(
                            icon: Icons.folder,
                            value: '$_totalCount',
                            label: 'Tổng tài liệu',
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MaterialStatCard(
                            icon: Icons.download,
                            value: '$_downloadedCount',
                            label: 'Đã tải',
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MaterialStatCard(
                            icon: Icons.star,
                            value: '${_featured.length}',
                            label: 'Nổi bật',
                            color: AppColors.primaryYellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_featured.isNotEmpty) ...[
                      const Text(
                        'Tài liệu nổi bật',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._featured.map((material) => MaterialCard(
                        material: material,
                        onDownload: () => _handleDownload(material),
                        onOpen: () => context.push('/material/detail?id=${material.id}'),
                      )),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Tất cả tài liệu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_materials.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.folder_open, size: 64, color: AppColors.grayLight),
                              const SizedBox(height: 16),
                              Text(
                                'Không tìm thấy tài liệu',
                                style: TextStyle(color: AppColors.grayLight),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._materials.map((material) => MaterialCard(
                        material: material,
                        onDownload: () => _handleDownload(material),
                        onOpen: () => context.push('/material/detail?id=${material.id}'),
                      )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}