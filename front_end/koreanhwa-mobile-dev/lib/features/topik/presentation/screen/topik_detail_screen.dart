import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/features/topik/presentation/screen/topik_test_form_screen.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/models/exam_model.dart';

class TopikDetailScreen extends StatefulWidget {
  final String examId;
  final String examTitle;

  const TopikDetailScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<TopikDetailScreen> createState() => _TopikDetailScreenState();
}

class _TopikDetailScreenState extends State<TopikDetailScreen> {
  String _activePracticeTab = 'practice'; // practice or fullTest
  Map<String, bool> _selectedSections = {
    'listening': false,
    'reading': false,
  };
  String _timeLimit = '';

  void _handleSectionChange(String section) {
    setState(() {
      _selectedSections[section] = !(_selectedSections[section] ?? false);
    });
  }

  void _handleSubmit(bool isFullTest) {
    if (!isFullTest) {
      if (!_selectedSections['listening']! &&
          !_selectedSections['reading']!) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ít nhất một phần thi!'),
            backgroundColor: Color(0xFFF44336),
          ),
        );
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopikTestFormScreen(
          examId: widget.examId,
          examTitle: widget.examTitle,
          isFullTest: isFullTest,
          selectedSections: _selectedSections,
          timeLimit: _timeLimit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
        ),
        title: const Text(
          'Chi tiết đề thi',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Test Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryBlack.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '#TOPIK한국어',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.examTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _activePracticeTab = 'info'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _activePracticeTab == 'info'
                                  ? AppColors.primaryYellow.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _activePracticeTab == 'info'
                                    ? AppColors.primaryYellow
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Thông tin đề thi',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Tải đáp án',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlack.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Test Info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.primaryYellow,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thời gian làm bài: 110 phút | 2 phần thi | 70 câu hỏi | 9 bình luận',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryBlack.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: AppColors.primaryYellow,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '2,847 người đã luyện tập đề thi này',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlack.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryYellow,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.primaryYellow,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Chú ý: để được quy đổi sang scaled score (ví dụ trên thang điểm 990 cho TOEIC hoặc 9.0 cho IELTS), vui lòng chọn chế độ làm FULL TEST.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBlack.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Practice Options Tabs
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.primaryBlack.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setState(() => _activePracticeTab = 'practice'),
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _activePracticeTab == 'practice'
                                        ? AppColors.primaryYellow
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Luyện tập',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _activePracticeTab == 'practice'
                                      ? AppColors.primaryBlack
                                      : AppColors.primaryBlack.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setState(() => _activePracticeTab = 'fullTest'),
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _activePracticeTab == 'fullTest'
                                        ? AppColors.primaryYellow
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Làm full test',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _activePracticeTab == 'fullTest'
                                      ? AppColors.primaryBlack
                                      : AppColors.primaryBlack.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Content based on active tab
                  if (_activePracticeTab == 'practice') ...[
                    // Pro Tips
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryYellow.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 20,
                            color: AppColors.primaryYellow,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pro tips: Hình thức luyện tập từng phần và chọn mức thời gian phù hợp sẽ giúp bạn tập trung vào giải đúng các câu hỏi thay vì phải chịu áp lực hoàn thành bài thi.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryBlack.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Section Selection
                    const Text(
                      'Chọn phần thi bạn muốn làm',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _selectedSections['listening'],
                      onChanged: (value) => _handleSectionChange('listening'),
                      title: const Text(
                        '듣기 - Listening (35 câu hỏi)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      activeColor: AppColors.primaryYellow,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      value: _selectedSections['reading'],
                      onChanged: (value) => _handleSectionChange('reading'),
                      title: const Text(
                        '읽기 - Reading (35 câu hỏi)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      activeColor: AppColors.primaryYellow,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 20),
                    // Time Limit
                    const Text(
                      'Giới hạn thời gian (Để trống để làm bài không giới hạn)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _timeLimit.isEmpty ? null : _timeLimit,
                      decoration: InputDecoration(
                        hintText: '-- Chọn thời gian --',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlack.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlack.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryYellow,
                            width: 2,
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: '30', child: Text('30 phút')),
                        DropdownMenuItem(value: '60', child: Text('60 phút')),
                        DropdownMenuItem(value: '90', child: Text('90 phút')),
                        DropdownMenuItem(
                            value: '110', child: Text('110 phút (Full test)')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _timeLimit = value ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Start Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleSubmit(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: AppColors.primaryBlack,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'LUYỆN TẬP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Full Test Content
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryYellow.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 20,
                            color: AppColors.primaryYellow,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pro tips: Chế độ Full Test sẽ mô phỏng bài thi thật với thời gian 110 phút và cả hai phần Listening & Reading. Hãy chuẩn bị kỹ trước khi bắt đầu!',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryBlack.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Chế độ Full Test sẽ bao gồm tất cả 70 câu hỏi (Listening: 35, Reading: 35) với thời gian cố định 110 phút.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryBlack.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleSubmit(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: AppColors.primaryBlack,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'BẮT ĐẦU FULL TEST',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Comments Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryBlack.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.comment_outlined,
                        color: AppColors.primaryBlack,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Bình luận',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Comment Input
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Chia sẻ cảm nghĩ của bạn ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryBlack.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryBlack.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryYellow,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.send, size: 16),
                        label: const Text(
                          'Gửi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          foregroundColor: AppColors.primaryBlack,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sample Comment
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlack.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'K',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'korean_learner_vn',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlack,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '• Thứ sáu 16, 2025',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          AppColors.primaryBlack.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Đề thi này khá khó, đặc biệt phần đọc hiểu. Có ai có transcript của phần nghe không ạ?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primaryBlack.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Trả lời',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryYellow,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Xem thêm 8 bình luận',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

