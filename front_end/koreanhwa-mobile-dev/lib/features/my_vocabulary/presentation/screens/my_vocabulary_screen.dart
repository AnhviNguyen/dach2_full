import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/models/vocabulary_folder_model.dart';
import 'package:koreanhwa_flutter/services/vocabulary_folder_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/my_vocabulary/presentation/widgets/curriculum_vocabulary_card.dart';
import 'package:koreanhwa_flutter/features/my_vocabulary/presentation/widgets/vocabulary_folder_tile.dart';
import 'package:koreanhwa_flutter/features/my_vocabulary/presentation/widgets/empty_folders_state.dart';

class MyVocabularyScreen extends StatefulWidget {
  const MyVocabularyScreen({super.key});

  @override
  State<MyVocabularyScreen> createState() => _MyVocabularyScreenState();
}

class _MyVocabularyScreenState extends State<MyVocabularyScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<VocabularyFolder> _folders = [];
  bool _personalExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadFolders() {
    setState(() {
      _folders = VocabularyFolderService.getFolders();
    });
  }

  List<VocabularyFolder> get _filteredFolders {
    if (_searchController.text.isEmpty) {
      return _folders;
    }
    return _folders
        .where((folder) => folder.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
        .toList();
  }

  void _showAddFolderDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Tạo Folder Mới',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Nhập tên folder...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryYellow, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final newFolder = VocabularyFolder(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: nameController.text.trim(),
                  icon: '📁',
                  words: [],
                );
                VocabularyFolderService.addFolder(newFolder);
                _loadFolders();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: const Color(0xFF1A1A1A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tạo', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAIHelperDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Assistant',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const Text(
          'Nhập chủ đề hoặc câu để AI tạo từ vựng cho bạn\n\n(Tính năng sẽ được tích hợp với API thực tế)',
          style: TextStyle(color: Color(0xFF4A4A4A), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    '🤖 AI đang phân tích và tạo từ vựng...',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFF667EEA),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Tạo ngay', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A), size: 20),
          ),
        ),
        title: const Text(
          'My Vocabulary',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: _showAIHelperDialog,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CurriculumVocabularyCard(),
          const SizedBox(height: 24),
          _buildPersonalVocabularySection(),
        ],
      ),
      floatingActionButton: _personalExpanded
          ? FloatingActionButton.extended(
              onPressed: _showAddFolderDialog,
              backgroundColor: AppColors.primaryYellow,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: const Icon(Icons.add, color: Color(0xFF1A1A1A)),
              label: const Text(
                'Tạo folder',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildPersonalVocabularySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _personalExpanded,
          onExpansionChanged: (value) => setState(() => _personalExpanded = value),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF48C9B0), Color(0xFF2ECC71)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.folder, color: Colors.white, size: 24),
          ),
          title: const Text(
            'Từ vựng của tôi',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              fontSize: 17,
            ),
          ),
          subtitle: const Text(
            'Quản lý thư viện cá nhân',
            style: TextStyle(
              color: Color(0xFF6B6B6B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm folder...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF48C9B0), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_filteredFolders.isEmpty)
              EmptyFoldersState(onCreateFolder: _showAddFolderDialog)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredFolders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final folder = _filteredFolders[index];
                  return VocabularyFolderTile(
                    folder: folder,
                    onDeleted: _loadFolders,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

