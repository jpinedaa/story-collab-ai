import 'package:flutter/material.dart';
import 'card_state.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';
import 'new_card_form_page.dart';
import 'dart:math';

class CardDetailDialog extends StatelessWidget {
  final CardModel card;
  final bool showEditDelete; // Add this line

  const CardDetailDialog({
    super.key,
    required this.card,
    this.showEditDelete = true, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    // Check if the card has been used
    bool isCardUsed = false;
    for (final moveOrScenecomponent in gameState.sceneAndMoves) {
      if (moveOrScenecomponent is Move) {
        if (moveOrScenecomponent.selectedCardsIndices
            .map((ind) => gameState.cards[ind])
            .toList()
            .contains(card)) {
          isCardUsed = true;
          break;
        }
      }
      if (moveOrScenecomponent is SceneComponent) {
        if (moveOrScenecomponent.selectedCardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .contains(card) ||
            (moveOrScenecomponent.placeCardIndex != null &&
                gameState.cards[moveOrScenecomponent.placeCardIndex!] ==
                    card)) {
          isCardUsed = true;
          break;
        }
      }
    }

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
                          if (card.imageBytes != null) ...[
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              height: 300,
                              width: double.infinity,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Image.memory(card.imageBytes!,
                                    fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                          ],
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
                    if (showEditDelete)
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
                                onPressed: () {
                                  CardModel duplicateCard = CardModel(
                                      title: card.title,
                                      description: card.description,
                                      type: card.type);
                                  gameState.addCard(duplicateCard);
                                  gameState.selectedPlayer!.cardsIndices.add(
                                      gameState.cards.indexOf(duplicateCard));
                                },
                                icon: const Icon(
                                  Icons.plus_one,
                                  color: Colors.green,
                                  size: 30,
                                )),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color:
                                      !isCardUsed ? Colors.red : Colors.grey),
                              onPressed: !isCardUsed
                                  ? () {
                                      gameState.removeCard(card);
                                      Navigator.pop(
                                          context); // Close the dialog
                                    }
                                  : null,
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
