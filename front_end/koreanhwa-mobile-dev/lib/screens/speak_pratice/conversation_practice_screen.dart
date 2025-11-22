import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';

class ConversationPracticeScreen extends StatefulWidget {
  const ConversationPracticeScreen({super.key});

  @override
  State<ConversationPracticeScreen> createState() => _ConversationPracticeScreenState();
}

class _ConversationPracticeScreenState extends State<ConversationPracticeScreen> {
  final List<_Topic> _topics = const [
    _Topic(title: 'Phỏng vấn xin việc', icon: '💼', difficulty: 'Nâng cao'),
    _Topic(title: 'Quán cà phê', icon: '☕', difficulty: 'Cơ bản'),
    _Topic(title: 'Lên kế hoạch du lịch', icon: '✈️', difficulty: 'Trung cấp'),
    _Topic(title: 'Làm quen bạn mới', icon: '👋', difficulty: 'Cơ bản'),
    _Topic(title: 'Thảo luận dự án', icon: '📊', difficulty: 'Nâng cao'),
    _Topic(title: 'Đặt bàn nhà hàng', icon: '🍽️', difficulty: 'Trung cấp'),
  ];

  _Topic? _selected;
  final List<_Message> _messages = [];
  bool _sessionActive = false;
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _startConversation() {
    if (_selected == null) return;
    setState(() {
      _sessionActive = true;
      _messages
        ..clear()
        ..add(
          _Message(
            text:
                'Xin chào! Chúng ta sẽ luyện chủ đề "${_selected!.title}". Mình sẽ là đối tác hội thoại AI và phản hồi bằng tiếng Việt. Bạn sẵn sàng chưa?',
            isUser: false,
          ),
        );
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _messages.add(
        _Message(
          text:
              'Rất tốt! Bạn có thể bổ sung thêm cảm xúc hoặc chi tiết? Hãy thử trả lời mở rộng hơn nhé.',
          isUser: false,
        ),
      );
      _inputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteOff,
      appBar: AppBar(
        backgroundColor: AppColors.whiteOff,
        elevation: 0,
        title: const Text(
          'Phòng hội thoại AI',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _sessionActive ? _buildSession() : _buildTopicPicker(),
    );
  }

  Widget _buildTopicPicker() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Row(
              children: const [
                Icon(Icons.tips_and_updates, color: AppColors.primaryBlack),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chọn 1 chủ đề để AI đóng vai đối thoại. Tất cả gợi ý, phản hồi đều bằng tiếng Việt giúp bạn theo sát mạch.',
                    style: TextStyle(color: AppColors.grayLight, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Chủ đề gợi ý',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: _topics
                  .map(
                    (topic) => GestureDetector(
                      onTap: () => setState(() => _selected = topic),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: _selected == topic
                                ? AppColors.primaryBlack
                                : Colors.black.withOpacity(0.08),
                          ),
                          boxShadow: [
                            if (_selected == topic)
                              BoxShadow(
                                color: AppColors.primaryYellow.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 10),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(topic.icon, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 12),
                            Text(
                              topic.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                topic.difficulty,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startConversation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primaryBlack,
                foregroundColor: AppColors.primaryYellow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text(
                'Bắt đầu hội thoại',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSession() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFECECEC)),
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đang luyện chủ đề',
                    style: TextStyle(color: AppColors.grayLight, fontSize: 12),
                  ),
                  Text(
                    _selected?.title ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _sessionActive = false),
                icon: const Icon(Icons.stop_circle_outlined, color: AppColors.primaryBlack),
                label: const Text(
                  'Kết thúc',
                  style: TextStyle(color: AppColors.primaryBlack),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return Align(
                alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser ? AppColors.primaryBlack : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(message.isUser ? 18 : 4),
                      topRight: Radius.circular(message.isUser ? 4 : 18),
                      bottomLeft: const Radius.circular(18),
                      bottomRight: const Radius.circular(18),
                    ),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? AppColors.primaryYellow : AppColors.primaryBlack,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFECECEC)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mic_none, color: AppColors.primaryBlack),
          ),
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: 'Nhập câu trả lời hoặc câu hỏi bằng tiếng Việt...',
                filled: true,
                fillColor: AppColors.whiteGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: AppColors.primaryBlack),
          ),
        ],
      ),
    );
  }
}

class _Topic {
  final String title;
  final String icon;
  final String difficulty;

  const _Topic({
    required this.title,
    required this.icon,
    required this.difficulty,
  });
}

class _Message {
  final String text;
  final bool isUser;

  const _Message({
    required this.text,
    required this.isUser,
  });
}

