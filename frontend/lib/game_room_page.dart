import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';
import 'scene_display_page.dart';
import 'base_container.dart';

class GameRoomPage extends StatelessWidget {
  const GameRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      body: Column(
        children: [
          // Horizontal list of players
          SizedBox(
            height: 100.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: gameState.players.length,
              itemBuilder: (context, index) {
                final player = gameState.players[index];
                return Container(
                  width: 100,
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        player.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(player.role),
                      Text(player.status),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                // BaseContainer for scene description
                BaseContainer(
                  title: 'Scene Description',
                  content: gameState.currentSceneDescription,
                ),
                // BaseContainers for each move
                ...gameState.currentMoves.map((move) => BaseContainer(
                      title: 'Move',
                      content: move,
                    )),
                if (gameState.isNarrator)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        gameState.startNewScene();
                      },
                      child: const Text('Start New Scene'),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SceneDisplayPage()),
                      ),
                      child: const Text('Make a Move'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
