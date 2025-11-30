import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/features/vocabulary/data/services/vocabulary_api_service.dart';
import 'package:koreanhwa_flutter/core/utils/user_utils.dart';
import 'package:koreanhwa_flutter/shared/widgets/dictionary_lookup_dialog.dart';

/// Widget để hiển thị text tiếng Hàn với khả năng chọn từ và tra từ điển
class SelectableKoreanText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const SelectableKoreanText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<SelectableKoreanText> createState() => _SelectableKoreanTextState();
}

class _SelectableKoreanTextState extends State<SelectableKoreanText> {
  String? _selectedText;
  Timer? _selectionTimer;
  TextSelection? _currentSelection;

  @override
  void dispose() {
    _selectionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      _buildTextSpan(context),
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      onSelectionChanged: (selection, cause) {
        // Cancel previous timer
        _selectionTimer?.cancel();
        _currentSelection = selection;
        
        if (selection.isValid && !selection.isCollapsed) {
          // Extract selected text
          final selectedText = widget.text.substring(
            selection.start,
            selection.end,
          ).trim();
          
          if (selectedText.isNotEmpty && _isKoreanWord(selectedText)) {
            setState(() {
              _selectedText = selectedText;
            });
            
            // Auto show dialog after user finishes selecting (delay 800ms)
            // This gives user time to adjust selection
            _selectionTimer = Timer(const Duration(milliseconds: 800), () {
              if (mounted && 
                  _selectedText == selectedText && 
                  _currentSelection?.isValid == true &&
                  !_currentSelection!.isCollapsed) {
                _showDictionaryDialog(context, selectedText);
              }
            });
          } else {
            setState(() {
              _selectedText = null;
            });
          }
        } else {
          setState(() {
            _selectedText = null;
          });
        }
      },
    );
  }

  Future<void> _showDictionaryDialog(BuildContext context, String word) async {
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    // Clean the word (remove particles, etc.)
    final cleanWord = _cleanKoreanWord(word);
    
    if (cleanWord.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (context) => DictionaryLookupDialog(word: cleanWord),
      );
      
      // Clear selection after dialog closes
      if (mounted) {
        setState(() {
          _selectedText = null;
        });
      }
    }
  }

  /// Làm sạch từ tiếng Hàn - loại bỏ tiền tố/hậu tố phổ biến
  String _cleanKoreanWord(String word) {
    // Common Korean particles/suffixes to remove
    final particles = [
      '에', '에게', '한테', '께', '에서', '로', '으로', '와', '과', '와서', '고서',
      '은', '는', '이', '가', '을', '를', '의', '도', '만', '부터', '까지',
      '이다', '입니다', '이에요', '예요', '아요', '어요', '해요', '세요',
      '습니다', '습니다', '겠습니다', '겠어요',
    ];
    
    String cleaned = word.trim();
    
    // Try to find the root word by removing particles
    for (final particle in particles) {
      if (cleaned.endsWith(particle)) {
        cleaned = cleaned.substring(0, cleaned.length - particle.length).trim();
        break; // Remove only one particle at a time
      }
    }
    
    // If cleaned word is too short, use original
    if (cleaned.length < 1) {
      cleaned = word.trim();
    }
    
    return cleaned;
  }

  TextSpan _buildTextSpan(BuildContext context) {
    // Simple text span - selection will be handled by SelectableText
    return TextSpan(text: widget.text, style: widget.style);
  }

  /// Tách text thành các từ, giữ lại khoảng trắng và dấu câu
  List<String> _splitKoreanText(String text) {
    final words = <String>[];
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      
      if (_isKoreanChar(char) || _isHangul(char)) {
        buffer.write(char);
      } else {
        if (buffer.isNotEmpty) {
          words.add(buffer.toString());
          buffer.clear();
        }
        words.add(char);
      }
    }
    
    if (buffer.isNotEmpty) {
      words.add(buffer.toString());
    }
    
    return words;
  }

  /// Kiểm tra xem có phải ký tự tiếng Hàn không
  bool _isKoreanChar(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    // Hangul syllables: 0xAC00-0xD7A3
    // Hangul Jamo: 0x1100-0x11FF, 0x3130-0x318F
    return (code >= 0xAC00 && code <= 0xD7A3) ||
           (code >= 0x1100 && code <= 0x11FF) ||
           (code >= 0x3130 && code <= 0x318F);
  }

  /// Kiểm tra xem có phải Hangul không
  bool _isHangul(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return code >= 0xAC00 && code <= 0xD7A3;
  }

  /// Kiểm tra xem có phải từ tiếng Hàn không (có ít nhất 1 ký tự Hangul)
  bool _isKoreanWord(String word) {
    return word.split('').any((char) => _isKoreanChar(char));
  }
}


