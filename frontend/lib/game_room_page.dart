import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_creation_page.dart';
import 'game_state.dart';
import 'scene_display_page.dart';
import 'move_editor_page.dart';
import 'base_container.dart';
import 'card_state.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'card_detail_dialog.dart';

class GameRoomPage extends StatelessWidget {
  const GameRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final player = gameState.selectedPlayer;
    bool isHovered = false;
    Timer? timer;

    void showCard(card) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 100),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return CardDetailDialog(
              card: card, showEditDelete: false); // Add showEditDelete: false
        },
      );
    }

    void onHoverEnter(card) {
      if (card == null) {
        return;
      }
      isHovered = true;
      timer = Timer(const Duration(milliseconds: 900), () {
        if (isHovered) {
          showCard(card);
        }
      });
    }

    void onHoverExit() {
      isHovered = false;
      timer?.cancel();
    }

    void onClick() {
      isHovered = false;
      timer?.cancel();
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
                            onClick();
                          },
                          child: MouseRegion(
                            onEnter: (_) => onHoverEnter(
                                player.cardIndex != null
                                    ? gameState.cards[player.cardIndex!]
                                    : null),
                            onExit: (_) => onHoverExit(),
                            child: Container(
                              width: 120,
                              margin: const EdgeInsets.all(8.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.white,
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
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (player.cardIndex != null &&
                                      gameState.cards[player.cardIndex!]
                                              .imageBytes !=
                                          null) ...[
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      height: 80,
                                      width: double.infinity,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Image.memory(
                                          gameState.cards[player.cardIndex!]
                                              .imageBytes!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                  ],
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CardCreationPage()),
                    );
                  },
                ),
                IconButton(
                  icon:
                      const Icon(Icons.refresh, color: Colors.red, size: 45.0),
                  onPressed: () async {
                    await resetGameState();
                    gameState.fetchGameState();
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
                  children: gameState.sceneAndMoves.map<Widget>((item) {
                    if (item is SceneComponent) {
                      return BaseContainer(
                        title: item.title,
                        content: item.description,
                        placeCard: item.placeCardIndex != null
                            ? gameState.cards[item.placeCardIndex!]
                            : null,
                        selectedCards: item.selectedCardsIndices
                            .map((ind) => gameState.cards[ind])
                            .toList(),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SceneDisplayPage(sceneComponent: item),
                              ),
                            );
                          },
                        ),
                        onDelete: () {
                          gameState.deleteItem(item);
                        },
                      );
                    } else {
                      return BaseContainer(
                        title: 'Move',
                        content: item.description,
                        selectedCards: item.selectedCardsIndices
                            .map((ind) => gameState.cards[ind])
                            .toList()
                            .cast<CardModel>(),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MoveEditorPage(move: item),
                              ),
                            );
                          },
                        ),
                        onDelete: () {
                          gameState.deleteItem(item);
                        },
                      );
                    }
                  }).toList(),
                ),
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => player?.role == 'Narrator'
                                  ? const SceneDisplayPage()
                                  : const MoveEditorPage(),
                            ),
                          );
                        },
                        child: Text(player?.role == 'Narrator'
                            ? 'Create Scene'
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

  Future<void> resetGameState() async {
    const url = 'http://127.0.0.1:5000/gamestate/reset';
    final response = await http.post(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to reset game state');
    }
  }
}
