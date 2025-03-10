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
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue,
          image: card.isFaceUp
              ? DecorationImage(image: AssetImage(card.image), fit: BoxFit.cover)
              : DecorationImage(image: AssetImage('assets/card_back.png'), fit: BoxFit.cover),
        ),
      ),
    );
  }
}
