import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/models/lesson_model.dart.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';


class LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onTap;

  const LessonCard({
    Key? key,
    required this.lesson,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor ?? (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: Color(0xFFFBE389),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/penguin_study.png',
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPenguinIllustration();
                },
              ),
            ),
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Star icon
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    color: theme.cardColor ?? (isDark ? AppColors.darkSurface : Colors.white),
                    size: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  lesson.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color ?? (isDark ? AppColors.darkOnSurface : Colors.black87),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  lesson.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color ?? (isDark ? AppColors.grayLight : Colors.grey[600]),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlack,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Tiếp theo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

  Widget _buildPenguinIllustration() {
    return CustomPaint(
      size: Size(200, 200),
      painter: PenguinPainter(),
    );
  }
}

class PenguinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw penguin body
    paint.color = Color(0xFF5B6B8F);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      60,
      paint,
    );

    // Draw belly
    paint.color = Color(0xFFFFF8E1);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2 + 10),
      40,
      paint,
    );

    // Draw book
    paint.color = Color(0xFFFFF8E1);
    final bookRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 + 60),
        width: 80,
        height: 50,
      ),
      Radius.circular(4),
    );
    canvas.drawRRect(bookRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
