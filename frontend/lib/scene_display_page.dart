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
  int? _selectedPlaceCardIndex;
  final List<int> _selectedChallengesIndices = [];
  final List<int> _selectedCardIndicesOriginal = [];

  @override
  void initState() {
    super.initState();
    if (widget.sceneComponent != null) {
      _title = widget.sceneComponent!.title;
      _description = widget.sceneComponent!.description;
      _selectedPlaceCardIndex = widget.sceneComponent!.placeCardIndex;
      _selectedChallengesIndices
          .addAll(widget.sceneComponent!.selectedCardsIndices);
      _selectedCardIndicesOriginal.addAll(_selectedChallengesIndices);
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

    List<int> usedCards = gameState.sceneAndMoves
        .whereType<SceneComponent>()
        .map((sc) => sc.selectedCardsIndices)
        .expand((element) => element)
        .toList();
    usedCards.removeWhere(
        (element) => _selectedCardIndicesOriginal.contains(element));
    print('usedCards: $usedCards');
    print('_selectedChallengesIndices: $_selectedChallengesIndices');

    final placeCards = player.cardsIndices
        .map((ind) => gameState.cards[ind])
        .toList()
        .where((card) => card.type == CardType.Place)
        .toList();
    final selectableCards = player.cardsIndices
        .map((ind) => gameState.cards[ind])
        .toList()
        .where((card) => (card.playerStatus == PlayerStatus.NPC ||
            card.type == CardType.Obstacle ||
            card.type == CardType.Asset ||
            card.type == CardType.Goal))
        .map((card) {
      String label =
          (card.type == CardType.Obstacle || card.type == CardType.Character)
              ? 'Challenge'
              : 'Pickup - ${card.type.name}';
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
                  value: _selectedPlaceCardIndex != null
                      ? gameState.cards[_selectedPlaceCardIndex!]
                      : null,
                  decoration: const InputDecoration(labelText: 'Place Card'),
                  items: placeCards
                      .map((card) => DropdownMenuItem<CardModel>(
                            value: card,
                            child: Text(card.title),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlaceCardIndex =
                          value != null ? gameState.cards.indexOf(value) : null;
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
                          !usedCards.contains(
                                  gameState.cards.indexOf(selectableCard.card))
                              ? Text(selectableCard.label)
                              : Text('${selectableCard.label} - Used'),
                          Checkbox(
                            value: _selectedChallengesIndices
                                .map((ind) => gameState.cards[ind])
                                .toList()
                                .contains(selectableCard.card),
                            onChanged: (bool? value) {
                              setState(() {
                                if (!usedCards.contains(gameState.cards
                                    .indexOf(selectableCard.card))) {
                                  if (value == true) {
                                    _selectedChallengesIndices.add(gameState
                                        .cards
                                        .indexOf(selectableCard.card));
                                  } else {
                                    _selectedChallengesIndices.remove(gameState
                                        .cards
                                        .indexOf(selectableCard.card));
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
                        placeCardIndex: _selectedPlaceCardIndex,
                        selectedCardsIndices: _selectedChallengesIndices,
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
