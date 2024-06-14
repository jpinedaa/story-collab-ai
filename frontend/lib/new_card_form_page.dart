import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_state.dart';
import 'game_state.dart';
import 'card_creation_page.dart';
import 'scene_display_page.dart';

class NewCardFormPage extends StatefulWidget {
  final CardModel? card;
  final CardType? preselectedCardType;
  final bool fromSceneEditor;

  const NewCardFormPage({
    super.key,
    this.card,
    this.preselectedCardType,
    this.fromSceneEditor = false,
  });

  @override
  _NewCardFormPageState createState() => _NewCardFormPageState();
}

class _NewCardFormPageState extends State<NewCardFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCardType;
  String _description = '';
  String _title = '';
  String? _selectedPlayerStatus;

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      _title = widget.card!.title;
      _description = widget.card!.description;
      _selectedCardType = widget.card!.type.toString();
      _selectedPlayerStatus = widget.card!.playerStatus?.toString();
    } else if (widget.preselectedCardType != null) {
      _selectedCardType = widget.preselectedCardType.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final player = gameState.selectedPlayer;
    final cardState = Provider.of<CardState>(context);

    if (player == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create New Card'),
        ),
        body: const Center(
          child: Text('No player selected'),
        ),
      );
    }

    List<CardType> availableCardTypes = player.role == 'Narrator'
        ? [
            CardType.Place,
            CardType.Character,
            CardType.Obstacle,
            CardType.Nature,
            CardType.Strength,
            CardType.Weakness,
            CardType.Subplot,
            CardType.Asset,
            CardType.Goal,
          ]
        : [
            CardType.Nature,
            CardType.Strength,
            CardType.Weakness,
            CardType.Subplot,
            CardType.Asset,
            CardType.Goal,
          ];

    List<DropdownMenuItem<String>> playerStatusItems = PlayerStatus.values
        .map((status) => DropdownMenuItem<String>(
              value: status.toString(),
              child: Text(status.toString().split('.').last),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card == null ? 'Create New Card' : 'Edit Card'),
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
              DropdownButtonFormField<String>(
                value: _selectedCardType,
                decoration: const InputDecoration(labelText: 'Card Type'),
                items: availableCardTypes
                    .map((type) => DropdownMenuItem<String>(
                          value: type.toString(),
                          child: Text(type.toString().split('.').last),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCardType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a card type';
                  }
                  return null;
                },
              ),
              if (_selectedCardType == CardType.Character.toString() &&
                  player.role == 'Narrator')
                DropdownButtonFormField<String>(
                  value: _selectedPlayerStatus,
                  decoration: const InputDecoration(labelText: 'Player Status'),
                  items: playerStatusItems,
                  onChanged: (value) {
                    setState(() {
                      _selectedPlayerStatus = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a player status';
                    }
                    return null;
                  },
                ),
              Expanded(
                child: TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final newCard = CardModel(
                      title: _title,
                      description: _description,
                      type: CardType.values.firstWhere(
                        (e) => e.toString() == _selectedCardType,
                      ),
                      playerStatus:
                          _selectedCardType == CardType.Character.toString() &&
                                  player.role == 'Narrator'
                              ? PlayerStatus.values.firstWhere(
                                  (e) => e.toString() == _selectedPlayerStatus,
                                )
                              : null,
                    );
                    if (widget.card == null) {
                      player.cards = List.from(player.cards)..add(newCard);
                      if (newCard.type == CardType.Character) {
                        final newPlayer = Player(
                            newCard.title,
                            'Character',
                            newCard.playerStatus?.toString().split('.').last ??
                                'Manual');
                        gameState.addPlayer(newPlayer);
                      }
                      cardState.addCard(newCard);
                    } else {
                      final index = player.cards.indexOf(widget.card!);
                      player.cards[index] = newCard;
                    }
                    gameState.updateGameState().then((_) {
                      if (widget.fromSceneEditor) {
                        Navigator.pop(context); // Pop the form page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SceneDisplayPage(),
                          ),
                        );
                      } else {
                        Navigator.pop(context); // Pop the form page
                        Navigator.pop(context); // Pop back to CardCreationPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CardCreationPage()),
                        );
                      }
                    });
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
