import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'widgets/card_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text("Card Matching Game")),
        body: Column(
          children: [
            const ScoreBoard(),
            const Expanded(child: GameGrid()),
            const GameControls(),
          ],
        ),
      ),
    );
  }
}

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text("Score: ${game.score}", 
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Time: ${game.timeElapsed}s", 
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text("Best Score: ${game.bestScore}", 
              style: const TextStyle(fontSize: 18, color: Colors.green)),
        ],
      ),
    );
  }
}

class GameGrid extends StatelessWidget {
  const GameGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

class GameControls extends StatelessWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: game.restartGame,
            child: const Text("Restart"),
          ),
          ElevatedButton(
            onPressed: game.pauseResumeGame,
            child: Text(game.isPaused ? "Resume" : "Pause"),
          ),
        ],
      ),
    );
  }
}