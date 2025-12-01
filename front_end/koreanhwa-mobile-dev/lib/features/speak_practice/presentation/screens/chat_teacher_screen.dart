import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/services/chat_api_service.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/services/tts_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatTeacherScreen extends StatefulWidget {
  const ChatTeacherScreen({super.key});

  @override
  State<ChatTeacherScreen> createState() => _ChatTeacherScreenState();
}

class _ChatTeacherScreenState extends State<ChatTeacherScreen> with SingleTickerProviderStateMixin {
  final ChatApiService _chatService = ChatApiService();
  final TtsApiService _ttsService = TtsApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  final List<Map<String, String>> _history = [];

  // Tab modes
  final List<_TabMode> _tabModes = [
    _TabMode(
      id: 'free_chat',
      title: 'Trò chuyện',
      icon: Icons.chat_bubble_outline,
      description: 'Chat tự do với giáo viên AI',
      placeholder: 'Hãy hỏi tôi bất cứ điều gì về tiếng Hàn...',
      color: const Color(0xFF6C63FF),
    ),
    _TabMode(
      id: 'explain',
      title: 'Giải thích',
      icon: Icons.school_outlined,
      description: 'Giải thích ngữ pháp và từ vựng',
      placeholder: 'Ví dụ: Giải thích ngữ pháp -(으)ㄹ 것이다',
      color: const Color(0xFFFF6B9D),
    ),
    _TabMode(
      id: 'speaking_feedback',
      title: 'Phản hồi',
      icon: Icons.record_voice_over_outlined,
      description: 'Nhận phản hồi về phát âm và văn phạm',
      placeholder: 'Nhập câu của bạn để nhận phản hồi...',
      color: const Color(0xFF4CAF50),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _messages.clear();
          _history.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String get _selectedMode => _tabModes[_tabController.index].id;
  _TabMode get _currentTab => _tabModes[_tabController.index];

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _history.add({'role': 'user', 'content': text});
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final response = await _chatService.chatWithTeacher(
        message: text,
        mode: _selectedMode,
        language: 'ko',
        history: _history,
      );

      final reply = response['reply'] as String? ?? 'Xin lỗi, tôi không thể trả lời.';
      final ttsUrl = response['tts_url'] as String?;

      setState(() {
        _messages.add(_ChatMessage(
          text: reply,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _history.add({'role': 'assistant', 'content': reply});
        _isLoading = false;
      });

      _scrollToBottom();

      if (ttsUrl != null && ttsUrl.isNotEmpty) {
        await _playTTS(ttsUrl);
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text: 'Lỗi: $e',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _playTTS(String audioUrl) async {
    try {
      final fullUrl = _ttsService.getMediaUrl(audioUrl);
      final uri = Uri.parse(fullUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error playing TTS: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Custom App Bar with Tabs
          Container(
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : Colors.white),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Giáo viên AI',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Luôn sẵn sàng hỗ trợ bạn 24/7',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: _currentTab.color,
                    indicatorWeight: 3,
                    labelColor: AppColors.primaryBlack,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: _tabModes.map((mode) {
                      return Tab(
                        icon: Icon(mode.icon, size: 22),
                        text: mode.title,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabModes.map((mode) {
                return _buildChatContent(mode);
              }).toList(),
            ),
          ),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatContent(_TabMode mode) {
    return Container(
      color: AppColors.whiteOff,
      child: Column(
        children: [
          // Mode Description Card
          if (_messages.isEmpty) ...[
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    mode.color.withOpacity(0.1),
                    mode.color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: mode.color.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    mode.icon,
                    size: 48,
                    color: mode.color,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mode.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mode.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mode.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickPrompts(mode),
                ],
              ),
            ),
          ],

          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(mode)
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _messages.length) {
                  return _buildTypingIndicator(mode);
                }
                if (index < 0 || index >= _messages.length) {
                  return const SizedBox.shrink();
                }
                final message = _messages[index];
                return _buildMessageBubble(message, mode);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts(_TabMode mode) {
    List<String> prompts = [];

    switch (mode.id) {
      case 'free_chat':
        prompts = [
          '안녕하세요! 👋',
          'Giới thiệu bản thân',
          'Gợi ý chủ đề',
        ];
        break;
      case 'explain':
        prompts = [
          'Giải thích -(으)ㄹ 것이다',
          'Phân biệt 이/가 và 은/는',
          'Cách dùng 아/어/여요',
        ];
        break;
      case 'speaking_feedback':
        prompts = [
          'Kiểm tra phát âm',
          'Sửa lỗi ngữ pháp',
          'Đánh giá câu của tôi',
        ];
        break;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: prompts.map((prompt) {
        return InkWell(
          onTap: () {
            _messageController.text = prompt;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: mode.color.withOpacity(0.3)),
            ),
            child: Text(
              prompt,
              style: TextStyle(
                color: mode.color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(_TabMode mode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: mode.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              mode.icon,
              size: 64,
              color: mode.color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Bắt đầu ${mode.title.toLowerCase()}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              mode.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(_TabMode mode) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 600 + (index * 100)),
                    builder: (context, value, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: mode.color.withOpacity(value),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                    onEnd: () {
                      setState(() {});
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message, _TabMode mode) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? LinearGradient(
            colors: [mode.color, mode.color.withOpacity(0.8)],
          )
              : null,
          color: message.isUser
              ? null
              : message.isError
              ? AppColors.error.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(message.isUser ? 20 : 4),
            topRight: Radius.circular(message.isUser ? 4 : 20),
            bottomLeft: const Radius.circular(20),
            bottomRight: const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser
                    ? Colors.white
                    : message.isError
                    ? AppColors.error
                    : AppColors.primaryBlack,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser
                    ? Colors.white.withOpacity(0.7)
                    : Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteOff,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _currentTab.color.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: _currentTab.placeholder,
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_currentTab.color, _currentTab.color.withOpacity(0.8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _currentTab.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: Icon(
                    _isLoading ? Icons.hourglass_empty : Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

class _TabMode {
  final String id;
  final String title;
  final IconData icon;
  final String description;
  final String placeholder;
  final Color color;

  _TabMode({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.placeholder,
    required this.color,
  });
}