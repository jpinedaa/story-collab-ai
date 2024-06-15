import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_state.dart';
import 'game_state.dart';
import 'new_card_form_page.dart';
import 'card_detail_dialog.dart';

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
            'Place': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Place)
                .toList(),
            'Character': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Character)
                .toList(),
            'Obstacle': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Obstacle)
                .toList(),
            'Nature': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Nature)
                .toList(),
            'Strength': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Strength)
                .toList(),
            'Weakness': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Weakness)
                .toList(),
            'Subplot': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Subplot)
                .toList(),
            'Asset': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Asset)
                .toList(),
            'Goal': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Goal)
                .toList(),
          }
        : {
            'Nature': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Nature)
                .toList(),
            'Strength': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Strength)
                .toList(),
            'Weakness': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Weakness)
                .toList(),
            'Subplot': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Subplot)
                .toList(),
            'Asset': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
                .where((card) => card.type == CardType.Asset)
                .toList(),
            'Goal': player.cardsIndices
                .map((ind) => gameState.cards[ind])
                .toList()
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
            maxLines: 1,
          ),
          if (card.imageBytes != null) ...[
            const SizedBox(height: 8.0),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Image.memory(card.imageBytes!, fit: BoxFit.cover),
              ),
            )
          ],
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
