import 'package:koreanhwa_flutter/features/onboarding/data/models/onboarding_page.dart';

class OnboardingMockData {
  static List<OnboardingPage> get pages => const [
        OnboardingPage(
          title: 'Bắt đầu học tiếng Hàn trong 5 phút',
          description: 'Không cần tài liệu phức tạp, học ngay hôm nay. Khám phá lộ trình học tốt nhất!',
        ),
        OnboardingPage(
          title: 'Học mọi lúc mọi nơi',
          description: 'Truy cập bài học, từ vựng và bài tập mọi lúc mọi nơi trên thiết bị của bạn',
        ),
        OnboardingPage(
          title: 'Theo dõi tiến độ',
          description: 'Xem tiến độ học tập, điểm số và thành tích của bạn một cách trực quan',
        ),
      ];
}

