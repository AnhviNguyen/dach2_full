import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/shared/widgets/dictionary_lookup_dialog.dart';

/// Dialog để nhập từ tiếng Hàn và tra từ điển
class DictionaryInputDialog extends StatefulWidget {
  const DictionaryInputDialog({super.key});

  @override
  State<DictionaryInputDialog> createState() => _DictionaryInputDialogState();
}

class _DictionaryInputDialogState extends State<DictionaryInputDialog> {
  final TextEditingController _wordController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _wordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Auto focus after dialog is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _handleLookup() {
    final word = _wordController.text.trim();
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập từ tiếng Hàn'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Close input dialog
    Navigator.of(context).pop();
    
    // Show dictionary lookup dialog
    showDialog(
      context: context,
      builder: (context) => DictionaryLookupDialog(word: word),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.translate,
                      color: Theme.of(context).iconTheme.color ?? AppColors.primaryBlack,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tra từ điển',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.primaryBlack,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color ?? AppColors.primaryBlack),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Input field
            TextField(
              controller: _wordController,
              focusNode: _focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nhập từ tiếng Hàn...',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color ?? AppColors.primaryBlack),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
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
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.primaryBlack,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _handleLookup(),
            ),
            const SizedBox(height: 20),
            
            // Lookup button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleLookup,
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tra từ',
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
}

