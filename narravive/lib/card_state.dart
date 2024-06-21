// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

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
  final Uint8List? imageBytes;

  CardModel({
    required this.title,
    required this.description,
    required this.type,
    this.playerStatus,
    this.imageBytes,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'playerStatus': playerStatus?.toString().split('.').last,
      'imageBytes': imageBytes
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
      imageBytes: json['imageBytes'] != null
          ? Uint8List.fromList(List<int>.from(json['imageBytes']))
          : null,
    );
  }
}

class SelectableCard {
  final CardModel card;
  final String label;

  SelectableCard(this.card, this.label);
}
