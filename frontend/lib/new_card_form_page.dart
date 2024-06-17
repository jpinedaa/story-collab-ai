import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_state.dart';
import 'game_state.dart';
import 'card_creation_page.dart';
import 'scene_display_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
//import 'package:image_compression/image_compression.dart';
import 'package:image/image.dart' as img;

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
  NewCardFormPageState createState() => NewCardFormPageState();
}

class NewCardFormPageState extends State<NewCardFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCardType;
  String _description = '';
  String _title = '';
  String? _selectedPlayerStatus;
  Uint8List? _imageBytes;
  bool _isCompressing = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      _title = widget.card!.title;
      _description = widget.card!.description;
      _selectedCardType = widget.card!.type.toString();
      _selectedPlayerStatus = widget.card!.playerStatus?.toString();
      _imageBytes = widget.card!.imageBytes;
    } else if (widget.preselectedCardType != null) {
      _selectedCardType = widget.preselectedCardType.toString();
    }
  }

  Future<void> save() async {
    setState(() {
      isSaving = true;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        _isCompressing = true;
      });

      // Allow UI to update
      await Future.delayed(const Duration(milliseconds: 100));

      // Compress the image
      final compressedBytes = await compressImage(bytes);

      setState(() {
        _imageBytes = compressedBytes;
        _isCompressing = false;
      });
    }
  }

  // Future<Uint8List> compressImage(Uint8List bytes) async {
  //   final input = ImageFile(
  //     rawBytes: bytes,
  //     filePath: '', // optional: file path can be empty for web
  //   );
  //   const config = Configuration(
  //     jpgQuality: 5,
  //   );
  //   final imgconfig = ImageFileConfiguration(input: input, config: config);

  //   final compressedFile = await compressInQueue(imgconfig);
  //   return compressedFile.rawBytes;
  // }

  Future<Uint8List> compressImage(Uint8List bytes,
      {int targetWidth = 300, int targetHeight = 300}) async {
    // Decode the image
    img.Image image = img.decodeImage(bytes)!;

    // Resize the image
    img.Image resizedImage =
        img.copyResize(image, width: targetWidth, height: targetHeight);

    // Compress the resized image
    Uint8List compressedBytes =
        Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));

    return compressedBytes;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final player = gameState.selectedPlayer;

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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double availableHeight = constraints.maxHeight -
                        6; // Adjust this value as needed
                    return Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: SizedBox(
                            height: availableHeight,
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
                        ),
                        const SizedBox(
                            width: 16), // Add some space between the widgets
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: Colors.grey[200],
                                ),
                                height: availableHeight,
                                width: double.infinity,
                                child: Center(
                                  child: _isCompressing
                                      ? const Text('Compressing Image...',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold))
                                      : _imageBytes == null
                                          ? ElevatedButton(
                                              onPressed: _pickImage,
                                              child: const Text('Pick Image'),
                                            )
                                          : Image.memory(_imageBytes!,
                                              fit: BoxFit.cover),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              !isSaving
                  ? ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          save();
                          final newCard = CardModel(
                            title: _title,
                            description: _description,
                            type: CardType.values.firstWhere(
                              (e) => e.toString() == _selectedCardType,
                            ),
                            playerStatus: _selectedCardType ==
                                        CardType.Character.toString() &&
                                    player.role == 'Narrator'
                                ? PlayerStatus.values.firstWhere(
                                    (e) =>
                                        e.toString() == _selectedPlayerStatus,
                                  )
                                : null,
                            imageBytes: _imageBytes,
                          );
                          if (widget.card == null) {
                            gameState.addCard(newCard);
                            player.cardsIndices = List.from(player.cardsIndices)
                              ..add(gameState.cards.indexOf(newCard));
                            if (newCard.type == CardType.Character &&
                                newCard.playerStatus != PlayerStatus.NPC) {
                              final newPlayer = Player(newCard.title,
                                  'Character', newCard.playerStatus!.name,
                                  cardIndex: gameState.cards.indexOf(newCard));
                              gameState.addPlayer(newPlayer);
                            }
                          } else {
                            gameState.updateCard(widget.card!, newCard);
                          }
                          gameState.updateGameState().then((_) {
                            if (widget.fromSceneEditor) {
                              Navigator.pop(context); // Pop the form page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SceneDisplayPage(),
                                ),
                              );
                            } else {
                              Navigator.pop(context); // Pop the form page
                              Navigator.pop(
                                  context); // Pop back to CardCreationPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CardCreationPage()),
                              );
                            }
                          });
                        }
                      },
                      child: const Text('Save'),
                    )
                  : const Text('Saving...'),
            ],
          ),
        ),
      ),
    );
  }
}
