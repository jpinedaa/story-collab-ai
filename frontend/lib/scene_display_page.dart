import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';

class SceneDisplayPage extends StatelessWidget {
  const SceneDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scene Display'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Scene: ${gameState.currentSceneDescription}',
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: gameState.challenges.length,
              itemBuilder: (context, index) {
                final challenge = gameState.challenges[index];
                return ListTile(
                  title: Text(challenge.description),
                  subtitle: Text('Points needed: ${challenge.points}'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (gameState.canMakeMove()) {
                gameState.makeMove('A new move');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid move!')),
                );
              }
            },
            child: const Text('Play Card'),
          ),
        ],
      ),
    );
  }
}
