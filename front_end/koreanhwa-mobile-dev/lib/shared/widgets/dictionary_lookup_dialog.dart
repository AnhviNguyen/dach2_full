import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/vocabulary/data/services/vocabulary_api_service.dart';
import 'package:koreanhwa_flutter/core/utils/user_utils.dart';

/// Dialog để tra từ điển và thêm vào My vocabulary
class DictionaryLookupDialog extends ConsumerStatefulWidget {
  final String word;

  const DictionaryLookupDialog({
    super.key,
    required this.word,
  });

  @override
  ConsumerState<DictionaryLookupDialog> createState() => _DictionaryLookupDialogState();
}

class _DictionaryLookupDialogState extends ConsumerState<DictionaryLookupDialog> {
  final VocabularyApiService _vocabService = VocabularyApiService();
  bool _isLoading = true;
  bool _isAdding = false;
  Map<String, dynamic>? _lookupResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _lookupWord();
  }

  Future<void> _lookupWord() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _vocabService.lookupWord(widget.word);
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _lookupResult = result['data'] as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Không tìm thấy từ này trong từ điển';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tra từ: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _addToMyVocabulary() async {
    if (_lookupResult == null) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final userId = await UserUtils.getUserId();
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đăng nhập để thêm từ vựng')),
          );
        }
        setState(() {
          _isAdding = false;
        });
        return;
      }

      final word = _lookupResult!['word'] as String? ?? widget.word;
      final vietnamese = _lookupResult!['vietnamese'] as String? ?? '';
      final viWord = _lookupResult!['vi_word'] as String? ?? '';
      final viDef = _lookupResult!['vi_def'] as String? ?? '';
      
      // Lấy pronunciation từ lookup result nếu có
      String? pronunciation;
      if (_lookupResult!.containsKey('pronunciation')) {
        pronunciation = _lookupResult!['pronunciation'] as String?;
      }

      await _vocabService.addWordToDailyFolder(
        userId: userId,
        word: word,
        vietnamese: vietnamese,
        pronunciation: pronunciation,
        example: viDef.isNotEmpty ? viDef : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm vào My vocabulary'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tra từ điển',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.primaryBlack),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Word
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryYellow,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.translate, color: AppColors.primaryBlack, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.word,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.primaryBlack,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _lookupWord,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryYellow,
                                  foregroundColor: AppColors.primaryBlack,
                                ),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : _lookupResult != null
                          ? SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Vietnamese meaning
                                  if (_lookupResult!['vietnamese'] != null)
                                    _buildInfoRow(
                                      'Nghĩa tiếng Việt',
                                      _lookupResult!['vietnamese'] as String,
                                      Icons.translate,
                                    ),
                                  
                                  // Vietnamese word
                                  if (_lookupResult!['vi_word'] != null &&
                                      (_lookupResult!['vi_word'] as String).isNotEmpty)
                                    _buildInfoRow(
                                      'Từ tiếng Việt',
                                      _lookupResult!['vi_word'] as String,
                                      Icons.text_fields,
                                    ),
                                  
                                  // Definition
                                  if (_lookupResult!['vi_def'] != null &&
                                      (_lookupResult!['vi_def'] as String).isNotEmpty)
                                    _buildInfoRow(
                                      'Định nghĩa',
                                      _lookupResult!['vi_def'] as String,
                                      Icons.info_outline,
                                    ),
                                  
                                  // Pronunciation
                                  if (_lookupResult!['pronunciation'] != null &&
                                      (_lookupResult!['pronunciation'] as String).isNotEmpty)
                                    _buildInfoRow(
                                      'Phát âm',
                                      _lookupResult!['pronunciation'] as String,
                                      Icons.volume_up,
                                    ),
                                  
                                  // Source
                                  if (_lookupResult!['source'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Nguồn: ${_lookupResult!['source']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.grayLight,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // Add to My Vocabulary button
            if (_lookupResult != null && !_isLoading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAdding ? null : _addToMyVocabulary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.primaryBlack,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: AppColors.primaryBlack,
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: _isAdding
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlack),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Thêm vào My vocabulary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryBlack.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlack.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

