import 'dart:io';
import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/services/speaking_api_service.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/services/tts_api_service.dart';
import 'package:koreanhwa_flutter/features/speak_practice/data/services/user_progress_api_service.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PronunciationPracticeScreen extends StatefulWidget {
  const PronunciationPracticeScreen({super.key});

  @override
  State<PronunciationPracticeScreen> createState() => _PronunciationPracticeScreenState();
}

class _PronunciationPracticeScreenState extends State<PronunciationPracticeScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final SpeakingApiService _apiService = SpeakingApiService();
  final TtsApiService _ttsService = TtsApiService();
  final UserProgressApiService _progressService = UserProgressApiService();
  bool _isRecording = false;
  bool _isProcessing = false;
  double? _score;
  String? _feedback;
  String? _transcript;
  String? _audioPath;
  bool? _modelStatus;
  bool _isCheckingModel = false;
  Directory? _tempDirectory; // Cache temp directory
  
  // Phrases mode
  bool _isPhrasesMode = false;
  Map<String, dynamic>? _phrasesData;
  List<String> _availableCategories = [];
  String? _selectedPhraseCategory;
  List<String> _currentPhrases = [];
  String? _selectedPhrase;
  bool _isLoadingPhrases = false;
  Map<String, dynamic>? _pronunciationFeedback;

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
    _loadPhrases();
    _initTempDirectory(); // Pre-load temp directory
  }

  Future<void> _initTempDirectory() async {
    // Pre-load temp directory to avoid delay when recording
    try {
      _tempDirectory = await getTemporaryDirectory();
      debugPrint('✅ Temp directory initialized: ${_tempDirectory?.path}');
    } catch (e) {
      debugPrint('❌ Error initializing temp directory: $e');
    }
  }
  
  Future<void> _loadPhrases() async {
    setState(() => _isLoadingPhrases = true);
    try {
      final data = await _apiService.getKoreanPhrases();
      setState(() {
        _phrasesData = data;
        if (data['categories'] != null) {
          final categoriesMap = data['categories'] as Map;
          _availableCategories = categoriesMap.keys.map((k) => k.toString()).toList();
          if (_availableCategories.isNotEmpty) {
            _selectedPhraseCategory = _availableCategories.first;
            _updateCurrentPhrases();
          }
        }
        _isLoadingPhrases = false;
      });
    } catch (e) {
      setState(() => _isLoadingPhrases = false);
      debugPrint('Error loading phrases: $e');
    }
  }
  
  void _updateCurrentPhrases() {
    if (_phrasesData != null && 
        _selectedPhraseCategory != null && 
        _phrasesData!['categories'] != null) {
      final category = _phrasesData!['categories'][_selectedPhraseCategory];
      if (category != null && category['phrases'] != null) {
        final phrasesList = category['phrases'] as List<dynamic>?;
        if (phrasesList != null) {
          _currentPhrases = phrasesList.map((p) => p.toString()).toList();
        }
      }
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _checkModelStatus() async {
    setState(() => _isCheckingModel = true);
    try {
      final response = await _apiService.getModelStatus();
      setState(() {
        // Backend returns 'model_loaded' or 'available' key
        final modelLoaded = response['model_loaded'] as bool?;
        final available = response['available'] as bool?;
        final status = response['status'] as String?;
        final statusReady = status == 'ready';
        
        _modelStatus = modelLoaded ?? available ?? statusReady;
        _isCheckingModel = false;
      });
    } catch (e) {
      setState(() {
        _modelStatus = false;
        _isCheckingModel = false;
      });
      debugPrint('Error checking model status: $e');
    }
  }

// Cập nhật lại _startRecording để update state tốt hơn
  Future<void> _startRecording() async {
    // Clear previous results
    setState(() {
      _score = null;
      _feedback = null;
      _transcript = null;
      _pronunciationFeedback = null;
    });

    // Request permission
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
      // Get temp directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _audioPath = '${directory.path}/recording_$timestamp.m4a';

      debugPrint('🎤 Starting recording...');

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: _audioPath!,
      );

      setState(() {
        _isRecording = true;
      });

      debugPrint('✅ Recording started successfully');
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
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

// Cập nhật _stopRecording
  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    try {
      debugPrint('🛑 Stopping recording...');
      final path = await _audioRecorder.stop();

      if (path == null || path.isEmpty) {
        throw Exception('Không thể lưu file ghi âm');
      }

      debugPrint('✅ Recording stopped: $path');

      setState(() {
        _audioPath = path;
      });

      String expectedText = _selectedPhrase ?? '안녕하세요';
      await _checkPronunciation(File(path), expectedText);

    } catch (e) {
      debugPrint('❌ Error stopping recording: $e');
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

  Future<void> _checkPronunciation(File audioFile, String expectedText) async {
    try {
      final response = await _apiService.checkReadAloud(
        audioFile: audioFile,
        expectedText: expectedText,
        language: 'ko',
      );

      final score = response['overall_score'] as double? ?? 
                   response['word_accuracy'] as double? ?? 0.0;
      final feedback = response['feedback_vi'] as String? ?? 
                      response['ai_feedback'] as String? ?? '';
      final transcript = response['transcript'] as String?;
      final wordErrors = response['word_errors'] as List<dynamic>? ?? [];
      final pronunciationFeedback = response['pronunciation_feedback'] as Map<String, dynamic>?;

      setState(() {
        _isProcessing = false;
        _score = score;
        _feedback = feedback;
        _transcript = transcript;
        _pronunciationFeedback = pronunciationFeedback;
      });

      // Save weak words if score is low
      if (score < 85 && wordErrors.isNotEmpty) {
        await _saveWeakWords(expectedText, wordErrors);
      }

      // Show success message
      if (mounted && _score != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đánh giá hoàn tất! Điểm: ${_score!.toStringAsFixed(0)}%'),
            backgroundColor: _score! >= 85 ? Colors.green : 
                           _score! >= 70 ? Colors.orange : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đánh giá phát âm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveWeakWords(String expectedText, List<dynamic> wordErrors) async {
    try {
      // Get user ID (you may need to get this from auth provider)
      const userId = 'user_1'; // TODO: Get from auth provider
      final now = DateTime.now().toIso8601String();

      for (final error in wordErrors) {
        final word = error['word'] as String? ?? '';
        final errorType = error['error_type'] as String? ?? 'mispronunciation';
        final errorCount = error['error_count'] as int? ?? 1;

        if (word.isNotEmpty) {
          await _progressService.saveWeakWord(
            userId: userId,
            word: word,
            errorType: errorType,
            errorCount: errorCount,
            lastPracticed: now,
          );
        }
      }
    } catch (e) {
      // Silently fail - weak words saving is not critical
      debugPrint('Error saving weak words: $e');
    }
  }

  Future<void> _playTTS(String text) async {
    try {
      final response = await _ttsService.generateSpeech(
        text: text,
        lang: 'ko',
      );

      final audioUrl = response['audio_url'] as String?;
      if (audioUrl != null) {
        final fullUrl = _ttsService.getMediaUrl(audioUrl);
        final uri = Uri.parse(fullUrl);
        
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi phát âm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.whiteOff),
        elevation: 0,
        title: Text(
          'Phòng lab phát âm',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.appBarTheme.foregroundColor ?? (isDark ? Colors.white : AppColors.primaryBlack)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildModeSelector(),
          _buildHeader(),
          _buildModelStatus(),
          if (!_isPhrasesMode) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mic_none,
                      size: 64,
                      color: AppColors.grayLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chế độ Phòng lab đang được phát triển',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.grayLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng sử dụng chế độ "Luyện phrases"',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grayLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            _buildPhrasesCategorySelector(),
            Expanded(
              child: _isLoadingPhrases
                  ? const Center(child: CircularProgressIndicator())
                  : _currentPhrases.isEmpty
                      ? const Center(child: Text('Không có phrases'))
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: [
                            const SizedBox(height: 12),
                            ..._currentPhrases.map(
                              (phrase) => _buildPhraseCard(phrase),
                            ),
                          ],
                        ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isPhrasesMode = false;
                _selectedPhrase = null;
                _pronunciationFeedback = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isPhrasesMode ? AppColors.primaryYellow : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Phòng lab',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: !_isPhrasesMode ? AppColors.primaryBlack : AppColors.grayLight,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _isPhrasesMode = true;
                _score = null;
                _pronunciationFeedback = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isPhrasesMode ? AppColors.primaryYellow : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Luyện phrases',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isPhrasesMode ? AppColors.primaryBlack : AppColors.grayLight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhrasesCategorySelector() {
    if (_availableCategories.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _availableCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final categoryId = _availableCategories[index];
          final category = _phrasesData?['categories']?[categoryId];
          final isSelected = _selectedPhraseCategory == categoryId;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPhraseCategory = categoryId;
                _updateCurrentPhrases();
                _selectedPhrase = null;
                _pronunciationFeedback = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryYellow : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlack : Colors.black.withOpacity(0.1),
                ),
              ),
              child: Center(
                child: Text(
                  category?['name'] ?? categoryId,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primaryBlack : AppColors.grayLight,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhraseCard(String phrase) {
    final isSelected = _selectedPhrase == phrase;
    
    return GestureDetector(
      onTap: () {
        // Update state immediately and show sheet without await to prevent blocking
        setState(() {
          _selectedPhrase = phrase;
          _score = null;
          _pronunciationFeedback = null;
          _transcript = null;
          _feedback = null;
        });
        // Show bottom sheet without blocking
        _showPhraseDrillSheet(phrase);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryYellow.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryYellow : Colors.black.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                phrase,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlack,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () => _playTTS(phrase),
              color: AppColors.primaryYellow,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.grayLight,
            ),
          ],
        ),
      ),
    );
  }

  void _showPhraseDrillSheet(String phrase) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: false, // Không cho đóng khi đang ghi âm
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.6,
              builder: (_, controller) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ListView(
                    controller: controller,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Hiển thị phrase với highlight đúng/sai nếu có feedback
                      _buildHighlightedPhrase(phrase),
                      const SizedBox(height: 8),
                      const Text(
                        'Nhấn vào micro để luyện phát âm',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.grayLight),
                      ),
                      const SizedBox(height: 24),

                      // RECORDER với state riêng trong modal
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (_isRecording) {
                                // Update cả 2 state
                                setState(() => _isRecording = false);
                                setModalState(() {});
                                await _stopRecording();
                                // Update lại sau khi xong
                                setModalState(() {});
                              } else {
                                // Clear results
                                setState(() {
                                  _isRecording = true;
                                  _score = null;
                                  _feedback = null;
                                  _transcript = null;
                                  _pronunciationFeedback = null;
                                });
                                setModalState(() {});
                                await _startRecording();
                                // Update lại sau khi xong
                                setModalState(() {});
                              }
                            },
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: _isRecording
                                    ? AppColors.error
                                    : _isProcessing
                                    ? AppColors.grayLight
                                    : AppColors.primaryBlack,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _isRecording
                                        ? AppColors.error.withOpacity(0.2)
                                        : Colors.black12,
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                              child: _isProcessing
                                  ? const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 3,
                                ),
                              )
                                  : Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: _isRecording ? Colors.white : AppColors.primaryYellow,
                                size: 48,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isProcessing
                                ? 'Đang xử lý...'
                                : _isRecording
                                ? 'Đang ghi âm... Chạm để dừng'
                                : 'Chạm để bắt đầu luyện',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),

                          if (_transcript != null && _transcript!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.whiteGray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Bạn đã nói:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grayLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _transcript!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.primaryBlack,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          // Hiển thị expected text với highlight đúng/sai
                          if (_pronunciationFeedback != null && _selectedPhrase != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Phát âm của bạn:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.grayLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                                      SizedBox(width: 4),
                                      Text('Đúng', style: TextStyle(fontSize: 12, color: Colors.green)),
                                      SizedBox(width: 16),
                                      Icon(Icons.cancel, color: Colors.red, size: 16),
                                      SizedBox(width: 4),
                                      Text('Sai', style: TextStyle(fontSize: 12, color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildHighlightedPhrase(_selectedPhrase!),
                                ],
                              ),
                            ),
                          ],

                          if (_score != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Điểm chính xác: ${_score!.clamp(0, 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _score! >= 85
                                    ? AppColors.success
                                    : _score! >= 70
                                    ? Colors.orange
                                    : AppColors.error,
                              ),
                            ),
                            if (_feedback != null && _feedback!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryYellow.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryYellow.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  _feedback!,
                                  style: const TextStyle(
                                    color: AppColors.primaryBlack,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 4),
                              Text(
                                _score! >= 85
                                    ? 'Tuyệt vời! Phát âm rất tốt!'
                                    : _score! >= 70
                                    ? 'Tốt lắm! Tiếp tục luyện tập nhé!'
                                    : 'Cố gắng luyện tập thêm nhé!',
                                style: const TextStyle(color: AppColors.grayLight),
                              ),
                            ],
                          ],
                        ],
                      ),

                      if (_pronunciationFeedback != null) ...[
                        const SizedBox(height: 24),
                        _buildPronunciationFeedback(),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }


  Widget _buildPronunciationFeedback() {
    if (_pronunciationFeedback == null) return const SizedBox.shrink();
    
    final feedback = _pronunciationFeedback!;
    final phonemeAccuracy = feedback['phoneme_accuracy'] as double? ?? 0.0;
    final summary = feedback['summary'] as Map<String, dynamic>?;
    final phonemeDetails = feedback['phoneme_details'] as List<dynamic>? ?? [];
    final wordFeedback = feedback['word_feedback'] as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Độ chính xác phoneme: ${phonemeAccuracy.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (summary != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Đúng', summary['correct_phonemes'] ?? 0, Colors.green),
                    _buildStatItem('Sai', summary['wrong_phonemes'] ?? 0, Colors.red),
                    _buildStatItem('Thiếu', summary['missing_phonemes'] ?? 0, Colors.orange),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Phụ âm đầu', summary['initial_errors'] ?? 0, Colors.blue),
                    _buildStatItem('Nguyên âm', summary['vowel_errors'] ?? 0, Colors.purple),
                    _buildStatItem('Phụ âm cuối', summary['final_errors'] ?? 0, Colors.teal),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (wordFeedback.isNotEmpty) ...[
          const Text(
            'Chi tiết từng từ:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...wordFeedback.map((wf) => _buildWordFeedbackCard(wf)),
        ],
        const SizedBox(height: 16),
        if (phonemeDetails.isNotEmpty) ...[
          const Text(
            'Chi tiết từng phoneme:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: phonemeDetails.take(20).map((pd) {
              final isCorrect = pd['is_correct'] as bool? ?? false;
              final expected = pd['expected'] as String? ?? '';
              final predicted = pd['predicted'] as String? ?? '';
              final type = pd['type'] as String? ?? 'other';
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      expected,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    if (!isCorrect && predicted.isNotEmpty)
                      Text(
                        '→ $predicted',
                        style: const TextStyle(fontSize: 10),
                      ),
                    Text(
                      type,
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.grayLight),
        ),
      ],
    );
  }

  /// Map phonemes về từng ký tự Hangul
  /// Mỗi ký tự Hangul có 2-3 phonemes: initial (lead), vowel, final (tail - optional)
  /// Sử dụng phoneme_details từ backend để map chính xác
  Map<int, List<int>> _mapPhonemesToCharacters(String text, List<dynamic> phonemeDetails) {
    final charPhonemeMap = <int, List<int>>{}; // char index -> [phoneme indices in phonemeDetails]
    int phonemeDetailIndex = 0;
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final code = char.codeUnitAt(0);
      
      // Kiểm tra xem có phải ký tự Hangul không (0xAC00 - 0xD7A3)
      if (code >= 0xAC00 && code <= 0xD7A3) {
        final s = code - 0xAC00;
        final t = s % 28; // tail index
        
        // Mỗi ký tự Hangul có:
        // - 1 phoneme initial (lead) - luôn có
        // - 1 phoneme vowel - luôn có
        // - 0-1 phoneme final (tail) - có thể có hoặc không
        final phonemeIndices = <int>[];
        
        // Tìm phonemes của ký tự này trong phonemeDetails
        // Bỏ qua các phoneme <sp> và <blank>
        int foundPhonemes = 0;
        int targetPhonemes = (t > 0) ? 3 : 2; // 2 hoặc 3 phonemes
        
        while (foundPhonemes < targetPhonemes && phonemeDetailIndex < phonemeDetails.length) {
          final phonemeDetail = phonemeDetails[phonemeDetailIndex] as Map<String, dynamic>?;
          final expected = phonemeDetail?['expected'] as String? ?? '';
          
          // Bỏ qua <sp> và <blank> và empty
          if (expected != '<sp>' && expected != '<blank>' && expected.isNotEmpty) {
            phonemeIndices.add(phonemeDetailIndex);
            foundPhonemes++;
          }
          phonemeDetailIndex++;
        }
        
        if (phonemeIndices.isNotEmpty) {
          charPhonemeMap[i] = phonemeIndices;
        }
      } else if (char == ' ') {
        // Space -> có thể có <sp> phoneme, bỏ qua
        while (phonemeDetailIndex < phonemeDetails.length) {
          final phonemeDetail = phonemeDetails[phonemeDetailIndex] as Map<String, dynamic>?;
          final expected = phonemeDetail?['expected'] as String? ?? '';
          if (expected == '<sp>' || expected == '<blank>') {
            phonemeDetailIndex++;
            break;
          }
          // Nếu không phải <sp>, có thể là phoneme của ký tự tiếp theo
          break;
        }
      } else {
        // Ký tự khác (không phải Hangul) -> không map
        // Có thể là dấu câu, số, v.v.
      }
    }
    
    return charPhonemeMap;
  }

  Widget _buildHighlightedPhrase(String phrase) {
    // Nếu không có feedback, hiển thị text bình thường
    if (_pronunciationFeedback == null) {
      return Text(
        phrase,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlack,
        ),
        textAlign: TextAlign.center,
      );
    }

    final phonemeDetails = _pronunciationFeedback!['phoneme_details'] as List<dynamic>? ?? [];
    
    // Map phonemes về từng ký tự (sử dụng phonemeDetails để map chính xác)
    final charPhonemeMap = _mapPhonemesToCharacters(phrase, phonemeDetails);
    
    final textSpans = <TextSpan>[];

    // Xử lý từng ký tự trong phrase
    for (int i = 0; i < phrase.length; i++) {
      final char = phrase[i];
      final phonemeIndices = charPhonemeMap[i];
      
      // Xác định màu sắc dựa trên phonemes của ký tự này
      Color textColor = AppColors.primaryBlack;
      bool hasError = false;
      
      if (phonemeIndices != null && phonemeIndices.isNotEmpty) {
        // Kiểm tra từng phoneme của ký tự này
        for (final phnIdx in phonemeIndices) {
          if (phnIdx < phonemeDetails.length) {
            final phonemeDetail = phonemeDetails[phnIdx] as Map<String, dynamic>?;
            final isCorrect = phonemeDetail?['is_correct'] as bool? ?? true;
            final isMissing = phonemeDetail?['is_missing'] as bool? ?? false;
            final isExtra = phonemeDetail?['is_extra'] as bool? ?? false;
            
            // Nếu có phoneme sai, thiếu, hoặc thừa -> ký tự này có lỗi
            if (!isCorrect || isMissing || isExtra) {
              hasError = true;
              break;
            }
          }
        }
      }
      
      // Màu xanh nếu đúng, màu đỏ nếu sai
      textColor = hasError ? Colors.red : Colors.green;

      textSpans.add(
        TextSpan(
          text: char,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: textSpans),
    );
  }

  Widget _buildWordFeedbackCard(Map<String, dynamic> wf) {
    final word = wf['word'] as String? ?? '';
    final accuracy = wf['accuracy'] as double? ?? 0.0;
    final isCorrect = wf['is_correct'] as bool? ?? false;
    final phonemes = wf['phonemes'] as List<dynamic>? ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.orange,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                word,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.orange,
                ),
              ),
              Text(
                '${accuracy.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          if (phonemes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: phonemes.map((phn) {
                final isPhnCorrect = phn['is_correct'] as bool? ?? false;
                final exp = phn['expected'] as String? ?? '';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPhnCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    exp,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPhnCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4C2), Color(0xFFFFE082)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlack,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.graphic_eq, color: AppColors.primaryYellow, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Mục tiêu hôm nay',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryBlack,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Luyện 2 nguyên âm + 1 phụ âm cuối, đạt điểm tối thiểu 85/100.',
                  style: TextStyle(color: AppColors.grayLight, height: 1.3),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '85%',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelStatus() {
    if (_isCheckingModel) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            const Text('Đang kiểm tra model...', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (_modelStatus ?? false) ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_modelStatus ?? false) ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            (_modelStatus ?? false) ? Icons.check_circle : Icons.warning,
            color: (_modelStatus ?? false) ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              (_modelStatus ?? false) 
                  ? 'Model pronunciation đã sẵn sàng' 
                  : 'Model pronunciation chưa sẵn sàng',
              style: TextStyle(
                fontSize: 12,
                color: (_modelStatus ?? false) ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!(_modelStatus ?? false))
            TextButton(
              onPressed: _checkModelStatus,
              child: const Text('Thử lại', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }


  Widget _buildRecorder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _isRecording ? _stopRecording : _startRecording,
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: _isRecording 
                  ? AppColors.error 
                  : _isProcessing 
                      ? AppColors.grayLight 
                      : AppColors.primaryBlack,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _isRecording 
                      ? AppColors.error.withOpacity(0.2) 
                      : Colors.black12,
                  blurRadius: 24,
                ),
              ],
            ),
            child: _isProcessing
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  )
                : Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: _isRecording ? Colors.white : AppColors.primaryYellow,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isProcessing 
              ? 'Đang xử lý...' 
              : _isRecording 
                  ? 'Đang ghi âm...' 
                  : 'Chạm để bắt đầu luyện',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        if (_transcript != null && _transcript!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.whiteGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Bạn đã nói:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grayLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _transcript!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
        if (_score != null) ...[
          const SizedBox(height: 16),
          Text(
            'Điểm chính xác: ${_score!.clamp(0, 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _score! >= 85 
                  ? AppColors.success 
                  : _score! >= 70 
                      ? Colors.orange 
                      : AppColors.error,
            ),
          ),
          if (_feedback != null && _feedback!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.3),
                ),
              ),
              child: Text(
                _feedback!,
                style: const TextStyle(
                  color: AppColors.primaryBlack,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
          const SizedBox(height: 4),
            Text(
              _score! >= 85 
                  ? 'Tuyệt vời! Phát âm rất tốt!' 
                  : _score! >= 70 
                      ? 'Tốt lắm! Tiếp tục luyện tập nhé!' 
                      : 'Cố gắng luyện tập thêm nhé!',
              style: const TextStyle(color: AppColors.grayLight),
          ),
          ],
        ],
      ],
    );
  }
}


