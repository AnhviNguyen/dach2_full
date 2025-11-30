import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/vocabulary_item.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/services/tts_api_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VocabularyCard extends StatefulWidget {
  final VocabularyItem vocabulary;

  const VocabularyCard({
    super.key,
    required this.vocabulary,
  });

  @override
  State<VocabularyCard> createState() => _VocabularyCardState();
}

class _VocabularyCardState extends State<VocabularyCard> {
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
    
    final koreanText = widget.vocabulary.korean;
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlack,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.vocabulary.korean,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
              IconButton(
                onPressed: _isPlayingAudio ? null : _playPronunciation,
                icon: _isPlayingAudio
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryBlack,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.volume_up,
                        size: 20,
                        color: AppColors.primaryBlack,
                      ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.vocabulary.vietnamese,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.vocabulary.pronunciation,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primaryBlack,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              widget.vocabulary.example,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primaryBlack.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

