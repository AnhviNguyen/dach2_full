import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition.dart';
import 'package:koreanhwa_flutter/features/competition/data/models/competition_question.dart';
import 'package:koreanhwa_flutter/features/competition/data/services/competition_api_service.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/auth/providers/auth_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:koreanhwa_flutter/core/config/ai_api_config.dart';

class CompetitionJoinScreen extends ConsumerStatefulWidget {
  final Competition? competition;
  final int? competitionId;

  const CompetitionJoinScreen({super.key, this.competition, this.competitionId});

  @override
  ConsumerState<CompetitionJoinScreen> createState() => _CompetitionJoinScreenState();
}

class _CompetitionJoinScreenState extends ConsumerState<CompetitionJoinScreen> {
  int _currentQuestion = 0;
  Map<int, String> _answers = {}; // Changed to Map<int, String> to match API
  int _timeLeft = 300; // 5 minutes per question
  final CompetitionApiService _apiService = CompetitionApiService();
  Competition? _competition;
  List<CompetitionQuestion> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentlyPlayingQuestionId;
  PlayerState _audioPlayerState = PlayerState.stopped;
  bool _isLoadingAudio = false;

  @override
  void initState() {
    super.initState();
    if (widget.competition != null) {
      _competition = widget.competition;
      // Check if competition is active
      if (_competition!.status != 'active') {
        setState(() {
          _isLoading = false;
          _errorMessage = _competition!.status == 'upcoming'
              ? 'Cuộc thi chưa bắt đầu'
              : _competition!.status == 'completed'
                  ? 'Cuộc thi đã kết thúc'
                  : 'Không thể tham gia cuộc thi này';
        });
        return;
      }
      _loadQuestions();
    } else if (widget.competitionId != null) {
      _loadCompetitionAndQuestions();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không tìm thấy cuộc thi';
      });
    }
    
    // Lắng nghe trạng thái audio player
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _audioPlayerState = state;
          if (state == PlayerState.completed || state == PlayerState.stopped) {
            _currentlyPlayingQuestionId = null;
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadCompetitionAndQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = ref.read(authProvider).user?.id;
      final competition = await _apiService.getCompetitionById(widget.competitionId!, currentUserId: userId);
      
      // Check if competition is active
      if (competition.status != 'active') {
        setState(() {
          _competition = competition;
          _isLoading = false;
          _errorMessage = competition.status == 'upcoming'
              ? 'Cuộc thi chưa bắt đầu'
              : competition.status == 'completed'
                  ? 'Cuộc thi đã kết thúc'
                  : 'Không thể tham gia cuộc thi này';
        });
        return;
      }
      
      setState(() {
        _competition = competition;
      });
      await _loadQuestions();
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadQuestions() async {
    if (_competition == null) return;

    try {
      final questions = await _apiService.getCompetitionQuestions(_competition!.id);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải câu hỏi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _timeLeft > 0) {
        setState(() => _timeLeft--);
        _startTimer();
      }
    });
  }

  /// Play audio cho listening question
  Future<void> _playAudio(int questionId, String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) {
      return;
    }

    try {
      // Nếu đang phát câu hỏi khác, dừng lại
      if (_currentlyPlayingQuestionId != null && _currentlyPlayingQuestionId != questionId) {
        await _audioPlayer.stop();
      }

      // Nếu đang phát cùng câu hỏi, toggle pause/play
      if (_currentlyPlayingQuestionId == questionId && _audioPlayerState == PlayerState.playing) {
        await _audioPlayer.pause();
        return;
      }

      // Nếu đang pause, resume
      if (_currentlyPlayingQuestionId == questionId && _audioPlayerState == PlayerState.paused) {
        await _audioPlayer.resume();
        return;
      }

      // Build full URL
      String fullAudioUrl = audioUrl;
      if (!audioUrl.startsWith('http')) {
        // Relative path - thêm base URL
        final baseUrl = AiApiConfig.baseUrl.replaceAll('/api', '');
        if (audioUrl.startsWith('/')) {
          fullAudioUrl = '$baseUrl$audioUrl';
        } else {
          fullAudioUrl = '$baseUrl/$audioUrl';
        }
      }

      setState(() {
        _currentlyPlayingQuestionId = questionId;
        _isLoadingAudio = true;
        _audioPlayerState = PlayerState.stopped;
      });

      // Play audio
      await _audioPlayer.play(UrlSource(fullAudioUrl));

      setState(() {
        _isLoadingAudio = false;
        _audioPlayerState = PlayerState.playing;
      });
    } catch (e) {
      setState(() {
        _currentlyPlayingQuestionId = null;
        _audioPlayerState = PlayerState.stopped;
        _isLoadingAudio = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi phát audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Stop audio playback
  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlayingQuestionId = null;
        _audioPlayerState = PlayerState.stopped;
      });
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.black,
          title: Text('Đang tải...', style: TextStyle(color: isDark ? Colors.white : Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final competition = _competition;
    if (competition == null || _questions.isEmpty || _errorMessage != null) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.black,
          title: Text('Lỗi', style: TextStyle(color: isDark ? Colors.white : Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage ?? 'Không tìm thấy cuộc thi',
                style: TextStyle(color: isDark ? Colors.white : Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.competitionId != null ? _loadCompetitionAndQuestions : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.primaryBlack,
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentQuestion >= _questions.length) {
      _submitCompetition();
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
        ),
      );
    }

    final question = _questions[_currentQuestion];
    final progress = ((_currentQuestion + 1) / _questions.length);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header với timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          competition.title,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Câu ${_currentQuestion + 1}/${_questions.length}',
                          style: TextStyle(
                            color: isDark ? AppColors.grayLight : const Color(0xFF888888),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryYellow,
                          AppColors.primaryYellow.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryYellow.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, size: 16, color: Colors.black),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(_timeLeft),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            Container(
              height: 4,
              color: isDark ? AppColors.darkSurface : const Color(0xFF1A1A1A),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFF1A1A1A),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
              ),
            ),

            // Content - Scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Audio Player Section (chỉ hiển thị nếu có audio)
                    if (question.audioUrl.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryYellow.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                        children: [
                          // Audio Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryYellow.withOpacity(0.15),
                                  AppColors.primaryYellow.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryYellow,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.headphones,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Audio',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                // Category badges
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E88E5).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF1E88E5).withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    '${question.category}',
                                    style: const TextStyle(
                                      color: Color(0xFF64B5F6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Audio Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkBackground : Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? AppColors.darkDivider : const Color(0xFF2A2A2A),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        question.title,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        question.titleKr,
                                        style: TextStyle(
                                          color: AppColors.primaryYellow.withOpacity(0.9),
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Audio Waveform Visualization (simplified)
                                Container(
                                  height: 120,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkBackground : Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? AppColors.darkDivider : const Color(0xFF2A2A2A),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: List.generate(30, (index) {
                                      final height = (index % 5 + 1) * 15.0;
                                      final isActive = _audioPlayerState == PlayerState.playing;
                                      return Container(
                                        width: 4,
                                        height: height,
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? AppColors.primaryYellow
                                              : (isDark ? AppColors.darkDivider : const Color(0xFF2A2A2A)),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Progress Info
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _audioPlayerState == PlayerState.playing
                                          ? 'Đang phát...'
                                          : _audioPlayerState == PlayerState.paused
                                              ? 'Đã tạm dừng'
                                              : 'Nhấn để phát',
                                      style: const TextStyle(
                                        color: Color(0xFF888888),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      question.duration,
                                      style: const TextStyle(
                                        color: Color(0xFF888888),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Audio Controls
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkBackground : Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? AppColors.darkDivider : const Color(0xFF2A2A2A),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildAudioButton(
                                        icon: Icons.refresh,
                                        color: isDark ? Colors.white : Colors.white70,
                                        onPressed: () {
                                          _stopAudio();
                                        },
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryYellow.withOpacity(0.4),
                                              blurRadius: 16,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: _buildAudioButton(
                                          icon: _isLoadingAudio
                                              ? Icons.hourglass_empty
                                              : (_audioPlayerState == PlayerState.playing
                                                  ? Icons.pause
                                                  : Icons.play_arrow),
                                          color: AppColors.primaryYellow,
                                          isMain: true,
                                          onPressed: _isLoadingAudio
                                              ? null
                                              : () => _playAudio(question.id, question.audioUrl),
                                        ),
                                      ),
                                      if (_audioPlayerState == PlayerState.playing || _audioPlayerState == PlayerState.paused)
                                        _buildAudioButton(
                                          icon: Icons.stop,
                                          color: isDark ? Colors.white : Colors.white70,
                                          onPressed: _stopAudio,
                                        )
                                      else
                                        _buildAudioButton(
                                          icon: Icons.volume_up,
                                          color: isDark ? Colors.white : Colors.white70,
                                          onPressed: () {},
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Transcript (chỉ hiển thị nếu có)
                                if (question.transcript.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF2A2A2A),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.description,
                                              color: AppColors.primaryYellow.withOpacity(0.8),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Transcript Preview',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          question.transcript,
                                          style: const TextStyle(
                                            color: Color(0xFF999999),
                                            fontSize: 11,
                                            height: 1.5,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ),

                    // Question Section
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryYellow.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryYellow,
                                      AppColors.primaryYellow.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryYellow.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Q${_currentQuestion + 1}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E88E5).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF1E88E5).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    '${question.category} | ${question.categoryKr}',
                                    style: const TextStyle(
                                      color: Color(0xFF64B5F6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Question Text
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF2A2A2A),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question.question,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  question.questionKr,
                                  style: TextStyle(
                                    color: AppColors.primaryYellow.withOpacity(0.9),
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Answer Options
                          ...List.generate(question.options.length, (index) {
                            final selectedAnswer = _answers[question.id];
                            final isSelected = selectedAnswer == question.options[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  setState(() => _answers[question.id] = question.options[index]);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryYellow.withOpacity(0.15)
                                        : Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryYellow
                                          : const Color(0xFF2A2A2A),
                                      width: 2,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: AppColors.primaryYellow.withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? AppColors.primaryYellow
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryYellow
                                                : const Color(0xFF444444),
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.black,
                                        )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${String.fromCharCode(65 + index)}. ${question.options[index]}',
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFFAAAAAA),
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 16),

                          // Bottom Navigation
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF2A2A2A),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: _timeLeft < 60
                                          ? const Color(0xFFEF5350)
                                          : const Color(0xFF888888),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTime(_timeLeft),
                                      style: TextStyle(
                                        color: _timeLeft < 60
                                            ? const Color(0xFFEF5350)
                                            : const Color(0xFF888888),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: _answers.containsKey(question.id)
                                      ? () {
                                    if (_currentQuestion < _questions.length - 1) {
                                      setState(() {
                                        _currentQuestion++;
                                        _timeLeft = 300;
                                      });
                                    } else {
                                      _submitCompetition();
                                    }
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryYellow,
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor: const Color(0xFF333333),
                                    disabledForegroundColor: const Color(0xFF666666),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: _answers.containsKey(_currentQuestion) ? 4 : 0,
                                    shadowColor: AppColors.primaryYellow.withOpacity(0.4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _currentQuestion < _questions.length - 1
                                            ? 'Tiếp theo'
                                            : 'Hoàn thành',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        _currentQuestion < _questions.length - 1
                                            ? Icons.arrow_forward
                                            : Icons.check_circle,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAudioButton({
    required IconData icon,
    required Color color,
    bool isMain = false,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: _isLoadingAudio && isMain
          ? SizedBox(
              width: isMain ? 40 : 24,
              height: isMain ? 40 : 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          : Icon(icon, color: color),
      iconSize: isMain ? 40 : 24,
      onPressed: onPressed,
    );
  }

  Future<void> _submitCompetition() async {
    if (_competition == null) return;

    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để tham gia cuộc thi')),
      );
      return;
    }

    try {
      // Convert answers to Map<int, String> format for API
      final answersMap = <int, String>{};
      for (final entry in _answers.entries) {
        // Find question ID by answer
        final question = _questions.firstWhere(
          (q) => q.options.contains(entry.value),
          orElse: () => _questions.first,
        );
        answersMap[question.id] = entry.value;
      }

      await _apiService.submitCompetition(
        competitionId: _competition!.id,
        answers: answersMap,
        userId: userId,
      );

      // Navigate to result screen
      context.pushReplacement('/competition/evaluating', extra: _competition);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi nộp bài: ${e.toString()}')),
      );
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}