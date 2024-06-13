// card_state.dart
import 'package:flutter/material.dart';

class CardState with ChangeNotifier {
  List<CardModel> cards = [];

  void addCard(CardModel card) {
    cards.add(card);
    notifyListeners();
  }

  List<CardModel> getCardsByType(CardType type) {
    return cards.where((card) => card.type == type).toList();
  }
}

enum CardType {
  place,
  character,
  obstacle,
  nature,
  strength,
  weakness,
  subplot,
  asset,
  goal,
}

class CardModel {
  final String title;
  final String description;
  final CardType type;

  CardModel({
    required this.title,
    required this.description,
    required this.type,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
    };
  }

  // Create from JSON
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      title: json['title'],
      description: json['description'],
      type: CardType.values
          .firstWhere((e) => e.toString() == 'CardType.${json['type']}'),
    );
  }
}
