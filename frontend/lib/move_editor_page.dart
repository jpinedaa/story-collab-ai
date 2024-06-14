import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_state.dart';
import 'game_state.dart';

class MoveEditorPage extends StatefulWidget {
  final String? move;

  const MoveEditorPage({super.key, this.move});

  @override
  MoveEditorPageState createState() => MoveEditorPageState();
}

class MoveEditorPageState extends State<MoveEditorPage> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  final List<CardModel> _selectedChallenges = [];

  @override
  void initState() {
    super.initState();
    if (widget.move != null) {
      _description = widget.move!;
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

    final allCards = player.cards.toList();
    final bool hasCards = allCards.isNotEmpty;

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
                  onPressed: hasCards
                      ? () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            if (widget.move == null) {
                              gameState.makeMove(_description);
                            } else {
                              gameState.updateMove(widget.move!, _description);
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
