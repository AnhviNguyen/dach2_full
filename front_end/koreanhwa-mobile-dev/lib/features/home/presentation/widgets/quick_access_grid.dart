import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/home/presentation/widgets/section_header.dart';

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const colorPurple = Color(0xFF8B5CF6);
    const colorOrange = Color(0xFFF97316);
    const colorBlue = Color(0xFF3B82F6);
    const colorGreen = Color(0xFF10B981);

    final quickAccess = [
      _QuickAccessItem('Blog', Icons.article, colorPurple, () => context.push('/blog')),
      _QuickAccessItem('Cuộc thi', Icons.emoji_events, colorOrange, () => context.push('/competition')),
      _QuickAccessItem('TOPIK', Icons.quiz, colorBlue, () => context.push('/topik-library')),
      _QuickAccessItem('Từ vựng', Icons.book, colorGreen, () => context.push('/my-vocabulary')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Truy cập nhanh', icon: Icons.dashboard),
        const SizedBox(height: 12),
        Row(
          children: quickAccess.map((item) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(item.icon, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.primaryBlack,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuickAccessItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _QuickAccessItem(this.label, this.icon, this.color, this.onTap);
}

