import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/models/vocabulary_folder_model.dart';
import 'package:koreanhwa_flutter/services/vocabulary_folder_service.dart';
import 'package:koreanhwa_flutter/features/my_vocabulary/presentation/screen/folder_detail_screen.dart';

class VocabularyFolderTile extends StatelessWidget {
  final VocabularyFolder folder;
  final VoidCallback onDeleted;

  const VocabularyFolderTile({
    super.key,
    required this.folder,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      [const Color(0xFFFFE5E5), const Color(0xFFFF6B6B)],
      [const Color(0xFFE5F5FF), const Color(0xFF4DA8FF)],
      [const Color(0xFFFFF0E5), const Color(0xFFFFAA66)],
      [const Color(0xFFE8F5E9), const Color(0xFF66BB6A)],
      [const Color(0xFFF3E5F5), const Color(0xFFAB47BC)],
    ];
    final colorPair = colors[folder.id % colors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderDetailScreen(folderId: folder.id),
          ),
        ).then((_) => onDeleted());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorPair[0],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorPair[1].withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorPair[1].withOpacity(0.15),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(folder.icon, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${folder.words.length} từ vựng',
                    style: const TextStyle(
                      color: Color(0xFF6B6B6B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B), size: 18),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Xóa folder này?',
                      style: TextStyle(fontWeight: FontWeight.w700),
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
                      TextButton(
                        onPressed: () {
                          VocabularyFolderService.deleteFolder(folder.id);
                          onDeleted();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Xóa',
                          style: TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

