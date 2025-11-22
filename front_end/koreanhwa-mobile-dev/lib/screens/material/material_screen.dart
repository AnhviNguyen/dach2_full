import 'package:flutter/material.dart' hide Material;
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/models/material_model.dart';
import 'package:koreanhwa_flutter/services/material_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  String _searchQuery = '';
  String _selectedLevel = 'all';
  String _selectedSkill = 'all';
  String _selectedType = 'all';

  @override
  Widget build(BuildContext context) {
    final materials = MaterialService.getMaterials(
      level: _selectedLevel == 'all' ? null : _selectedLevel,
      skill: _selectedSkill == 'all' ? null : _selectedSkill,
      type: _selectedType == 'all' ? null : _selectedType,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
    );
    final featured = MaterialService.getFeaturedMaterials();
    final downloaded = MaterialService.getDownloadedMaterials();
    final userPoints = MaterialService.userPoints;

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        title: const Text(
          'Tài liệu học tập',
          style: TextStyle(
            color: AppColors.primaryBlack,
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
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryWhite,
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
                  onChanged: (value) => setState(() => _searchQuery = value),
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
                          if (value != null) setState(() => _selectedLevel = value);
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
                          if (value != null) setState(() => _selectedSkill = value);
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
                          if (value != null) setState(() => _selectedType = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(Icons.folder, '${materials.length}', 'Tổng tài liệu', AppColors.info)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(Icons.download, '${downloaded.length}', 'Đã tải', AppColors.success)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(Icons.star, '${featured.length}', 'Nổi bật', AppColors.primaryYellow)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Featured
                  if (featured.isNotEmpty) ...[
                    const Text(
                      'Tài liệu nổi bật',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...featured.map((material) => _buildMaterialCard(material)),
                    const SizedBox(height: 24),
                  ],
                  // All Materials
                  const Text(
                    'Tất cả tài liệu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (materials.isEmpty)
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
                    ...materials.map((material) => _buildMaterialCard(material)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
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

  Widget _buildMaterialCard(LearningMaterial material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlack.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                material.thumbnail,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        material.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (material.isDownloaded)
                      const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  material.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grayLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag(MaterialService.getSkillName(material.skill), AppColors.primaryYellow),
                    _buildTag(MaterialService.getLevelName(material.level), AppColors.grayLight),
                    _buildTag(MaterialService.getTypeName(material.type), AppColors.info),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.download, size: 14, color: AppColors.grayLight),
                    const SizedBox(width: 4),
                    Text('${material.downloads}', style: TextStyle(fontSize: 12, color: AppColors.grayLight)),
                    const SizedBox(width: 16),
                    Icon(Icons.star, size: 14, color: AppColors.primaryYellow),
                    const SizedBox(width: 4),
                    Text('${material.rating}', style: TextStyle(fontSize: 12, color: AppColors.grayLight)),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: AppColors.grayLight),
                    const SizedBox(width: 4),
                    Text(material.size, style: TextStyle(fontSize: 12, color: AppColors.grayLight)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              if (material.isDownloaded)
                ElevatedButton(
                  onPressed: () {
                    context.push('/material/detail?id=${material.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.primaryWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Mở'),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    if (MaterialService.userPoints >= material.points) {
                      if (MaterialService.downloadMaterial(material.id)) {
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tải tài liệu thành công!')),
                        );
                        if (material.type == 'pdf' && material.pdfUrl != null) {
                          context.push('/material/detail?id=${material.id}');
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bạn không đủ điểm! Cần ${material.points} điểm')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MaterialService.userPoints >= material.points
                        ? AppColors.primaryYellow
                        : AppColors.grayLight,
                    foregroundColor: AppColors.primaryBlack,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text('${material.points} điểm'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
