import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';

class GameProvider with ChangeNotifier {
  List<CardModel> _cards = [];
  CardModel? _selectedCard;
  int _score = 0;
  int _timeElapsed = 0;
  Timer? _timer;
  bool _isPaused = false;
  int _bestScore = 0;
  bool _isProcessing = false; // Add flag to prevent multiple card flips during animation

  List<CardModel> get cards => _cards;
  int get score => _score;
  int get timeElapsed => _timeElapsed;
  int get bestScore => _bestScore;
  bool get isPaused => _isPaused;

  GameProvider() {
    _loadBestScore();
  }

  void initializeGame() {
    // Create pairs of cards
    final List<CardModel> cardPairs = [];
    for (int i = 1; i <= 8; i++) { // Assuming 8 pairs for a 4x4 grid
      cardPairs.add(CardModel(id: '${i}a', image: 'assets/card$i.png'));
      cardPairs.add(CardModel(id: '${i}b', image: 'assets/card$i.png'));
    }
    
    // Shuffle the cards
    cardPairs.shuffle();
    _cards = cardPairs;
    
    _selectedCard = null;
    _score = 0;
    _timeElapsed = 0;
    _isPaused = false;
    _isProcessing = false;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _timeElapsed++;
        notifyListeners();
      }
    });
  }

  void pauseResumeGame() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void restartGame() {
    _timer?.cancel();
    initializeGame();
  }

  void flipCard(CardModel card) {
    // Don't allow flipping if game is paused, card is matched, or we're processing a match
    if (card.isMatched || _isPaused || _isProcessing) {
      return;
    }

    // Don't allow flipping a card that's already face up
    if (card.isFaceUp) {
      return;
    }

    // Create a new list to maintain immutability
    final int cardIndex = _cards.indexWhere((c) => c.id == card.id);
    if (cardIndex == -1) return;

    // Create a new list with the updated card
    final List<CardModel> updatedCards = List.from(_cards);
    updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(isFaceUp: true);
    _cards = updatedCards;

    if (_selectedCard == null) {
      // First card flipped
      _selectedCard = _cards[cardIndex];
      notifyListeners();
    } else {
      // Second card flipped
      _isProcessing = true; // Prevent further card flips during animation
      
      if (_selectedCard!.image == card.image && _selectedCard!.id != card.id) {
        // Found a match
        // Mark both cards as matched
        final int selectedIndex = _cards.indexWhere((c) => c.id == _selectedCard!.id);
        if (selectedIndex != -1) {
          final List<CardModel> updatedCards = List.from(_cards);
          updatedCards[selectedIndex] = updatedCards[selectedIndex].copyWith(isMatched: true);
          updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(isMatched: true);
          _cards = updatedCards;
          _score += 10;
        }
        _selectedCard = null;
        _isProcessing = false;
        notifyListeners();
        
        // Check for win after a match
        if (_checkWinCondition()) {
          _timer?.cancel();
          _updateBestScore();
          // Use a shorter delay for the win dialog
          Future.delayed(Duration(milliseconds: 500), () {
            _showWinDialog();
          });
        }
      } else {
        // No match
        notifyListeners(); // Update UI to show the second card
        
        // Wait and then flip both cards back
        Future.delayed(Duration(milliseconds: 1000), () {
          final int selectedIndex = _cards.indexWhere((c) => c.id == _selectedCard!.id);
          if (selectedIndex != -1) {
            final List<CardModel> updatedCards = List.from(_cards);
            updatedCards[selectedIndex] = updatedCards[selectedIndex].copyWith(isFaceUp: false);
            updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(isFaceUp: false);
            _cards = updatedCards;
          }
          _score = (_score - 5 >= 0) ? _score - 5 : 0; // Prevent negative score
          _selectedCard = null;
          _isProcessing = false;
          notifyListeners();
        });
      }
    }
  }

  bool _checkWinCondition() {
    return _cards.every((card) => card.isMatched);
  }

  Future<void> _updateBestScore() async {
    if (_bestScore == 0 || _score > _bestScore) {
      _bestScore = _score;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('best_score', _bestScore);
    }
  }

  Future<void> _loadBestScore() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _bestScore = prefs.getInt('best_score') ?? 0;
      notifyListeners();
    } catch (e) {
      print('Error loading best score: $e');
    }
  }

  void _showWinDialog() {
    print("You win! Final Score: $_score");
    // This would be replaced with an actual dialog in the UI
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}