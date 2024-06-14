import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_state.dart';
import 'game_state.dart';
import 'new_card_form_page.dart';

class SceneDisplayPage extends StatefulWidget {
  final SceneComponent? sceneComponent;

  const SceneDisplayPage({super.key, this.sceneComponent});

  @override
  SceneDisplayPageState createState() => SceneDisplayPageState();
}

class SceneDisplayPageState extends State<SceneDisplayPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  CardModel? _selectedPlaceCard;
  final List<CardModel> _selectedChallenges = [];

  @override
  void initState() {
    super.initState();
    if (widget.sceneComponent != null) {
      _title = widget.sceneComponent!.title;
      _description = widget.sceneComponent!.description;
      _selectedPlaceCard = widget.sceneComponent!.placeCard;
      _selectedChallenges.addAll(widget.sceneComponent!.selectedCards);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final player = gameState.selectedPlayer;

    if (player == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scene Editor'),
        ),
        body: const Center(
          child: Text('No player selected'),
        ),
      );
    }

    final placeCards =
        player.cards.where((card) => card.type == CardType.Place).toList();
    final selectableCards = player.cards
        .where((card) =>
            card.type != CardType.Character ||
            card.playerStatus == PlayerStatus.NPC)
        .map((card) {
      String label =
          (card.type == CardType.Obstacle || card.type == CardType.Character)
              ? 'Challenge'
              : 'Pickup';
      return SelectableCard(card, label);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.sceneComponent == null ? 'Scene Editor' : 'Edit Scene'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value ?? '';
                },
              ),
              if (placeCards.isEmpty)
                Column(
                  children: [
                    const Text(
                      'No place cards available.',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewCardFormPage(
                                preselectedCardType: CardType.Place,
                                fromSceneEditor: true),
                          ),
                        );
                      },
                      child: const Text('Create Place Card'),
                    ),
                  ],
                )
              else
                DropdownButtonFormField<CardModel>(
                  value: _selectedPlaceCard,
                  decoration: const InputDecoration(labelText: 'Place Card'),
                  items: placeCards
                      .map((card) => DropdownMenuItem<CardModel>(
                            value: card,
                            child: Text(card.title),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlaceCard = value;
                    });
                  },
                ),
              const SizedBox(height: 16.0),
              const Text(
                'Select Cards',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (selectableCards.isEmpty)
                Column(
                  children: [
                    const Text(
                      'No cards available.',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NewCardFormPage(fromSceneEditor: true),
                          ),
                        );
                      },
                      child: const Text('Create Card'),
                    ),
                  ],
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxHeight: 200), // Set a maximum height
                  child: ListView(
                    shrinkWrap: true,
                    children: selectableCards.map((selectableCard) {
                      return Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  selectableCard.card.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    selectableCard.card.description,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(selectableCard.label),
                          Checkbox(
                            value: _selectedChallenges
                                .contains(selectableCard.card),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedChallenges.add(selectableCard.card);
                                } else {
                                  _selectedChallenges
                                      .remove(selectableCard.card);
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
              Expanded(
                child: TextFormField(
                  initialValue: _description,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      final newSceneComponent = SceneComponent(
                        _title,
                        _description,
                        placeCard: _selectedPlaceCard,
                        selectedCards: _selectedChallenges,
                      );
                      if (widget.sceneComponent == null) {
                        gameState.createSceneComponent(newSceneComponent);
                      } else {
                        gameState.updateSceneComponent(
                            widget.sceneComponent!, newSceneComponent);
                      }
                      Navigator.pop(context); // Pop back to GameRoomPage
                    }
                  },
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
