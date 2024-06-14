import 'dart:convert';
import 'package:flutter/material.dart';
import 'card_state.dart';
import 'package:http/http.dart' as http;

class Player {
  final String name;
  final String role;
  String status;
  List<CardModel> cards;

  Player(this.name, this.role, this.status, {List<CardModel>? cards})
      : cards = cards ?? [];

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      json['name'],
      json['role'],
      json['status'],
      cards: (json['cards'] as List<dynamic>?)
          ?.map((card) => CardModel.fromJson(card))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'status': status,
        'cards': cards.map((card) => card.toJson()).toList(),
      };
}

class SceneComponent {
  final String title;
  final String description;

  SceneComponent(this.title, this.description);

  factory SceneComponent.fromJson(Map<String, dynamic> json) {
    return SceneComponent(json['title'], json['description']);
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };
}

class GameState with ChangeNotifier {
  List<Player> players = [];
  List<dynamic> sceneAndMoves = [];
  Player? selectedPlayer;

  static const String backendUrl = 'http://127.0.0.1:5000/gamestate';

  GameState() {
    fetchGameState();
  }

  Future<void> fetchGameState() async {
    final response = await http.get(Uri.parse(backendUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched data: $data'); // Debugging: print fetched data
      players = (data['players'] as List)
          .map((player) => Player.fromJson(player))
          .toList();
      sceneAndMoves = List<dynamic>.from(data['sceneAndMoves'].map((item) {
        if (item['title'] != null) {
          return SceneComponent.fromJson(item);
        } else {
          return item; // it's a move (String)
        }
      }));
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
            return item; // it's a move (String)
          }
        }).toList(),
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
    notifyListeners();
  }

  void makeMove(String move) {
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

  void updateMove(String oldMove, String newMove) {
    final index = sceneAndMoves.indexOf(oldMove);
    if (index != -1) {
      sceneAndMoves[index] = newMove;
      updateGameState();
      notifyListeners();
    }
  }
}
