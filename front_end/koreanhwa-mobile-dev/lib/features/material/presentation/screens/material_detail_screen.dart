import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/material/data/models/learning_material.dart';
import 'package:koreanhwa_flutter/features/material/data/services/material_api_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialDetailScreen extends ConsumerStatefulWidget {
  final int materialId;

  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  ConsumerState<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends ConsumerState<MaterialDetailScreen> {
  int _currentPage = 21;
  final int _totalPages = 384;
  bool _bookmarked = false;
  final MaterialApiService _apiService = MaterialApiService();
  LearningMaterial? _material;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showToc = false;

  @override
  void initState() {
    super.initState();
    _loadMaterial();
  }

  Future<void> _loadMaterial() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = ref.read(authProvider).user?.id;
      final material = await _apiService.getMaterialById(widget.materialId, currentUserId: userId);
      setState(() {
        _material = material;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _material == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack)),
            onPressed: () => context.go('/material'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.iconTheme.color ?? AppColors.grayLight),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Không tìm thấy tài liệu',
                style: TextStyle(color: theme.textTheme.bodyLarge?.color ?? (isDark ? AppColors.darkOnSurface : AppColors.primaryBlack)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMaterial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.primaryBlack,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final material = _material!;
    final pdfUrl = material.pdfUrl ?? 'https://kanata.edu.vn/wp-content/uploads/2022/10/Giao-trinh-Tieng-Han-Tong-hop-so-cap-1.pdf';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Modern AppBar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.primaryWhite),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
                    onPressed: () => context.go('/material'),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          material.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Trang $_currentPage / $_totalPages',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grayLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: _bookmarked ? AppColors.primaryYellow : AppColors.grayLight,
                    ),
                    onPressed: () => setState(() => _bookmarked = !_bookmarked),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: AppColors.primaryBlack),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.download, size: 20),
                            SizedBox(width: 12),
                            Text('Tải xuống'),
                          ],
                        ),
                        onTap: () async {
                          final uri = Uri.parse(pdfUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.volume_up, size: 20),
                            SizedBox(width: 12),
                            Text('Audio'),
                          ],
                        ),
                        onTap: () async {
                          final uri = Uri.parse(pdfUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: Stack(
                children: [
                  // PDF Preview
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            children: [
                              // PDF Header
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryYellow,
                                      AppColors.primaryYellow.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryWhite.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.picture_as_pdf,
                                        color: AppColors.primaryBlack,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            material.title,
                                            style: const TextStyle(
                                              color: AppColors.primaryBlack,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${material.size} • $_totalPages trang',
                                            style: TextStyle(
                                              color: AppColors.primaryBlack.withOpacity(0.7),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // PDF Content Area
                              InkWell(
                                onTap: () async {
                                  final uri = Uri.parse(pdfUrl);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Container(
                                  height: 500,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.whiteGray,
                                        AppColors.whiteGray.withOpacity(0.5),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryYellow.withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.touch_app,
                                            size: 64,
                                            color: AppColors.primaryYellow,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        const Text(
                                          'Nhấn để mở PDF',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlack,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Xem toàn bộ nội dung tài liệu',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.grayLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Table of Contents Drawer
                  if (_showToc)
                    GestureDetector(
                      onTap: () => setState(() => _showToc = false),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  if (_showToc)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 320,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryYellow,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.list, color: AppColors.primaryBlack),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Mục lục',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryBlack,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: AppColors.primaryBlack),
                                      onPressed: () => setState(() => _showToc = false),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.all(16),
                                  children: [
                                    _buildTocItem('Sưu tầm', 1, 0),
                                    _buildTocItem('Bài 1: Chào hỏi cơ bản', 15, 1),
                                    _buildTocItem('Từ vựng', 16, 2),
                                    _buildTocItem('Ngữ pháp', 18, 2),
                                    _buildTocItem('Bài tập', 20, 2),
                                    _buildTocItem('Bài 2: Giới thiệu bản thân', 25, 1),
                                    _buildTocItem('Bài 3: Gia đình', 35, 1),
                                    _buildTocItem('Từ vựng', 36, 2),
                                    _buildTocItem('Ngữ pháp', 38, 2),
                                    _buildTocItem('Bài 4: Thời gian', 45, 1),
                                    _buildTocItem('Bài 5: Hoạt động hàng ngày', 55, 1),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom Navigation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentPage > 1
                          ? () => setState(() => _currentPage--)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Trước'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whiteGray,
                        foregroundColor: AppColors.primaryBlack,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showToc = !_showToc),
                    icon: const Icon(Icons.list),
                    label: const Text('Mục lục'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentPage < _totalPages
                          ? () => setState(() => _currentPage++)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Sau'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whiteGray,
                        foregroundColor: AppColors.primaryBlack,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTocItem(String title, int page, int level) {
    final isActive = _currentPage == page;
    return InkWell(
      onTap: () {
        setState(() {
          _currentPage = page;
          _showToc = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.only(
          left: level * 16.0 + 12,
          top: 12,
          bottom: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryYellow.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: AppColors.primaryYellow, width: 2)
              : null,
        ),
        child: Row(
          children: [
            if (level > 0)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: level == 1 ? AppColors.primaryYellow : AppColors.grayLight,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: level == 0
                      ? AppColors.primaryYellow
                      : AppColors.primaryBlack,
                  fontSize: level == 0 ? 14 : 13,
                  fontWeight: isActive || level == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryYellow
                    : AppColors.whiteGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$page',
                style: TextStyle(
                  color: isActive ? AppColors.primaryBlack : AppColors.grayLight,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}