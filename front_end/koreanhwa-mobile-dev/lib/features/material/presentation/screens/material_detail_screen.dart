import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/material/data/models/learning_material.dart';
import 'package:koreanhwa_flutter/services/material_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialDetailScreen extends StatefulWidget {
  final int materialId;

  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  bool _sidebarOpen = true;
  int _currentPage = 21;
  final int _totalPages = 384;
  double _zoomLevel = 100.0;
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    final material = MaterialService.getMaterialById(widget.materialId);
    if (material == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không tìm thấy tài liệu')),
      );
    }

    final pdfUrl = material.pdfUrl ?? 'https://kanata.edu.vn/wp-content/uploads/2022/10/Giao-trinh-Tieng-Han-Tong-hop-so-cap-1.pdf';

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _sidebarOpen ? 320 : 0,
            child: _sidebarOpen
                ? Container(
              color: AppColors.primaryBlack,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.grayLight.withOpacity(0.3)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                material.title,
                                style: const TextStyle(
                                  color: AppColors.primaryWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: AppColors.primaryWhite),
                              onPressed: () => setState(() => _sidebarOpen = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(pdfUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.volume_up),
                          label: const Text('Audio'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: AppColors.primaryBlack,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(pdfUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Tải xuống'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow.withOpacity(0.8),
                            foregroundColor: AppColors.primaryBlack,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Page Navigation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.grayLight.withOpacity(0.3)),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Trang $_currentPage / $_totalPages',
                                style: const TextStyle(
                                  color: AppColors.primaryWhite,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryYellow,
                                foregroundColor: AppColors.primaryBlack,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('Đi'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _currentPage > 1
                                  ? () => setState(() => _currentPage--)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.grayLight.withOpacity(0.2),
                                foregroundColor: AppColors.primaryWhite,
                              ),
                              child: const Text('Previous'),
                            ),
                            ElevatedButton(
                              onPressed: _currentPage < _totalPages
                                  ? () => setState(() => _currentPage++)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.grayLight.withOpacity(0.2),
                                foregroundColor: AppColors.primaryWhite,
                              ),
                              child: const Text('Next'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Table of Contents
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          'MỤC LỤC',
                          style: TextStyle(
                            color: AppColors.grayLight,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTocItem('Sưu tầm', 1, 0),
                        _buildTocItem('Bài 1: Chào hỏi cơ bản', 15, 1),
                        _buildTocItem('Từ vựng', 16, 2),
                        _buildTocItem('Ngữ pháp', 18, 2),
                        _buildTocItem('Bài tập', 20, 2),
                        _buildTocItem('Bài 2: Giới thiệu bản thân', 25, 1),
                        _buildTocItem('Bài 3: Gia đình', 35, 1),
                      ],
                    ),
                  ),
                ],
              ),
            )
                : null,
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Toolbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppColors.primaryBlack,
                  child: Row(
                    children: [
                      if (!_sidebarOpen)
                        IconButton(
                          icon: const Icon(Icons.menu, color: AppColors.primaryWhite),
                          onPressed: () => setState(() => _sidebarOpen = true),
                        ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () => context.go('/material'),
                        child: const Text(
                          'Tài liệu',
                          style: TextStyle(color: AppColors.grayLight),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.grayLight, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          material.title,
                          style: const TextStyle(
                            color: AppColors.primaryWhite,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownButton<double>(
                        value: _zoomLevel,
                        dropdownColor: AppColors.primaryBlack,
                        style: const TextStyle(color: AppColors.primaryWhite),
                        items: [50, 75, 100, 125, 150].map((zoom) {
                          return DropdownMenuItem<double>(
                            value: zoom.toDouble(),
                            child: Text('$zoom%'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _zoomLevel = value);
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.search, color: AppColors.primaryWhite),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: AppColors.primaryWhite),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                // PDF Viewer
                Expanded(
                  child: Container(
                    color: AppColors.grayLight.withOpacity(0.1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 600,
                            margin: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.primaryWhite,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Material(
                                child: InkWell(
                                  onTap: () async {
                                    final uri = Uri.parse(pdfUrl);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryYellow,
                                          border: Border(
                                            bottom: BorderSide(color: AppColors.primaryBlack.withOpacity(0.1)),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.picture_as_pdf, color: AppColors.primaryBlack),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                material.title,
                                                style: const TextStyle(
                                                  color: AppColors.primaryBlack,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.picture_as_pdf,
                                                size: 80,
                                                color: AppColors.primaryYellow,
                                              ),
                                              const SizedBox(height: 16),
                                              const Text(
                                                'Nhấn để mở PDF',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Trang $_currentPage / $_totalPages',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.grayLight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Page Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _currentPage > 1
                                    ? () => setState(() => _currentPage--)
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                                label: const Text('Trang trước'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.grayLight.withOpacity(0.2),
                                  foregroundColor: AppColors.primaryWhite,
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () => setState(() => _bookmarked = !_bookmarked),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _bookmarked
                                      ? AppColors.primaryYellow
                                      : AppColors.grayLight.withOpacity(0.2),
                                  foregroundColor: _bookmarked
                                      ? AppColors.primaryBlack
                                      : AppColors.primaryWhite,
                                ),
                                child: Row(
                                  children: [
                                    Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border),
                                    const SizedBox(width: 8),
                                    const Text('Bookmark'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: _currentPage < _totalPages
                                    ? () => setState(() => _currentPage++)
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                                label: const Text('Trang sau'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.grayLight.withOpacity(0.2),
                                  foregroundColor: AppColors.primaryWhite,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildTocItem(String title, int page, int level) {
    return InkWell(
      onTap: () => setState(() => _currentPage = page),
      child: Container(
        padding: EdgeInsets.only(
          left: level * 16.0 + 12,
          top: 8,
          bottom: 8,
          right: 12,
        ),
        decoration: BoxDecoration(
          color: _currentPage == page
              ? AppColors.primaryYellow.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: level == 0
                      ? AppColors.primaryYellow
                      : level == 1
                      ? AppColors.primaryWhite
                      : AppColors.grayLight,
                  fontSize: level == 0 ? 14 : 12,
                  fontWeight: level == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Text(
              '$page',
              style: TextStyle(
                color: AppColors.grayLight,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
