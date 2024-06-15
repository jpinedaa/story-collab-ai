import 'dart:convert';
import 'package:flutter/material.dart';
import 'card_state.dart';
import 'package:http/http.dart' as http;

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
        placeCardIndex: json['placeCardIndex'] as int,
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

  Move(this.description, {this.selectedCardsIndices = const []});

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(json['description'],
        selectedCardsIndices: (json['selectedCardsIndices'] as List<dynamic>)
            .map((e) => e as int)
            .toList());
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'selectedCardsIndices': selectedCardsIndices
      };
}

class GameState with ChangeNotifier {
  List<Player> players = [];
  List<dynamic> sceneAndMoves = [];
  Player? selectedPlayer;
  List<CardModel> cards = [];

  static const String backendUrl = 'http://127.0.0.1:5000/gamestate';

  GameState() {
    fetchGameState();
  }

  Future<void> fetchGameState() async {
    final response = await http.get(Uri.parse(backendUrl));
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
        final newNarrator = Player('', 'Narrator', 'Manual');
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

  Future<void> updateGameState() async {
    final response = await http.post(
      Uri.parse(backendUrl),
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
    cards.remove(card);
    // Remove the card from all players
    for (final player in players) {
      player.cardsIndices.remove(cardIndex);
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
}
