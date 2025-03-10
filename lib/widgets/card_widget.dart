import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../providers/game_provider.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;

  const CardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Provider.of<GameProvider>(context, listen: false).flipCard(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(
              card.isFaceUp ? card.image : 'assets/card_back.png'
            ), 
            fit: BoxFit.cover
          ),
        ),
        child: card.isMatched ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green, width: 3),
          ),
        ) : null,
      ),
    );
  }
}