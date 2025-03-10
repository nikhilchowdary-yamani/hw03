import 'dart:async';
import 'package:flutter/material.dart';
import '../models/card_model.dart';

class GameProvider with ChangeNotifier {
  List<CardModel> _cards = [];
  CardModel? _selectedCard;
  int _score = 0;
  int _timeElapsed = 0;
  Timer? _timer;
  bool _isGameWon = false;

  List<CardModel> get cards => _cards;
  int get score => _score;
  int get timeElapsed => _timeElapsed;
  bool get isGameWon => _isGameWon;

  void initializeGame() {
    _cards = [
      CardModel(id: '1', image: 'assets/card1.png'),
      CardModel(id: '2', image: 'assets/card2.png'),
      // Add more pairs
    ]..shuffle();

    _score = 0;
    _timeElapsed = 0;
    _isGameWon = false;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timeElapsed++;
      notifyListeners();
    });
  }

  void flipCard(CardModel card) {
    if (!card.isMatched && !_isGameWon) {
      card.isFaceUp = !card.isFaceUp;

      if (_selectedCard == null) {
        _selectedCard = card;
      } else {
        if (_selectedCard!.image == card.image) {
          _selectedCard!.isMatched = true;
          card.isMatched = true;
          _score += 10;
        } else {
          Future.delayed(Duration(seconds: 1), () {
            _selectedCard!.isFaceUp = false;
            card.isFaceUp = false;
            notifyListeners();
          });
          _score -= 5;
        }
        _selectedCard = null;
      }
      notifyListeners();
    }

    _checkWinCondition();
  }

  void _checkWinCondition() {
    if (_cards.every((card) => card.isMatched)) {
      _isGameWon = true;
      _timer?.cancel();
      notifyListeners();
    }
  }
}
