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
  bool _isProcessing = false; 

  List<CardModel> get cards => _cards;
  int get score => _score;
  int get timeElapsed => _timeElapsed;
  int get bestScore => _bestScore;
  bool get isPaused => _isPaused;

  GameProvider() {
    _loadBestScore();
  }

  void initializeGame() {
    final List<CardModel> cardPairs = [];
    for (int i = 1; i <= 8; i++) {
      cardPairs.add(CardModel(id: '${i}a', image: 'assets/card$i.png'));
      cardPairs.add(CardModel(id: '${i}b', image: 'assets/card$i.png'));
    }
    
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
    if (card.isMatched || _isPaused || _isProcessing) {
      return;
    }

    if (card.isFaceUp) {
      return;
    }

    final int cardIndex = _cards.indexWhere((c) => c.id == card.id);
    if (cardIndex == -1) return;

    final List<CardModel> updatedCards = List.from(_cards);
    updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(isFaceUp: true);
    _cards = updatedCards;

    if (_selectedCard == null) {
      _selectedCard = _cards[cardIndex];
      notifyListeners();
    } else {
      _isProcessing = true;
      
      if (_selectedCard!.image == card.image && _selectedCard!.id != card.id) {
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
        
        if (_checkWinCondition()) {
          _timer?.cancel();
          _updateBestScore();
          Future.delayed(Duration(milliseconds: 500), () {
            _showWinDialog();
          });
        }
      } else {
        notifyListeners();
        
        Future.delayed(Duration(milliseconds: 1000), () {
          final int selectedIndex = _cards.indexWhere((c) => c.id == _selectedCard!.id);
          if (selectedIndex != -1) {
            final List<CardModel> updatedCards = List.from(_cards);
            updatedCards[selectedIndex] = updatedCards[selectedIndex].copyWith(isFaceUp: false);
            updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(isFaceUp: false);
            _cards = updatedCards;
          }
          _score = (_score - 5 >= 0) ? _score - 5 : 0;
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}