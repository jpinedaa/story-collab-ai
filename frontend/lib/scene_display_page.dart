import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_state.dart';
import 'game_state.dart';
import 'new_card_form_page.dart';

class SceneDisplayPage extends StatefulWidget {
  final Scene? scene;

  const SceneDisplayPage({super.key, this.scene});

  @override
  _SceneDisplayPageState createState() => _SceneDisplayPageState();
}

class _SceneDisplayPageState extends State<SceneDisplayPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  CardModel? _selectedPlaceCard;
  final List<CardModel> _selectedChallenges = [];

  @override
  void initState() {
    super.initState();
    if (widget.scene != null) {
      _title = widget.scene!.title;
      _description = widget.scene!.description;
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
    final allCards = player.cards.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scene == null ? 'Scene Editor' : 'Edit Scene'),
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
              if (allCards.isEmpty)
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
              else if (allCards.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxHeight: 200), // Set a maximum height
                  child: ListView(
                    shrinkWrap: true,
                    children: allCards.map((card) {
                      return CheckboxListTile(
                        title: Text(card.title),
                        value: _selectedChallenges.contains(card),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedChallenges.add(card);
                            } else {
                              _selectedChallenges.remove(card);
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
                      final newScene = Scene(_title, _description);
                      if (widget.scene == null) {
                        gameState.createScene(newScene);
                      } else {
                        gameState.updateScene(widget.scene!, newScene);
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
