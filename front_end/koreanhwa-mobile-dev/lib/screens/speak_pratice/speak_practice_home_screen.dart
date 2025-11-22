import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/screens/speak_pratice/conversation_practice_screen.dart';
import 'package:koreanhwa_flutter/screens/speak_pratice/pronunciation_practice_screen.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class SpeakPracticeHomeScreen extends StatelessWidget {
  const SpeakPracticeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteOff,
      appBar: AppBar(
        backgroundColor: AppColors.whiteOff,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Trung tâm luyện nói',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: AppColors.primaryBlack),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(context),
            const SizedBox(height: 20),
            _buildStats(),
            const SizedBox(height: 24),
            const _SectionTitle(title: 'Nhiệm vụ hôm nay'),
            const SizedBox(height: 12),
            _buildMissions(),
            const SizedBox(height: 24),
            const _SectionTitle(title: 'Bắt đầu nhanh'),
            const SizedBox(height: 12),
            _buildQuickActions(context),
            const SizedBox(height: 28),
            const _SectionTitle(title: 'Lộ trình luyện nói 4 bước'),
            const SizedBox(height: 12),
            _buildRoadmap(),
            const SizedBox(height: 24),
            const _SectionTitle(title: 'Huấn luyện viên nổi bật'),
            const SizedBox(height: 12),
            _buildCoachCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE082), Color(0xFFFFC107)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellowAccent.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlack,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.graphic_eq, color: AppColors.primaryYellow),
              ),
              const SizedBox(width: 12),
              const Text(
                'VoiceFlow AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.bolt, size: 18, color: AppColors.primaryBlack),
                    SizedBox(width: 4),
                    Text(
                      'Chuỗi 7 ngày',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Cùng AI luyện phát âm, hội thoại và theo dõi tiến độ một cách trực quan, tất cả bằng tiếng Việt.',
            style: TextStyle(
              color: AppColors.primaryBlack,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    foregroundColor: AppColors.primaryYellow,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PronunciationPracticeScreen()),
                  ),
                  child: const Text('Luyện phát âm ngay'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryBlack,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConversationPracticeScreen()),
                ),
                child: const Icon(Icons.mic_none),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = [
      ('Thời lượng', '24 phút', 'Hôm nay'),
      ('Chuỗi ngày', '7 ngày', 'Không bỏ lỡ'),
      ('Điểm nói', '86/100', 'Tăng 8%'),
    ];

    return Row(
      children: stats
          .map(
            (stat) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.$1,
                      style: const TextStyle(
                        color: AppColors.grayLight,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stat.$2,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      stat.$3,
                      style: const TextStyle(color: AppColors.grayLight, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMissions() {
    final missions = [
      (
        'Phát âm 10 câu',
        'Còn 3 câu nữa để hoàn thành mục tiêu',
        Icons.graphic_eq,
        AppColors.primaryYellow
      ),
      (
        'Hội thoại 5 phút',
        'Thực hành với chủ đề tự chọn',
        Icons.chat_bubble_outline,
        AppColors.blackLight
      ),
      (
        'Ôn lại lỗi sai',
        'Xem lại 4 âm chưa chính xác hôm qua',
        Icons.refresh,
        AppColors.warning
      ),
    ];

    return Column(
      children: missions
          .map(
            (mission) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mission.$4.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(mission.$3, color: mission.$4),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mission.$2,
                          style: const TextStyle(color: AppColors.grayLight),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.grayLight),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final cardData = [
      (
        'Luyện phát âm chuẩn',
        Icons.record_voice_over,
        AppColors.primaryYellow,
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PronunciationPracticeScreen()),
            )
      ),
      (
        'Hội thoại tình huống',
        Icons.forum_outlined,
        AppColors.primaryBlack,
        () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConversationPracticeScreen()),
            )
      ),
      (
        'Thử thách nhanh',
        Icons.flash_on_outlined,
        AppColors.warning,
        () {},
      ),
      (
        'Xem báo cáo',
        Icons.insights_outlined,
        AppColors.success,
        () {},
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.08,
      physics: const NeverScrollableScrollPhysics(),
      children: cardData
          .map(
            (item) => GestureDetector(
              onTap: item.$4,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: item.$3.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.$3.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(item.$2, color: item.$3),
                    ),
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const Text(
                      'Chạm để mở',
                      style: TextStyle(color: AppColors.grayLight, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildRoadmap() {
    final steps = [
      ('Chuẩn bị khẩu hình', 'Xem demo và mẹo đặt lưỡi/môi', '🎯'),
      ('Luyện phát âm', 'Chấm điểm ngay lập tức với AI', '🎙️'),
      ('Hội thoại ngắn', 'Ứng dụng âm vừa học trong hội thoại', '💬'),
      ('Đánh giá & ghi chú', 'Ghi nhớ lỗi và đặt mục tiêu mới', '📝'),
    ];

    return Column(
      children: steps
          .asMap()
          .entries
          .map(
            (entry) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryYellow.withOpacity(0.25),
                      child: Text(entry.value.$3),
                    ),
                    if (entry.key < steps.length - 1)
                      Container(
                        width: 3,
                        height: 36,
                        color: AppColors.primaryYellow,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.value.$2,
                          style: const TextStyle(color: AppColors.grayLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildCoachCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primaryYellow,
            child: Text('👩‍🏫', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Cô Mi Na · Chuyên gia phát âm',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryBlack,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tùy chỉnh giáo án phù hợp với tốc độ học, phản hồi 100% bằng tiếng Việt.',
                  style: TextStyle(color: AppColors.grayLight),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grayLight),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: AppColors.primaryBlack,
      ),
    );
  }
}

