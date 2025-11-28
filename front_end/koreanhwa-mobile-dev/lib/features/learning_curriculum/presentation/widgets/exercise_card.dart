import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/learning_curriculum/data/models/exercise_item.dart';

class ExerciseCard extends StatefulWidget {
  final ExerciseItem exercise;
  final int index;
  final Function(int, dynamic)? onAnswerChanged;
  final bool isSubmitted;
  final bool showResult;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.index,
    this.onAnswerChanged,
    this.isSubmitted = false,
    this.showResult = false,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  String? _selectedAnswer;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _isCorrect {
    if (widget.exercise.type == 'multiple_choice') {
      if (widget.exercise.correct != null && widget.exercise.options != null) {
        final correctAnswer = widget.exercise.options![widget.exercise.correct!];
        return _selectedAnswer == correctAnswer;
      }
    } else if (widget.exercise.type == 'fill_blank') {
      final userAnswer = _textController.text.trim().toLowerCase();
      final correctAnswer = (widget.exercise.answer ?? '').trim().toLowerCase();
      return userAnswer == correctAnswer;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.showResult ? _isCorrect : null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.showResult
            ? (isCorrect == true
                ? AppColors.success.withOpacity(0.1)
                : isCorrect == false
                    ? const Color(0xFFF44336).withOpacity(0.1)
                    : AppColors.primaryWhite)
            : AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.showResult
              ? (isCorrect == true
                  ? AppColors.success
                  : isCorrect == false
                      ? const Color(0xFFF44336)
                      : AppColors.primaryBlack)
              : AppColors.primaryBlack,
          width: widget.showResult ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Câu ${widget.index + 1}: ${widget.exercise.question}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ),
              ),
              if (widget.showResult)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCorrect == true
                        ? AppColors.success
                        : isCorrect == false
                            ? const Color(0xFFF44336)
                            : AppColors.primaryBlack.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCorrect == true
                        ? Icons.check
                        : isCorrect == false
                            ? Icons.close
                            : Icons.help_outline,
                    color: AppColors.primaryWhite,
                    size: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.exercise.type == 'multiple_choice' && widget.exercise.options != null) ...[
            ...widget.exercise.options!.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              final isSelected = _selectedAnswer == option;
              final isCorrectOption = widget.exercise.correct == optionIndex;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: widget.isSubmitted ? null : () {
                    setState(() {
                      _selectedAnswer = option;
                    });
                    widget.onAnswerChanged?.call(widget.exercise.id, option);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.showResult
                          ? (isCorrectOption
                              ? AppColors.success.withOpacity(0.1)
                              : isSelected && !isCorrectOption
                                  ? const Color(0xFFF44336).withOpacity(0.1)
                                  : Colors.transparent)
                          : (isSelected
                              ? AppColors.primaryYellow.withOpacity(0.2)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.showResult
                            ? (isCorrectOption
                                ? AppColors.success
                                : isSelected && !isCorrectOption
                                    ? const Color(0xFFF44336)
                                    : AppColors.primaryBlack.withOpacity(0.2))
                            : (isSelected
                                ? AppColors.primaryYellow
                                : AppColors.primaryBlack.withOpacity(0.2)),
                        width: widget.showResult && (isCorrectOption || (isSelected && !isCorrectOption)) ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: option,
                          groupValue: _selectedAnswer,
                          onChanged: widget.isSubmitted ? null : (val) {
                            setState(() {
                              _selectedAnswer = val;
                            });
                            widget.onAnswerChanged?.call(widget.exercise.id, val);
                          },
                          activeColor: AppColors.primaryYellow,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primaryBlack,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              if (widget.showResult && isCorrectOption)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    '✓ Đáp án đúng',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
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
            }).toList(),
          ] else if (widget.exercise.type == 'fill_blank') ...[
            TextField(
              controller: _textController,
              enabled: !widget.isSubmitted,
              decoration: InputDecoration(
                hintText: 'Nhập đáp án...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlack,
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
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.showResult
                        ? (isCorrect == true
                            ? AppColors.success
                            : isCorrect == false
                                ? const Color(0xFFF44336)
                                : AppColors.primaryBlack)
                        : AppColors.primaryBlack,
                    width: widget.showResult ? 2 : 1,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: widget.showResult
                        ? (isCorrect == true
                            ? AppColors.success
                            : isCorrect == false
                                ? const Color(0xFFF44336)
                                : AppColors.primaryBlack)
                        : AppColors.primaryBlack,
                    width: widget.showResult ? 2 : 1,
                  ),
                ),
              ),
              onChanged: widget.isSubmitted ? null : (value) {
                widget.onAnswerChanged?.call(widget.exercise.id, value);
              },
            ),
            if (widget.showResult) ...[
              const SizedBox(height: 8),
              if (isCorrect == true)
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      'Đáp án đúng!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else if (isCorrect == false)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cancel, color: Color(0xFFF44336), size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'Đáp án sai',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFF44336),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (widget.exercise.answer != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Đáp án đúng: ${widget.exercise.answer}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ],
        ],
      ),
    );
  }
}

