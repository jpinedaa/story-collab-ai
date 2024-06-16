import 'dart:convert';
import 'dart:async'; // Add this import
import 'package:flutter/material.dart';
import 'card_state.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class Player {
  final String name;
  final String role;
  String status;
  List<int> cardsIndices;
  int? cardIndex;

  Player(this.name, this.role, this.status,
      {List<int>? cardsIndices, this.cardIndex})
      : cardsIndices = cardsIndices ?? [];

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(json['name'], json['role'], json['status'],
        cardsIndices: (json['cardsIndices'] as List<dynamic>)
            .map((e) => e as int)
            .toList(),
        cardIndex: json['cardIndex'] as int?);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'status': status,
        'cardsIndices': cardsIndices,
        'cardIndex': cardIndex
      };
}

class SceneComponent {
  final String title;
  final String description;
  final int? placeCardIndex;
  final List<int> selectedCardsIndices;

  SceneComponent(this.title, this.description,
      {this.placeCardIndex, this.selectedCardsIndices = const []});

  factory SceneComponent.fromJson(Map<String, dynamic> json) {
    return SceneComponent(json['title'], json['description'],
        placeCardIndex: json['placeCardIndex'] as int?,
        selectedCardsIndices: (json['selectedCardsIndices'] as List<dynamic>)
            .map((e) => e as int)
            .toList());
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'placeCardIndex': placeCardIndex,
        'selectedCardsIndices': selectedCardsIndices,
      };
}

class Move {
  final String description;
  final List<int> selectedCardsIndices;
  final String character;

  Move(this.description, this.character,
      {this.selectedCardsIndices = const []});

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(json['description'], json['character'],
        selectedCardsIndices: (json['selectedCardsIndices'] as List<dynamic>)
            .map((e) => e as int)
            .toList());
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'character': character,
        'selectedCardsIndices': selectedCardsIndices
      };
}

class GameState with ChangeNotifier {
  List<Player> players = [];
  List<dynamic> sceneAndMoves = [];
  Player? selectedPlayer;
  List<CardModel> cards = [];
  List<int> finishedChallenges = [];
  Map<int, int> challengeProgress = {};
  bool isAutoRunning = false;
  Timer? _timer; // Add this line to declare the Timer object
  String? autoErrorMessage;

  static const String backendUrl = 'http://127.0.0.1:5000/gamestate';

  GameState() {
    fetchGameState();
    loadSettings();
  }

