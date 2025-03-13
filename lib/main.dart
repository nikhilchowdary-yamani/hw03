import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'widgets/card_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (_) => GameProvider(),
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
      home: Consumer<GameProvider>(
        builder: (context, game, _) {
          return Scaffold(
            appBar: AppBar(title: const Text("Card Matching Game")),
            body: game.isGameStarted
                ? Column(
                    children: [
                      const ScoreBoard(),
                      const Expanded(child: GameGrid()),
                      const GameControls(),
                    ],
                  )
                : const StartScreen(),
          );
        },
      ),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Memory Card Game",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Match all the cards to win!",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 15,
              ),
            ),
            onPressed: () {
              Provider.of<GameProvider>(context, listen: false).startGame();
            },
            child: const Text(
              "Start Game",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
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
        return Stack(
          children: [
            GridView.builder(
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
            ),
            if (game.isGameWon)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Victory!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Final Score: ${game.score}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Time: ${game.timeElapsed} seconds",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: game.restartGame,
                          child: const Text("Play Again"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
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