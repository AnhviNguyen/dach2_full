import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/services/speaking_api_service.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/services/tts_api_service.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class FreeSpeakScreen extends StatefulWidget {
  const FreeSpeakScreen({super.key});

  @override
  State<FreeSpeakScreen> createState() => _FreeSpeakScreenState();
}

class _FreeSpeakScreenState extends State<FreeSpeakScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final SpeakingApiService _apiService = SpeakingApiService();
  final TtsApiService _ttsService = TtsApiService();
  final TextEditingController _contextController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  bool _isRecording = false;
  bool _isProcessing = false;
  String? _audioPath;
  String? _errorMessage;
  String? _currentPlayingUrl;

  // Lịch sử tin nhắn dạng chat
  List<ChatMessage> _messages = [];

  // File tạm để lưu audio đã download
  File? _tempAudioFile;

  @override
  void initState() {
    super.initState();

    // Lắng nghe trạng thái audio player
    _audioPlayer.onPlayerStateChanged.listen((state) {
      debugPrint('🎵 Audio state changed: $state');
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        setState(() {
          _currentPlayingUrl = null;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      debugPrint('✅ Audio playback completed');
      setState(() {
        _currentPlayingUrl = null;
      });
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _contextController.dispose();
    _audioPlayer.dispose();
    _scrollController.dispose();
    _tempAudioFile?.delete().catchError((e) => debugPrint('Không thể xóa file tạm: $e'));
    super.dispose();
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

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần quyền truy cập microphone để ghi âm'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _audioPath = '${directory.path}/free_speak_$timestamp.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _audioPath!,
      );

      setState(() {
        _isRecording = true;
        _errorMessage = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi bắt đầu ghi âm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path == null || path.isEmpty) {
        throw Exception('Không thể lưu file ghi âm');
      }

      setState(() {
        _isRecording = false;
        _isProcessing = true;
        _audioPath = path;
      });

      await _evaluateFreeSpeak(File(path));
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi dừng ghi âm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _evaluateFreeSpeak(File audioFile) async {
    try {
      // Lấy lịch sử hội thoại cho API
      final history = _messages.map((msg) {
        return {
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text,
        };
      }).toList();

      final response = await _apiService.checkFreeSpeaking(
        audioFile: audioFile,
        context: _contextController.text.trim().isEmpty
            ? null
            : _contextController.text.trim(),
        language: 'ko',
        history: history.isNotEmpty ? history : null,
      );

      final transcript = response['transcript'] as String? ?? '';
      final reply = response['reply'] as String? ?? '';
      final ttsUrl = response['tts_url'] as String?;
      final feedback = response['feedback_vi'] as String? ?? response['feedback'] as String?;

      setState(() {
        _isProcessing = false;

        // Thêm tin nhắn của user
        if (transcript.isNotEmpty) {
          _messages.add(ChatMessage(
            text: transcript,
            isUser: true,
            timestamp: DateTime.now(),
          ));
        }

        // Thêm tin nhắn của AI
        if (reply.isNotEmpty) {
          _messages.add(ChatMessage(
            text: reply,
            isUser: false,
            timestamp: DateTime.now(),
            ttsUrl: ttsUrl,
            feedback: feedback,
          ));
        }
      });

      _scrollToBottom();

      debugPrint('📝 Tổng số tin nhắn: ${_messages.length}');

      // Tự động phát audio của reply
      if (ttsUrl != null && ttsUrl.isNotEmpty) {
        debugPrint('🎵 Tự động phát audio reply');
        await Future.delayed(const Duration(milliseconds: 500));
        await _playAudio(ttsUrl);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đánh giá: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playAudio(String audioUrl) async {
    if (audioUrl.isEmpty) {
      debugPrint('⚠️ Audio URL trống');
      return;
    }

    // Dừng audio hiện tại nếu đang phát
    if (_currentPlayingUrl != null) {
      await _audioPlayer.stop();
    }

    setState(() {
      _currentPlayingUrl = audioUrl;
    });

    try {
      // Tạo full URL
      final fullUrl = _ttsService.getMediaUrl(audioUrl);
      debugPrint('🎵 Phát audio từ: $fullUrl');

      // Download file về local trước
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      final directory = await getTemporaryDirectory();
      final filename = 'tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final localFile = File('${directory.path}/$filename');

      // Xóa file cũ nếu có
      if (_tempAudioFile != null && await _tempAudioFile!.exists()) {
        await _tempAudioFile!.delete();
      }

      await localFile.writeAsBytes(response.bodyBytes);
      _tempAudioFile = localFile;
      debugPrint('✅ Đã download file về: ${localFile.path}');
      debugPrint('📊 File size: ${response.bodyBytes.length} bytes');

      // Phát từ file local
      await _audioPlayer.stop();
      await _audioPlayer.setSourceDeviceFile(localFile.path);
      await _audioPlayer.resume();

      debugPrint('✅ Đã bắt đầu phát audio từ file local');

    } catch (e, stackTrace) {
      debugPrint('❌ Lỗi khi phát audio: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      setState(() {
        _currentPlayingUrl = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể phát audio: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử hội thoại'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử hội thoại?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteOff,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Coach Ivy',
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Nói tự do - Hội thoại',
              style: TextStyle(
                color: AppColors.grayLight,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _clearChat,
              tooltip: 'Xóa lịch sử',
            ),
        ],
      ),
      body: Column(
        children: [
          // Context input (collapsed)
          if (_contextController.text.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primaryYellow.withOpacity(0.1),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Ngữ cảnh hội thoại'),
                      content: TextField(
                        controller: _contextController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: Tôi muốn nói về kế hoạch du lịch...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Đóng'),
                        ),
                      ],
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        color: AppColors.primaryYellow, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Thêm ngữ cảnh (tùy chọn)',
                      style: TextStyle(
                        color: AppColors.primaryYellow,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primaryYellow, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _contextController.text,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _contextController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Bắt đầu hội thoại',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn vào micro để bắt đầu nói',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayLight,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Error message
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _errorMessage = null),
                  ),
                ],
              ),
            ),

          // Recording button
          Container(
            padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isProcessing
                          ? 'Đang xử lý...'
                          : _isRecording
                          ? 'Đang ghi âm... Nhấn để dừng'
                          : 'Nhấn để bắt đầu nói',
                      style: TextStyle(
                        color: AppColors.grayLight,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _isProcessing ? null : (_isRecording ? _stopRecording : _startRecording),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? AppColors.error
                            : _isProcessing
                            ? AppColors.grayLight
                            : AppColors.primaryYellow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording
                                ? AppColors.error
                                : AppColors.primaryYellow).withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _isProcessing
                          ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      )
                          : Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryYellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppColors.primaryBlack
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : AppColors.primaryBlack,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      if (!message.isUser && message.ttsUrl != null) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _playAudio(message.ttsUrl!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _currentPlayingUrl == message.ttsUrl
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: AppColors.primaryYellow,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _currentPlayingUrl == message.ttsUrl
                                      ? 'Đang phát...'
                                      : 'Nghe phát âm',
                                  style: TextStyle(
                                    color: AppColors.primaryYellow,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (!message.isUser && message.feedback != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.grayLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: AppColors.grayLight,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  message.feedback!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grayLight,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.grayLight,
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryBlack,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? ttsUrl;
  final String? feedback;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.ttsUrl,
    this.feedback,
  });
}