  Future<void> fetchGameState([String? path]) async {
    // Construct the URL with the optional path parameter
    final url = path != null ? '$backendUrl?path=$path' : backendUrl;

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      players = (data['players'] as List)
          .map((player) => Player.fromJson(player))
          .toList();
      sceneAndMoves = List<dynamic>.from(data['sceneAndMoves'].map((item) {
        if (item['title'] != null) {
          return SceneComponent.fromJson(item);
        } else {
          return Move.fromJson(item); // it's a move
        }
      }));
      cards = (data['cards'] as List)
          .map((card) => CardModel.fromJson(card))
          .toList();
      // Ensure there is a narrator
      final narrator =
          players.firstWhere((player) => player.role == 'Narrator', orElse: () {
        final newNarrator = Player('', 'Narrator', 'Auto');
        players.add(newNarrator);
        return newNarrator;
      });
      // Select the narrator by default
      selectPlayer(narrator);

      notifyListeners();
    } else {
      throw Exception('Failed to load game state');
    }
  }

  Future<void> updateGameState([String? path]) async {
    // Construct the URL with the optional path parameter
    final url = path != null ? '$backendUrl?path=$path' : backendUrl;

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'players': players.map((player) => player.toJson()).toList(),
        'sceneAndMoves': sceneAndMoves.map((item) {
          if (item is SceneComponent) {
            return item.toJson();
          } else {
            return item.toJson(); // it's a move
          }
        }).toList(),
        'cards': cards.map((card) => card.toJson()).toList(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update game state');
    }
    notifyListeners();
  }

  void startAutoRun({int intervalSeconds = 1}) {
    isAutoRunning = true;
    http
        .get(Uri.parse(
            'http://127.0.0.1:5000/autorun?selected=${selectedPlayer!.name}'))
        .then((response) {
      if (response.statusCode != 200) {
        autoErrorMessage = response.body;
        isAutoRunning = false;
        notifyListeners();
        throw Exception('Failed to make autorun request');
      }
    });
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) {
      if (isAutoRunning && selectedPlayer!.status == 'Auto') {
        fetchGameState();
      } else {
        isAutoRunning = false;
        timer.cancel();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void stopAutoRun() {
    isAutoRunning = false;
    _timer?.cancel();
    fetchGameState();
    notifyListeners();
  }

  Future<void> saveGameState() async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      fileName: 'story.json',
    );
    updateGameState(outputFile);
  }

  Future<void> openGameState() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    fetchGameState(result.files.single.path);
    updateGameState();
  }

  void checkFinishedChallenges() {
    challengeProgress.clear();
    for (final sceneOrMove in sceneAndMoves) {
      if (sceneOrMove is Move) {
        for (int cardInd in sceneOrMove.selectedCardsIndices) {
          if (cards[cardInd].type == CardType.Obstacle ||
              cards[cardInd].playerStatus == PlayerStatus.NPC) {
            challengeProgress.update(cardInd, (value) => value + 1,
                ifAbsent: () => 1);
          }
        }
      }
      finishedChallenges.clear();
      for (int cardInd in challengeProgress.keys) {
        if (challengeProgress[cardInd]! >= 3) {
          finishedChallenges.add(cardInd);
        }
      }
    }
  }

  void selectPlayer(Player player) {
    selectedPlayer = player;
    notifyListeners();
  }

  void addPlayer(Player player) {
    players.add(player);
    updateGameState();
    notifyListeners();
  }

  void makeMove(Move move) {
    sceneAndMoves.add(move);
    updateGameState();
    notifyListeners();
  }

  bool canMakeMove() {
    return true;
  }

  void createSceneComponent(SceneComponent sceneComponent) {
    sceneAndMoves.add(sceneComponent);
    updateGameState();
    notifyListeners();
  }

  void updateSceneComponent(
      SceneComponent oldSceneComponent, SceneComponent newSceneComponent) {
    final index = sceneAndMoves.indexOf(oldSceneComponent);
    if (index != -1) {
      sceneAndMoves[index] = newSceneComponent;
      updateGameState();
      notifyListeners();
    }
  }

  void deleteItem(dynamic item) {
    sceneAndMoves.remove(item);
    updateGameState();
    notifyListeners();
  }

  void updateMove(Move oldMove, Move newMove) {
    final index = sceneAndMoves.indexOf(oldMove);
    if (index != -1) {
      sceneAndMoves[index] = newMove;
      updateGameState();
      notifyListeners();
    }
  }

  List<CardModel> getCardsByType(CardType type) {
    return cards.where((card) => card.type == type).toList();
  }

  void addCard(CardModel card) {
    cards.add(card);
    updateGameState();
    notifyListeners();
  }

  void updateCard(CardModel oldCard, CardModel newCard) {
    final index = cards.indexOf(oldCard);
    if (index != -1) {
      cards[index] = newCard;
      updateGameState();
      notifyListeners();
    }
  }

  void removeCard(CardModel card) {
    int cardIndex = cards.indexOf(card);
    //cards.remove(card);
    cards[cardIndex] = CardModel(
        title: '',
        description: '',
        type: CardType
            .Asset); // not actually removing the card for now to keep the indices consistent
    // Remove the card from all players
    final playersCopy = List<Player>.from(players);
    for (final player in playersCopy) {
      if (player.cardsIndices.contains(cardIndex)) {
        player.cardsIndices.remove(cardIndex);
      }
      if (player.cardIndex == cardIndex) {
        players.remove(player);
      }
    }
    // Throw exception if the card is used in a scene or move
    for (final sceneOrMove in sceneAndMoves) {
      if (sceneOrMove is SceneComponent) {
        if (sceneOrMove.placeCardIndex == cardIndex) {
          throw Exception('Cannot delete card used in a scene');
        }
        if (sceneOrMove.selectedCardsIndices.contains(cardIndex)) {
          throw Exception('Cannot delete card used in a scene');
        }
      }
      if (sceneOrMove is Move) {
        if (sceneOrMove.selectedCardsIndices.contains(cardIndex)) {
          throw Exception('Cannot delete card used in a move');
        }
      }
    }
    updateGameState();
    notifyListeners();
  }

  String? _apiKey;
  String? _model;

  String? get apiKey => _apiKey;
  String? get model => _model;

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
    notifyListeners();
  }

  void setModel(String model) {
    _model = model;
    notifyListeners();
  }

  Future<void> loadSettings() async {
    const url = 'http://127.0.0.1:5000/settings';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final settings = json.decode(response.body);
      _apiKey = settings['apiKey'];
      _model = settings['model'];
      notifyListeners();
    } else {
      throw Exception('Failed to load settings');
    }
  }

  Future<void> saveSettings() async {
    const url = 'http://127.0.0.1:5000/settings';
    final settings = {
      'apiKey': _apiKey,
      'model': _model,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(settings),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save settings');
    }
  }
}
