import 'package:flutter/material.dart';

class CardState with ChangeNotifier {
  List<CardModel> cards = [];

  void addCard(CardModel card) {
    cards.add(card);
    notifyListeners();
  }

  void removeCard(CardModel card) {
    cards.remove(card);
    notifyListeners();
  }

  List<CardModel> getCardsByType(CardType type) {
    return cards.where((card) => card.type == type).toList();
  }
}

enum CardType {
  Place,
  Character,
  Obstacle,
  Nature,
  Strength,
  Weakness,
  Subplot,
  Asset,
  Goal,
}

enum PlayerStatus { Manual, Auto, NPC }

class CardModel {
  final String title;
  final String description;
  final CardType type;
  final PlayerStatus? playerStatus; // Added playerStatus field

  CardModel({
    required this.title,
    required this.description,
    required this.type,
    this.playerStatus, // Initialize playerStatus field
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'playerStatus': playerStatus
          ?.toString()
          .split('.')
          .last, // Convert playerStatus to JSON
    };
  }

  // Create from JSON
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      title: json['title'],
      description: json['description'],
      type: CardType.values
          .firstWhere((e) => e.toString() == 'CardType.${json['type']}'),
      playerStatus: json['playerStatus'] != null
          ? PlayerStatus.values.firstWhere(
              (e) => e.toString() == 'PlayerStatus.${json['playerStatus']}')
          : null,
    );
  }
}
