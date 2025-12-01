import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koreanhwa_flutter/models/vocabulary_folder_model.dart';
import 'package:koreanhwa_flutter/features/my_vocabulary/data/services/vocabulary_folder_api_service.dart';
import 'package:koreanhwa_flutter/features/my_vocabulary/presentation/screen/folder_detail_screen.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class VocabularyFolderTile extends ConsumerWidget {
  final VocabularyFolder folder;
  final VoidCallback onDeleted;

  const VocabularyFolderTile({
    super.key,
    required this.folder,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiService = VocabularyFolderApiService();
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
                color: Theme.of(context).cardColor ?? Colors.white,
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
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Theme.of(context).textTheme.titleMedium?.color ?? const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${folder.words.length} từ vựng',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF6B6B6B),
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
                  color: Theme.of(context).cardColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B), size: 18),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final theme = Theme.of(context);
                    final isDark = theme.brightness == Brightness.dark;
                    return AlertDialog(
                      backgroundColor: theme.dialogBackgroundColor ?? (isDark ? AppColors.darkSurface : Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        'Xóa folder này?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Hủy',
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color ?? (isDark ? AppColors.grayLight : Colors.grey[600]),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      TextButton(
                        onPressed: () async {
                          try {
                            final userId = ref.read(authProvider).user?.id;
                            if (userId == null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Vui lòng đăng nhập')),
                                );
                              }
                              return;
                            }

                            await apiService.deleteFolder(folder.id, userId);
                            if (context.mounted) {
                              onDeleted();
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: ${e.toString()}')),
                              );
                            }
                          }
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
                  );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

