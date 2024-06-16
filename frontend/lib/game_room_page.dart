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
import 'settings_dialog.dart';
import 'error_dialog.dart';

class GameRoomPage extends StatefulWidget {
  const GameRoomPage({super.key});

  @override
  _GameRoomPageState createState() => _GameRoomPageState();
}

class _GameRoomPageState extends State<GameRoomPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final gameState = Provider.of<GameState>(context, listen: false);

    // Add a listener to the isAutoRunning property
    gameState.addListener(_scrollToEndOnAutoRun);
  }

  @override
  void dispose() {
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.removeListener(_scrollToEndOnAutoRun);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEndOnAutoRun() {
    final gameState = Provider.of<GameState>(context, listen: false);
    if (gameState.isAutoRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final player = gameState.selectedPlayer;

    gameState.checkFinishedChallenges();

    void showErrorDialog(BuildContext context, String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(message: message);
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gameState.autoErrorMessage != null) {
        showErrorDialog(context, gameState.autoErrorMessage!);
        gameState.autoErrorMessage = null;
      }
    });

    void showSettings() {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 100),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return const SettingsDialog();
        },
      );
    }

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
          return CardDetailDialog(card: card, showEditDelete: false);
        },
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 180.0,
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

                        return PlayerCard(
                          player: player,
                          gameState: gameState,
                          isSelected: isSelected,
                          showCard: showCard,
                        );
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: !gameState.isAutoRunning
                      ? const Icon(Icons.play_arrow,
                          color: Colors.green, size: 45.0)
                      : const Icon(Icons.pause, color: Colors.red, size: 45.0),
                  onPressed: !gameState.isAutoRunning
                      ? () {
                          gameState.startAutoRun();
                        }
                      : () {
                          gameState.stopAutoRun();
                        },
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline,
                      color:
                          !gameState.isAutoRunning ? Colors.blue : Colors.grey,
                      size: 45.0),
                  onPressed: !gameState.isAutoRunning
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CardCreationPage()),
                          );
                        }
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.folder,
                      color: !gameState.isAutoRunning
                          ? const Color.fromARGB(255, 209, 209, 21)
                          : Colors.grey,
                      size: 45.0),
                  onPressed: !gameState.isAutoRunning
                      ? () async {
                          gameState.openGameState();
                        }
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.save,
                      color: !gameState.isAutoRunning
                          ? Colors.purple
                          : Colors.grey,
                      size: 45.0),
                  onPressed: !gameState.isAutoRunning
                      ? () async {
                          gameState.saveGameState();
                        }
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.settings,
                      color: !gameState.isAutoRunning
                          ? const Color.fromARGB(255, 43, 41, 41)
                          : Colors.grey,
                      size: 45.0),
                  onPressed: !gameState.isAutoRunning
                      ? () {
                          showSettings();
                        }
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.refresh,
                      color:
                          !gameState.isAutoRunning ? Colors.red : Colors.grey,
                      size: 45.0),
                  onPressed: !gameState.isAutoRunning
                      ? () async {
                          await resetGameState();
                          if (context.mounted) {
                            gameState.fetchGameState();
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ListView(
                  controller: _scrollController,
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
                        disableEdit: gameState.sceneAndMoves.indexOf(item) !=
                                    gameState.sceneAndMoves.length - 1 ||
                                gameState.isAutoRunning
                            ? true
                            : false,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            gameState.selectPlayer(gameState.players.firstWhere(
                                (player) => player.role == 'Narrator'));
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
                        title: 'Move by ${item.character}',
                        content: item.description,
                        selectedCards: item.selectedCardsIndices
                            .map((ind) => gameState.cards[ind])
                            .toList()
                            .cast<CardModel>(),
                        isMove: true,
                        disableEdit: gameState.sceneAndMoves.indexOf(item) !=
                                    gameState.sceneAndMoves.length - 1 ||
                                gameState.isAutoRunning
                            ? true
                            : false,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            gameState.selectPlayer(gameState.players.firstWhere(
                                (player) => player.name == item.character));

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
                      child: !gameState.isAutoRunning
                          ? ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        player?.role == 'Narrator'
                                            ? const SceneDisplayPage()
                                            : const MoveEditorPage(),
                                  ),
                                );
                              },
                              child: Text(player?.role == 'Narrator'
                                  ? 'Create Scene'
                                  : 'Make a Move'),
                            )
                          : null,
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

class PlayerCard extends StatefulWidget {
  final Player player;
  final GameState gameState;
  final bool isSelected;
  final Function(CardModel?) showCard;

  const PlayerCard({
    Key? key,
    required this.player,
    required this.gameState,
    required this.isSelected,
    required this.showCard,
  }) : super(key: key);

  @override
  _PlayerCardState createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  bool isHovered = false;
  Timer? timer;

  void onHoverEnter(card) {
    if (card == null) {
      return;
    }
    setState(() {
      isHovered = true;
    });
    timer = Timer(const Duration(milliseconds: 900), () {
      if (isHovered) {
        widget.showCard(card);
      }
    });
  }

  void onHoverExit() {
    setState(() {
      isHovered = false;
    });
    timer?.cancel();
  }

  void onClick() {
    setState(() {
      isHovered = false;
    });
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final gameState = widget.gameState;
    final isSelected = widget.isSelected;

    return GestureDetector(
      onTap: () {
        gameState.selectPlayer(player);
        onClick();
      },
      child: MouseRegion(
        onEnter: (_) => onHoverEnter(player.cardIndex != null
            ? gameState.cards[player.cardIndex!]
            : null),
        onExit: (_) => onHoverExit(),
        child: Container(
          width: 120,
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
                color: isHovered ? Colors.blue : Colors.transparent,
                width: 2.0),
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
                  gameState.cards[player.cardIndex!].imageBytes != null) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  height: 80,
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.memory(
                      gameState.cards[player.cardIndex!].imageBytes!,
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
  }
}
