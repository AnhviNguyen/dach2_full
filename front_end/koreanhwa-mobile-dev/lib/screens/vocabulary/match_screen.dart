import 'dart:math';
import 'package:flutter/material.dart';
import 'package:koreanhwa_flutter/shared/theme/app_colors.dart';
import 'package:koreanhwa_flutter/models/vocabulary_model.dart';

class MatchScreen extends StatefulWidget {
  final int bookId;
  final int lessonId;
  final List<Map<String, String>> vocabList;

  const MatchScreen({
    super.key,
    required this.bookId,
    required this.lessonId,
    required this.vocabList,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  List<MatchCard> _cards = [];
  List<MatchCard> _selectedCards = [];
  List<String> _matchedPairs = [];

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _selectedCards.clear();
      _matchedPairs.clear();
      
      final vocabToUse = widget.vocabList.take(6).toList();
      final koreanCards = vocabToUse.asMap().entries.map((entry) {
        final i = entry.key;
        final v = entry.value;
        return MatchCard(
          id: 'k-$i',
          text: v['korean']!,
          type: 'korean',
          matchId: i,
        );
      }).toList();

      final vietnameseCards = vocabToUse.asMap().entries.map((entry) {
        final i = entry.key;
        final v = entry.value;
        return MatchCard(
          id: 'v-$i',
          text: v['vietnamese']!,
          type: 'vietnamese',
          matchId: i,
        );
      }).toList();

      _cards = [...koreanCards, ...vietnameseCards]..shuffle(Random());
    });
  }

  void _handleCardClick(MatchCard card) {
    if (_selectedCards.length == 2 ||
        _matchedPairs.contains(card.id) ||
        _selectedCards.any((c) => c.id == card.id)) return;

    setState(() {
      _selectedCards.add(card);
    });

    if (_selectedCards.length == 2) {
      if (_selectedCards[0].matchId == _selectedCards[1].matchId) {
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _matchedPairs.addAll([
              _selectedCards[0].id,
              _selectedCards[1].id,
            ]);
            _selectedCards.clear();
          });
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            _selectedCards.clear();
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryWhite),
        ),
        title: const Text(
          'Match Game',
          style: TextStyle(
            color: AppColors.primaryWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh, color: AppColors.primaryWhite),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF9C27B0),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  'Ghép đôi: ${_matchedPairs.length ~/ 2} / 6',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  final isSelected =
                      _selectedCards.any((c) => c.id == card.id);
                  final isMatched = _matchedPairs.contains(card.id);

                  return InkWell(
                    onTap: isMatched ? null : () => _handleCardClick(card),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isMatched
                            ? AppColors.success
                            : isSelected
                                ? AppColors.primaryYellow
                                : card.type == 'korean'
                                    ? AppColors.primaryWhite
                                    : const Color(0xFFE1BEE7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isMatched
                              ? AppColors.success
                              : isSelected
                                  ? AppColors.primaryBlack
                                  : card.type == 'korean'
                                      ? const Color(0xFF9C27B0).withOpacity(0.3)
                                      : const Color(0xFF9C27B0),
                          width: isSelected || isMatched ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryYellow.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          card.text,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isMatched
                                ? AppColors.primaryWhite
                                : AppColors.primaryBlack,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

