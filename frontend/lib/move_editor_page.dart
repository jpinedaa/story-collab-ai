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
  Move _move = Move('');
  final List<CardModel> _selectedCards = [];
  final List<CardModel> _selectedSceneCards = [];

  @override
  void initState() {
    super.initState();
    if (widget.move != null) {
      _move = widget.move!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final player = gameState.selectedPlayer;

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

    final allCards =
        player.cardsIndices.map((ind) => gameState.cards[ind]).toList();
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
                          Text(sceneCard.label),
                          Checkbox(
                            value: _selectedSceneCards.contains(sceneCard.card),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedSceneCards.add(sceneCard.card);
                                } else {
                                  _selectedSceneCards.remove(sceneCard.card);
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
                      return CheckboxListTile(
                        title: Text(card.title),
                        value: _selectedCards.contains(card),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedCards.add(card);
                            } else {
                              _selectedCards.remove(card);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16.0),
              Expanded(
                child: TextFormField(
                  initialValue: _move.description,
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
                    _move = Move(value ?? '');
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: hasCards
                      ? () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            if (widget.move == null) {
                              gameState.makeMove(_move);
                            } else {
                              gameState.updateMove(widget.move!, _move);
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
