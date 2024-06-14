import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_state.dart';
import 'game_state.dart';
import 'new_card_form_page.dart';
import 'dart:math';

class CardCreationPage extends StatelessWidget {
  const CardCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final player = gameState.selectedPlayer;

    if (player == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Card Creation'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: const Center(
          child: Text('No player selected'),
        ),
      );
    }

    final cardCategories = player.role == 'Narrator'
        ? {
            'Place': player.cards
                .where((card) => card.type == CardType.Place)
                .toList(),
            'Character': player.cards
                .where((card) => card.type == CardType.Character)
                .toList(),
            'Obstacle': player.cards
                .where((card) => card.type == CardType.Obstacle)
                .toList(),
            'Nature': player.cards
                .where((card) => card.type == CardType.Nature)
                .toList(),
            'Strength': player.cards
                .where((card) => card.type == CardType.Strength)
                .toList(),
            'Weakness': player.cards
                .where((card) => card.type == CardType.Weakness)
                .toList(),
            'Subplot': player.cards
                .where((card) => card.type == CardType.Subplot)
                .toList(),
            'Asset': player.cards
                .where((card) => card.type == CardType.Asset)
                .toList(),
            'Goal': player.cards
                .where((card) => card.type == CardType.Goal)
                .toList(),
          }
        : {
            'Nature': player.cards
                .where((card) => card.type == CardType.Nature)
                .toList(),
            'Strength': player.cards
                .where((card) => card.type == CardType.Strength)
                .toList(),
            'Weakness': player.cards
                .where((card) => card.type == CardType.Weakness)
                .toList(),
            'Subplot': player.cards
                .where((card) => card.type == CardType.Subplot)
                .toList(),
            'Asset': player.cards
                .where((card) => card.type == CardType.Asset)
                .toList(),
            'Goal': player.cards
                .where((card) => card.type == CardType.Goal)
                .toList(),
          };

    return Scaffold(
      appBar: AppBar(title: Text('Card Creation for ${player.name}')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: cardCategories.entries
                        .map((entry) =>
                            buildCardCategory(entry.key, entry.value, context))
                        .toList(),
                  ),
                ),
                const SizedBox(
                    height: 80), // Spacer to ensure scrolling above the button
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NewCardFormPage()),
                    );
                  },
                  child: const Text('Create New Card'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildCardCategory(
    String category, List<CardModel> cards, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          category,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      if (cards.isEmpty)
        const Text('No cards available in this category.')
      else
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: cards.map((card) => buildCard(card, context)).toList(),
        ),
    ],
  );
}

Widget buildCard(CardModel card, BuildContext context) {
  return GestureDetector(
    onTap: () {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return Center(
            child: CardDetailDialog(card: card),
          );
        },
      );
    },
    child: Container(
      width: 200,
      height: 150, // Set a fixed height for all cards
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Ensure text color is black
              decoration:
                  TextDecoration.none, // Remove any underline decoration
            ),
            overflow: TextOverflow.ellipsis, // Truncate text if it doesn't fit
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Text(
              card.description,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black, // Ensure text color is black
                decoration:
                    TextDecoration.none, // Remove any underline decoration
              ),
              overflow:
                  TextOverflow.ellipsis, // Truncate text if it doesn't fit
              maxLines: 4, // Limit to 4 lines
            ),
          ),
        ],
      ),
    ),
  );
}

class CardDetailDialog extends StatelessWidget {
  final CardModel card;

  const CardDetailDialog({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final cardState = Provider.of<CardState>(context, listen: false);
    final gameState = Provider.of<GameState>(context, listen: false);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double maxWidth = constraints.maxWidth * 0.8;
              double maxHeight = constraints.maxHeight * 0.8;

              double minWidth = constraints.maxWidth * 0.3;
              double minHeight = constraints.maxHeight * 0.3;

              final double aspectRatio = minWidth / minHeight;
              const double fontSize = 18.0;
              final Size textSize = calculateTextDimensions(
                  card.description, fontSize, aspectRatio);

              if (textSize.width > minWidth && textSize.width < maxWidth) {
                maxWidth = textSize.width;
              }

              if (textSize.width < minWidth) {
                maxWidth = minWidth;
              }

              return Container(
                padding: const EdgeInsets.all(16.0),
                constraints: BoxConstraints(
                    minWidth: minWidth,
                    minHeight: minHeight,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SelectableText(
                            card.title,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Ensure text color is black
                              decoration: TextDecoration
                                  .none, // Remove any underline decoration
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          SelectableText(
                            card.description,
                            style: const TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight
                                  .normal, // Ensure normal text weight
                              color: Colors.black, // Ensure text color is black
                              decoration: TextDecoration
                                  .none, // Remove any underline decoration
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NewCardFormPage(card: card),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              cardState.removeCard(card);
                              final player = gameState.selectedPlayer;
                              if (player != null) {
                                player.cards.remove(card);
                                gameState.updateGameState().then((_) {
                                  gameState
                                      .notifyListeners(); // Ensure UI update
                                });
                              }
                              Navigator.pop(context); // Close the dialog
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Size calculateTextDimensions(String text, double fontSize, double aspectRatio) {
  // Step 1: Calculate the total height of the text in a single line
  final TextPainter singleLineTextPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  final double singleLineWidth = singleLineTextPainter.width;
  final double singleLineHeight = singleLineTextPainter.height;

  // Step 2: Determine the width and height with the new aspect ratio
  // Calculate the area needed to fit the text (singleLineWidth * singleLineHeight)
  final double area = singleLineWidth * singleLineHeight;

  // Calculate the new height by maintaining the aspect ratio and fitting the text area
  final double height = sqrt(area / aspectRatio);
  final double width = height * aspectRatio;

  return Size(width, height);
}
