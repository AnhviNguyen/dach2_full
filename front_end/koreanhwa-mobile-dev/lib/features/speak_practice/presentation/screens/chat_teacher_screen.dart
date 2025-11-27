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

class _ChatTeacherScreenState extends State<ChatTeacherScreen> {
  final ChatApiService _chatService = ChatApiService();
  final TtsApiService _ttsService = TtsApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  String _selectedMode = 'free_chat';
  final List<Map<String, String>> _history = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

      // Play TTS if available
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
    return Scaffold(
      backgroundColor: AppColors.whiteOff,
      appBar: AppBar(
        backgroundColor: AppColors.whiteOff,
        elevation: 0,
        title: const Text(
          'Chat với giáo viên AI',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Chế độ: ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'free_chat',
                        label: Text('Trò chuyện'),
                      ),
                      ButtonSegment(
                        value: 'explain',
                        label: Text('Giải thích'),
                      ),
                      ButtonSegment(
                        value: 'speaking_feedback',
                        label: Text('Phản hồi'),
                      ),
                    ],
                    selected: {_selectedMode},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedMode = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, 
                            size: 64, 
                            color: AppColors.grayLight),
                        const SizedBox(height: 16),
                        Text(
                          'Bắt đầu trò chuyện với giáo viên AI',
                          style: TextStyle(color: AppColors.grayLight),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFECECEC))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập câu hỏi...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.whiteGray,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send, color: AppColors.primaryBlack),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser 
              ? AppColors.primaryBlack 
              : message.isError 
                  ? AppColors.error.withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(message.isUser ? 18 : 4),
            topRight: Radius.circular(message.isUser ? 4 : 18),
            bottomLeft: const Radius.circular(18),
            bottomRight: const Radius.circular(18),
          ),
          border: Border.all(
            color: message.isError 
                ? AppColors.error 
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser 
                ? AppColors.primaryYellow 
                : message.isError 
                    ? AppColors.error 
                    : AppColors.primaryBlack,
          ),
        ),
      ),
    );
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

