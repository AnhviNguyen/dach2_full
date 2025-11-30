import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/services/tts_api_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ListenWriteScreen extends StatefulWidget {
  final int bookId;
  final int lessonId;
  final List<Map<String, String>> vocabList;

  const ListenWriteScreen({
    super.key,
    required this.bookId,
    required this.lessonId,
    required this.vocabList,
  });

  @override
  State<ListenWriteScreen> createState() => _ListenWriteScreenState();
}

class _ListenWriteScreenState extends State<ListenWriteScreen> {
  int _currentWord = 0;
  final TextEditingController _answerController = TextEditingController();
  bool _showResult = false;
  final TtsApiService _ttsService = TtsApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;
  StreamSubscription? _playerCompleteSubscription;
  File? _tempAudioFile;

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _answerController.dispose();
    _audioPlayer.dispose();
    _tempAudioFile?.delete();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (_isPlayingAudio || !mounted) return;
    
    final vocab = widget.vocabList[_currentWord];
    final koreanText = vocab['korean'] ?? '';
    
    if (koreanText.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _isPlayingAudio = true;
    });

    try {
      // Generate TTS
      final response = await _ttsService.generateSpeech(
        text: koreanText,
        lang: 'ko', // Korean
      );

      if (!mounted) return;

      final audioUrl = response['audio_url'] as String?;
      if (audioUrl != null) {
        final fullUrl = _ttsService.getMediaUrl(audioUrl);
        
        // Download audio file to local storage first (to avoid cleartext HTTP issues)
        final httpResponse = await http.get(Uri.parse(fullUrl));
        if (httpResponse.statusCode != 200) {
          throw Exception('HTTP ${httpResponse.statusCode}: ${httpResponse.reasonPhrase}');
        }

        final directory = await getTemporaryDirectory();
        final filename = 'tts_${koreanText.hashCode}.mp3';
        final localFile = File('${directory.path}/$filename');

        // Delete old temp file if exists
        if (_tempAudioFile != null && await _tempAudioFile!.exists()) {
          await _tempAudioFile!.delete();
        }

        await localFile.writeAsBytes(httpResponse.bodyBytes);
        _tempAudioFile = localFile;
        
        // Cancel previous subscription if exists
        await _playerCompleteSubscription?.cancel();
        
        // Play audio from local file
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(localFile.path));
        
        // Wait for audio to finish
        _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _isPlayingAudio = false;
            });
          }
        });
      } else {
        if (mounted) {
          setState(() {
            _isPlayingAudio = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi phát âm: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkAnswer() {
    setState(() {
      _showResult = true;
    });
  }

  void _nextWord() {
    setState(() {
      _currentWord = (_currentWord + 1) % widget.vocabList.length;
      _answerController.clear();
      _showResult = false;
    });
  }

  bool get _isCorrect {
    final vocab = widget.vocabList[_currentWord];
    return _answerController.text.trim().toLowerCase() ==
        vocab['korean']!.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final vocab = widget.vocabList[_currentWord];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryWhite),
        ),
        title: const Text(
          'Listen & Write',
          style: TextStyle(
            color: AppColors.primaryWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '${_currentWord + 1} / ${widget.vocabList.length}',
                style: const TextStyle(
                  color: AppColors.primaryWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primaryWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFF9800),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: _isPlayingAudio ? null : _playAudio,
                      iconSize: 64,
                      icon: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _isPlayingAudio 
                              ? const Color(0xFFFF9800).withOpacity(0.6)
                              : const Color(0xFFFF9800),
                          shape: BoxShape.circle,
                        ),
                        child: _isPlayingAudio
                            ? const SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryWhite,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.volume_up,
                                color: AppColors.primaryWhite,
                                size: 48,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nghe và viết từ tiếng Hàn',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryBlack.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vocab['vietnamese']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _answerController,
                      enabled: !_showResult,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập từ tiếng Hàn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF9800),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF9800),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF9800),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    if (_showResult) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isCorrect
                              ? AppColors.success.withOpacity(0.2)
                              : const Color(0xFFF44336).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isCorrect
                                ? AppColors.success
                                : const Color(0xFFF44336),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _isCorrect ? '✓ Chính xác!' : '✗ Sai rồi!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _isCorrect
                                    ? AppColors.success
                                    : const Color(0xFFF44336),
                              ),
                            ),
                            if (!_isCorrect) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Đáp án đúng: ${vocab['korean']!}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (!_showResult)
                      ElevatedButton(
                        onPressed: _checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: AppColors.primaryWhite,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Kiểm tra',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: _nextWord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: AppColors.primaryBlack,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tiếp theo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

