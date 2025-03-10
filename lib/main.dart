import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'widgets/card_widget.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => GameProvider()..initializeGame(),
    child: const CardMatchingGame(),
  ));
}

class CardMatchingGame extends StatelessWidget {
  const CardMatchingGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Card Matching Game")),
        body: Column(
          children: [
            ScoreBoard(),
            Expanded(child: GameGrid()),
          ],
        ),
      ),
    );
  }
}

class ScoreBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (game.isGameWon) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("You Win! 🎉"),
            content: Text("Final Score: ${game.score}\nTime Taken: ${game.timeElapsed}s"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  game.initializeGame();
                },
                child: Text("Restart"),
              ),
            ],
          ),
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text("Score: ${game.score}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("Time: ${game.timeElapsed}s", style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class GameGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: game.cards.length,
          itemBuilder: (context, index) {
            return CardWidget(card: game.cards[index]);
          },
        );
      },
    );
  }
}
