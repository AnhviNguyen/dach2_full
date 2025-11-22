import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/textbook/data/models/textbook.dart';

class TextbookMockData {
  static List<Textbook> generateTextbooks() {
    return List.generate(6, (index) {
      final bookNumber = index + 1;
      final completedLessons = bookNumber == 1 ? 15 : (bookNumber == 2 ? 8 : 0);
      return Textbook(
        bookNumber: bookNumber,
        title: 'Giáo trình Tiếng Hàn Quyển $bookNumber',
        subtitle: bookNumber == 1
            ? 'Sơ cấp 1'
            : bookNumber == 2
                ? 'Sơ cấp 2'
                : bookNumber == 3
                    ? 'Trung cấp 1'
                    : bookNumber == 4
                        ? 'Trung cấp 2'
                        : bookNumber == 5
                            ? 'Cao cấp 1'
                            : 'Cao cấp 2',
        totalLessons: 15,
        completedLessons: completedLessons,
        isCompleted: completedLessons == 15,
        isLocked: bookNumber > 2,
        color: AppColors.primaryYellow,
      );
    });
  }
}

