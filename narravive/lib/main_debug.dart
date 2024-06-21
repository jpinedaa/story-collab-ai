// ignore_for_file: use_key_in_widget_constructors, sized_box_for_whitespace, avoid_print

import 'package:flutter/material.dart';
import 'dart:typed_data';

void main() {
  runApp(MaterialApp(home: Scaffold(body: Center(child: HoverWidget()))));
}

class HoverWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dummy game state for demonstration
    final gameState = GameState();

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 180.0, // Ensure the height is explicitly defined
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: gameState.players
                  .where((player) => player.status != 'NPC')
                  .length,
              itemBuilder: (context, index) {
                final player = gameState.players
                    .where((player) => player.status != 'NPC')
                    .toList()[index];
                final isSelected = gameState.selectedPlayer == player;

                return GestureDetector(
                  onTap: () {
                    gameState.selectPlayer(player);
                    print("Player selected: ${player.name}");
                  },
                  child: MouseRegion(
                    onEnter: (_) {
                      if (player.cardIndex != null) {
                        print(
                            "Hovered over: ${gameState.cards[player.cardIndex!].name}");
                      }
                    },
                    onExit: (_) => print("Hover exit"),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blueAccent : Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
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
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (player.cardIndex != null &&
                              gameState.cards[player.cardIndex!].imageBytes !=
                                  null) ...[
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              height: 80,
                              width: double.infinity,
                              child: Align(
                                alignment: Alignment.center,
                                child: Image.memory(
                                  gameState
                                      .cards[player.cardIndex!].imageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                          ],
                          Text(
                            player.role,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            player.status,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline,
              color: Colors.blue, size: 45.0),
          onPressed: () {
            print("Add button pressed");
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.red, size: 45.0),
          onPressed: () {
            print("Refresh button pressed");
          },
        ),
      ],
    );
  }
}

// Dummy classes for demonstration
class GameState {
  List<Player> players = [
    Player(name: "Player 1", status: "Active", role: "Role 1", cardIndex: 0),
    Player(name: "Player 2", status: "Active", role: "Role 2", cardIndex: 1),
    Player(name: "Player 3", status: "Inactive", role: "Role 3"),
    Player(name: "Player 3", status: "Inactive", role: "Role 3"),
    Player(name: "Player 3", status: "Inactive", role: "Role 3"),
    Player(name: "Player 3", status: "Inactive", role: "Role 3"),
    Player(name: "Player 3", status: "Inactive", role: "Role 3"),
    Player(name: "Player 3", status: "Inactive", role: "Role 3"),
    Player(name: "Player 3", status: "Inactive", role: "Role 3"),
  ];
  List<CardModel> cards = [
    CardModel(name: "Card 1", imageBytes: null),
    CardModel(name: "Card 2", imageBytes: null),
  ];
  Player? selectedPlayer;

  void selectPlayer(Player player) {
    selectedPlayer = player;
  }
}

class Player {
  final String name;
  final String status;
  final String role;
  final int? cardIndex;

  Player(
      {required this.name,
      required this.status,
      required this.role,
      this.cardIndex});
}

class CardModel {
  final String name;
  final Uint8List? imageBytes;

  CardModel({required this.name, this.imageBytes});
}
