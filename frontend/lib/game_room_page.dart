import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_creation_page.dart';
import 'game_state.dart';
import 'scene_display_page.dart';
import 'base_container.dart';

class GameRoomPage extends StatelessWidget {
  const GameRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Set the background color here
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 100.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: gameState.players.length,
                      itemBuilder: (context, index) {
                        final player = gameState.players[index];
                        final isSelected = gameState.selectedPlayer == player;

                        return GestureDetector(
                          onTap: () {
                            gameState.selectPlayer(player);
                          },
                          child: Container(
                            width: 100,
                            margin: EdgeInsets.all(8.0),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Colors.blueAccent : Colors.white,
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  player.role,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  player.status,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline,
                      color: Colors.blue, size: 30.0),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CardCreationPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ListView(
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
                    SizedBox(
                        height:
                            60), // Spacer to ensure scrolling above the button
                  ],
                ),
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (gameState.isNarrator) {
                            gameState.startNewScene();
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SceneDisplayPage()),
                            );
                          }
                        },
                        child: Text(gameState.isNarrator
                            ? 'Start New Scene'
                            : 'Make a Move'),
                      ),
                    ),
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
