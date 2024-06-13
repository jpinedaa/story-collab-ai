import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_state.dart';
import 'game_state.dart';

class CardCreationPage extends StatelessWidget {
  const CardCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final player = gameState.selectedPlayer;

    if (player == null) {
      return Scaffold(
        backgroundColor: Colors.lightBlue[50],
        appBar: AppBar(
          title: const Text('Card Creation'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: const Center(
          child: Text('No player selected'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text('Card Creation for ${player.name}'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      buildCardCategory(
                          'Narrator Cards - Places',
                          player.cards
                              .where((card) => card.type == CardType.place)
                              .toList()),
                      buildCardCategory(
                          'Narrator Cards - Characters',
                          player.cards
                              .where((card) => card.type == CardType.character)
                              .toList()),
                      buildCardCategory(
                          'Narrator Cards - Obstacles',
                          player.cards
                              .where((card) => card.type == CardType.obstacle)
                              .toList()),
                      buildCardCategory(
                          'Player Cards - Nature',
                          player.cards
                              .where((card) => card.type == CardType.nature)
                              .toList()),
                      buildCardCategory(
                          'Player Cards - Strength',
                          player.cards
                              .where((card) => card.type == CardType.strength)
                              .toList()),
                      buildCardCategory(
                          'Player Cards - Weakness',
                          player.cards
                              .where((card) => card.type == CardType.weakness)
                              .toList()),
                      buildCardCategory(
                          'Player Cards - Subplot',
                          player.cards
                              .where((card) => card.type == CardType.subplot)
                              .toList()),
                      buildCardCategory(
                          'Player Cards - Asset',
                          player.cards
                              .where((card) => card.type == CardType.asset)
                              .toList()),
                      buildCardCategory(
                          'Player Cards - Goal',
                          player.cards
                              .where((card) => card.type == CardType.goal)
                              .toList()),
                      const SizedBox(
                          height:
                              80), // Spacer to ensure scrolling above the button
                    ],
                  ),
                ),
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
                    // Navigate to card creation form (to be implemented)
                    // This form should call gameState.addCardToSelectedPlayer(card)
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

  Widget buildCardCategory(String category, List<CardModel> cards) {
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
          SizedBox(
            height: 150.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return buildCard(cards[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget buildCard(CardModel card) {
    return Container(
      width: 200,
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
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            card.description,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
