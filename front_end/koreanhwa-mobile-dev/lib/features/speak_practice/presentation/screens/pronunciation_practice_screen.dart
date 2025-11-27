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
  final List<_SoundCategory> _categories = const [
    _SoundCategory(id: 'vowels', title: 'Nguyên âm', icon: 'ㅏ'),
    _SoundCategory(id: 'consonants', title: 'Phụ âm', icon: 'ㄱ'),
    _SoundCategory(id: 'batchim', title: 'Phụ âm cuối', icon: 'ㅎ'),
    _SoundCategory(id: 'intonation', title: 'Ngữ điệu', icon: '🎵'),
  ];

  final Map<String, List<_SoundCard>> _sounds = const {
    'vowels': [
      _SoundCard(
        phoneme: 'ㅏ (a)',
        description: 'Âm mở rộng, môi thả lỏng và mở lớn.',
        examples: ['아빠 (appa)', '사과 (sagwa)', '사랑 (sarang)'],
        tip: 'Giữ hàm ổn định, mở miệng dọc giống phát âm tiếng Việt “a”.',
      ),
      _SoundCard(
        phoneme: 'ㅗ (o)',
        description: 'Âm tròn môi, hơi đưa môi về phía trước.',
        examples: ['오빠 (oppa)', '도로 (doro)', '모자 (moja)'],
        tip: 'Hơi chúm môi lại và đẩy luồng hơi ra phía trước.',
      ),
    ],
    'consonants': [
      _SoundCard(
        phoneme: 'ㄹ (r/l)',
        description: 'Âm rung nhẹ, giữa R và L trong tiếng Việt.',
        examples: ['라면 (ramyeon)', '우리 (uri)', '노을 (noeul)'],
        tip: 'Đặt đầu lưỡi chạm nhanh lên vòm cứng rồi thả ra ngay.',
      ),
      _SoundCard(
        phoneme: 'ㅂ (b/p)',
        description: 'Âm bật môi, không thả hơi mạnh.',
        examples: ['바다 (bada)', '밥 (bap)', '사랑받다 (sarangbatda)'],
        tip: 'Ngậm môi nhẹ rồi bật ra, không hít không khí quá sâu.',
      ),
    ],
    'batchim': [
      _SoundCard(
        phoneme: '받침 ㄱ',
        description: 'Kết thúc bằng /k/ nhẹ, không bật hơi rõ.',
        examples: ['한국 (hanguk)', '책 (chaek)', '부탁 (butak)'],
        tip: 'Đặt gốc lưỡi chạm lên vòm mềm và kết thúc âm ngay.',
      ),
      _SoundCard(
        phoneme: '받침 ㅁ',
        description: 'Âm mũi /m/ giữ môi khép.',
        examples: ['밤 (bam)', '삶 (salm)', '봄 (bom)'],
        tip: 'Khép môi và rung nhẹ vùng mũi khi kết thúc.',
      ),
    ],
    'intonation': [
      _SoundCard(
        phoneme: 'Câu hỏi lên giọng',
        description: 'Tăng cao độ ở cuối câu để thể hiện câu hỏi.',
        examples: ['괜찮아요?', '어디 가요?', '정말요?'],
        tip: 'Giữ tốc độ chậm, nhấn mạnh từ khóa và nâng giọng cuối.',
      ),
      _SoundCard(
        phoneme: 'Nhấn trọng âm',
        description: 'Tập trung vào từ khóa, giảm âm ở từ phụ.',
        examples: ['오늘 꼭 해요.', '지금 바로요.', '정말 좋아요.'],
        tip: 'Tăng âm lượng ở từ quan trọng, giữ nhịp rõ ràng.',
      ),
    ],
  };

  String _selectedCategory = 'vowels';
  _SoundCard? _currentDrill;
  bool _isRecording = false;
  bool _isProcessing = false;
  double? _score;
  String? _feedback;
  String? _transcript;
  String? _audioPath;
  bool? _modelStatus;
  bool _isCheckingModel = false;

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
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
        _modelStatus = response['loaded'] as bool? ?? false;
        _isCheckingModel = false;
      });
    } catch (e) {
      setState(() {
        _modelStatus = false;
        _isCheckingModel = false;
      });
    }
  }

  Future<void> _startRecording() async {
    // Request microphone permission
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
      // Get temporary directory for audio file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _audioPath = '${directory.path}/recording_$timestamp.m4a';

      // Start recording
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
        _score = null;
        _feedback = null;
        _transcript = null;
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

      // Get expected text from current drill
      // Use first example, extract Korean text (before parentheses)
      String expectedText = '';
      if (_currentDrill != null && _currentDrill!.examples.isNotEmpty) {
        final firstExample = _currentDrill!.examples.first;
        // Extract Korean text (before parentheses if exists)
        expectedText = firstExample.split('(').first.trim();
        // If no Korean text found, use phoneme
        if (expectedText.isEmpty) {
          expectedText = _currentDrill!.phoneme;
        }
      } else {
        expectedText = _currentDrill?.phoneme ?? '안녕하세요';
      }

      // Call API to check pronunciation
      await _checkPronunciation(File(path), expectedText);
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

      setState(() {
        _isProcessing = false;
        _score = score;
        _feedback = feedback;
        _transcript = transcript;
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
    final sounds = _sounds[_selectedCategory] ?? [];
    return Scaffold(
      backgroundColor: AppColors.whiteOff,
      appBar: AppBar(
        backgroundColor: AppColors.whiteOff,
        elevation: 0,
        title: const Text(
          'Phòng lab phát âm',
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
      body: Column(
        children: [
          _buildHeader(),
          _buildModelStatus(),
          _buildCategoryChips(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                const SizedBox(height: 12),
                ...sounds.map(
                  (sound) => _SoundCardWidget(
                    sound: sound,
                    onPractice: () {
                      setState(() {
                        _currentDrill = sound;
                        _score = null;
                      });
                      _showDrillSheet(sound);
                    },
                    onPlayTTS: _playTTS,
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category.id == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryYellow : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlack : Colors.black.withOpacity(0.08),
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.primaryYellow.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category.icon, style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      category.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primaryBlack : AppColors.grayLight,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelected ? 'Đang luyện' : 'Chọn luyện',
                    style: TextStyle(
                      color: isSelected ? AppColors.primaryBlack : AppColors.grayLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _categories.length,
      ),
    );
  }

  Future<void> _showDrillSheet(_SoundCard sound) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          maxChildSize: 0.92,
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
                  Text(
                    sound.phoneme,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sound.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.grayLight),
                  ),
                  const SizedBox(height: 24),
                  _buildExamples(sound.examples),
                  const SizedBox(height: 16),
                  _buildTip(sound.tip),
                  const SizedBox(height: 24),
                  _buildRecorder(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExamples(List<String> words) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Từ/câu ví dụ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: words
              .map(
                (word) => GestureDetector(
                  onTap: () {
                    // Extract Korean text and play TTS
                    final koreanText = word.split('(').first.trim();
                    if (koreanText.isNotEmpty) {
                      _playTTS(koreanText);
                    }
                  },
                  child: Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(word),
                        const SizedBox(width: 4),
                        const Icon(Icons.volume_up, size: 16),
                      ],
                    ),
                    backgroundColor: AppColors.primaryYellow.withOpacity(0.18),
                    side: const BorderSide(color: AppColors.primaryYellow),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTip(String tip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(color: AppColors.primaryBlack),
            ),
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

class _SoundCardWidget extends StatelessWidget {
  final _SoundCard sound;
  final VoidCallback onPractice;
  final Future<void> Function(String) onPlayTTS;

  const _SoundCardWidget({
    required this.sound,
    required this.onPractice,
    required this.onPlayTTS,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                sound.phoneme,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // Play TTS for first example
                  if (sound.examples.isNotEmpty) {
                    final firstExample = sound.examples.first;
                    final koreanText = firstExample.split('(').first.trim();
                    if (koreanText.isNotEmpty) {
                      onPlayTTS(koreanText);
                    }
                  }
                },
                icon: const Icon(Icons.volume_up),
                color: AppColors.primaryBlack,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(sound.description, style: const TextStyle(color: AppColors.grayLight)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sound.examples
                .map(
                  (word) => Chip(
                    label: Text(word),
                    backgroundColor: AppColors.whiteGray,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPractice,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlack,
              foregroundColor: AppColors.primaryYellow,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), // Tăng ngang ở đây
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Bắt đầu luyện',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundCategory {
  final String id;
  final String title;
  final String icon;

  const _SoundCategory({
    required this.id,
    required this.title,
    required this.icon,
  });
}

class _SoundCard {
  final String phoneme;
  final String description;
  final List<String> examples;
  final String tip;

  const _SoundCard({
    required this.phoneme,
    required this.description,
    required this.examples,
    required this.tip,
  });
}

