import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/services/material_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/material/data/models/learning_material.dart';
import 'package:koreanhwa_flutter/features/material/presentation/widgets/material_stat_card.dart';
import 'package:koreanhwa_flutter/features/material/presentation/widgets/material_card.dart';

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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MaterialStatCard(
                          icon: Icons.folder,
                          value: '${materials.length}',
                          label: 'Tổng tài liệu',
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MaterialStatCard(
                          icon: Icons.download,
                          value: '${downloaded.length}',
                          label: 'Đã tải',
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MaterialStatCard(
                          icon: Icons.star,
                          value: '${featured.length}',
                          label: 'Nổi bật',
                          color: AppColors.primaryYellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                    ...featured.map((material) => MaterialCard(
                          material: material,
                          onDownload: () {
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
                    ...materials.map((material) => MaterialCard(
                          material: material,
                          onDownload: () {
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
                          onOpen: () => context.push('/material/detail?id=${material.id}'),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

