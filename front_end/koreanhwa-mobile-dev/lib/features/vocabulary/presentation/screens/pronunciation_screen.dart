import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/services/tts_api_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PronunciationScreen extends StatefulWidget {
  final int bookId;
  final int lessonId;
  final List<Map<String, String>> vocabList;

  const PronunciationScreen({
    super.key,
    required this.bookId,
    required this.lessonId,
    required this.vocabList,
  });

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  int _currentWord = 0;
  final TtsApiService _ttsService = TtsApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;
  StreamSubscription? _playerCompleteSubscription;
  File? _tempAudioFile;

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    _tempAudioFile?.delete();
    super.dispose();
  }

  Future<void> _playPronunciation() async {
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

  @override
  Widget build(BuildContext context) {
    final vocab = widget.vocabList[_currentWord];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryWhite),
        ),
        title: const Text(
          'Pronunciation',
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primaryWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF4CAF50),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    vocab['korean']!,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vocab['pronunciation']!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vocab['vietnamese']!,
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.primaryBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isPlayingAudio ? null : _playPronunciation,
              icon: _isPlayingAudio
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryWhite,
                        ),
                      ),
                    )
                  : const Icon(Icons.volume_up, size: 28),
              label: Text(
                _isPlayingAudio ? 'Đang phát...' : 'Nghe phát âm',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlayingAudio
                    ? const Color(0xFF4CAF50).withOpacity(0.6)
                    : const Color(0xFF4CAF50),
                foregroundColor: AppColors.primaryWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                vocab['example']!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryBlack.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentWord = (_currentWord - 1 + widget.vocabList.length) %
                          widget.vocabList.length;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    foregroundColor: AppColors.primaryWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Trước',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentWord = (_currentWord + 1) % widget.vocabList.length;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.primaryBlack,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
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
                        'Sau',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

