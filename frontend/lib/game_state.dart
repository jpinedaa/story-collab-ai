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

class Challenge {
  final String description;
  final int points;

  Challenge(this.description, this.points);
}

class GameState with ChangeNotifier {
  List<Player> players = [];
  String currentSceneDescription = '';
  List<String> currentMoves = [];
  List<Challenge> challenges = [];
  Player? selectedPlayer;

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
      currentSceneDescription = data['currentSceneDescription'];
      currentMoves = List<String>.from(data['currentMoves']);
      notifyListeners();

      // Ensure there is a narrator
      final narrator =
          players.firstWhere((player) => player.role == 'Narrator', orElse: () {
        final newNarrator = Player('', 'Narrator', 'Manual');
        players.add(newNarrator);
        return newNarrator;
      });

      // Select the narrator by default
      selectPlayer(narrator);
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
        'currentSceneDescription': currentSceneDescription,
        'currentMoves': currentMoves,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update game state');
    }
    notifyListeners(); // Ensure UI update
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
    currentMoves.add(move);
    updateGameState();
    notifyListeners();
  }

  bool canMakeMove() {
    // Logic to determine if a move can be made
    return true;
  }
}
