import 'dart:convert';
import 'package:flutter/material.dart';
import 'card_state.dart';
import 'package:http/http.dart' as http;

class Player {
  final String name;
  final String role;
  String status;
  List<CardModel> cards;

  Player(this.name, this.role, this.status, {this.cards = const []});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(json['name'], json['role'], json['status']);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'status': status,
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
  bool isNarrator = true;
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
      isNarrator = data['isNarrator'];
      notifyListeners();

      // Ensure there is a narrator
      final narrator =
          players.firstWhere((player) => player.role == 'Narrator', orElse: () {
        final newNarrator = Player('Narrator', 'Narrator', 'active');
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
        'isNarrator': isNarrator,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update game state');
    }
  }

  void selectPlayer(Player player) {
    selectedPlayer = player;
    notifyListeners();
  }

  void startNewScene() {
    currentSceneDescription = 'A new scene description goes here.';
    currentMoves = ['New move 1', 'New move 2', 'New move 3'];
    updateGameState();
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
