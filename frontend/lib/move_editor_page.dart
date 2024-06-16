import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_state.dart';
import 'game_state.dart';

class MoveEditorPage extends StatefulWidget {
  final Move? move;

  const MoveEditorPage({super.key, this.move});

  @override
  MoveEditorPageState createState() => MoveEditorPageState();
}

class MoveEditorPageState extends State<MoveEditorPage> {
  final _formKey = GlobalKey<FormState>();
  Move? _move;
  List<int> _selectedCardsIndices = [];
  String _description = '';
  bool _isChallengeSelected = false;

  @override
  void initState() {
    super.initState();
    if (widget.move != null) {
      _move = widget.move!;
      _selectedCardsIndices = _move!.selectedCardsIndices;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final player = gameState.selectedPlayer;

    bool isChallengeFinishing = false;
    for (int cardInt in _selectedCardsIndices) {
      if (gameState.challengeProgress.keys.contains(cardInt) &&
          gameState.challengeProgress[cardInt]! >= 2) {
        isChallengeFinishing = true;
        break;
      }
    }

    List<int> usedCards = gameState.sceneAndMoves
        .whereType<Move>()
        .where((move) => move.character == gameState.selectedPlayer!.name)
        .map((move) => move.selectedCardsIndices)
        .expand((element) => element)
        .toList();
    usedCards.removeWhere((element) => _selectedCardsIndices.contains(element));

    List<int> usedSceneCards = gameState.sceneAndMoves
        .whereType<Move>()
        .map((move) => move.selectedCardsIndices)
        .expand((element) => element)
        .toList();
    usedSceneCards
        .removeWhere((element) => _selectedCardsIndices.contains(element));

    if (player == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Move Editor'),
        ),
        body: const Center(
          child: Text('No player selected'),
        ),
      );
    }

    final allCards = player.cardsIndices
        .map((ind) => gameState.cards[ind])
        .toList()
        .map((playCard) {
      String label = playCard.type.name;
      return SelectableCard(playCard, label);
    });
    final bool hasCards = allCards.isNotEmpty;
    final sceneCards = gameState.sceneAndMoves
        .whereType<SceneComponent>()
        .map((sceneComponent) => sceneComponent.selectedCardsIndices
            .map((ind) => gameState.cards[ind]))
        .expand((element) => element)
        .toList()
        .map((sceneCard) {
      String label = (sceneCard.type == CardType.Obstacle ||
              sceneCard.type == CardType.Character)
          ? 'Challenge'
          : 'Pickup';
      return SelectableCard(sceneCard, label);
    }).toList();
    final bool hasSceneCards = sceneCards.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.move == null ? 'Move Editor' : 'Edit Move'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              const Text(
                'Select Scene Cards',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (!hasSceneCards)
                const Text(
                  'No scene cards available.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxHeight: 200), // Set a maximum height
                  child: ListView(
                    shrinkWrap: true,
                    children: sceneCards.map((sceneCard) {
                      return Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  sceneCard.card.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    sceneCard.card.description,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          sceneCard.label == 'Pickup'
                              ? !usedSceneCards.contains(
                                      gameState.cards.indexOf(sceneCard.card))
                                  ? Text(sceneCard.label)
                                  : const Text('Pickup - Used')
                              : !gameState.finishedChallenges.contains(
                                      gameState.cards.indexOf(sceneCard.card))
                                  ? Text(sceneCard.label)
                                  : const Text('Challenge - Completed'),
                          Checkbox(
                            value: _selectedCardsIndices
                                .map((ind) => gameState.cards[ind])
                                .where((card) =>
                                    card.type == CardType.Obstacle ||
                                    card.playerStatus == PlayerStatus.NPC ||
                                    card.type == CardType.Goal ||
                                    card.type == CardType.Asset)
                                .contains(sceneCard.card),
                            onChanged: (bool? value) {
                              setState(() {
                                if ((!gameState.finishedChallenges.contains(
                                        gameState.cards
                                            .indexOf(sceneCard.card))) &&
                                    (!usedSceneCards.contains(gameState.cards
                                            .indexOf(sceneCard.card)) ||
                                        sceneCard.label == 'Challenge')) {
                                  if (value == true) {
                                    _selectedCardsIndices.add(gameState.cards
                                        .indexOf(sceneCard.card));
                                  } else {
                                    _selectedCardsIndices.remove(gameState.cards
                                        .indexOf(sceneCard.card));
                                  }
                                }
                              });
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16.0),
              const Text(
                'Select Cards',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (!hasCards)
                const Text(
                  'No cards available.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxHeight: 200), // Set a maximum height
                  child: ListView(
                    shrinkWrap: true,
                    children: allCards.map((card) {
                      return Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  card.card.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    card.card.description,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          usedCards.contains(gameState.cards.indexOf(card.card))
                              ? Text('${card.label} - Used')
                              : Text(card.label),
                          Checkbox(
                            value: _selectedCardsIndices
                                .map((ind) => gameState.cards[ind])
                                .where((card) =>
                                    card.type != CardType.Obstacle &&
                                    card.playerStatus != PlayerStatus.NPC)
                                .toList()
                                .contains(card.card),
                            onChanged: (bool? value) {
                              setState(() {
                                if (!usedCards.contains(
                                    gameState.cards.indexOf(card.card))) {
                                  if (value == true) {
                                    _selectedCardsIndices.add(
                                        gameState.cards.indexOf(card.card));
                                  } else {
                                    _selectedCardsIndices.remove(
                                        gameState.cards.indexOf(card.card));
                                  }
                                }
                              });
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16.0),
              !isChallengeFinishing
                  ? Container()
                  : const Text(
                      'You are finishing the challenge, write the outcome!',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
              Expanded(
                child: TextFormField(
                  initialValue: _move != null && _move!.description != ''
                      ? _move!.description
                      : '',
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _description = value ?? '';
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              !_isChallengeSelected
                  ? Container()
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Text(
                        'You must select a challenge card to finish the challenge',
                        style: TextStyle(color: Colors.red),
                      )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: hasCards
                      ? () {
                          if (_selectedCardsIndices
                              .map((ind) => gameState.cards[ind])
                              .where((card) =>
                                  card.type == CardType.Obstacle ||
                                  card.playerStatus == PlayerStatus.NPC)
                              .isNotEmpty) {
                            if (_selectedCardsIndices
                                .map((ind) => gameState.cards[ind])
                                .where((card) =>
                                    card.type != CardType.Obstacle &&
                                    card.playerStatus != PlayerStatus.NPC)
                                .isEmpty) {
                              setState(() {
                                _isChallengeSelected = true;
                              });
                              return;
                            }
                          }
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            _move = Move(
                                _description,
                                gameState.selectedPlayer != null
                                    ? gameState.selectedPlayer!.name
                                    : 'ERROR: NO PLAYER SELECTED',
                                selectedCardsIndices: _selectedCardsIndices);
                            if (widget.move == null) {
                              gameState.makeMove(_move!);
                            } else {
                              gameState.updateMove(widget.move!, _move!);
                            }
                            Navigator.pop(context); // Pop back to GameRoomPage
                          }
                        }
                      : null,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
