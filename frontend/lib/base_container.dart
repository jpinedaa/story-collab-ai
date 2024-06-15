import 'package:flutter/material.dart';
import 'mini_card.dart';
import 'card_state.dart';

class BaseContainer extends StatelessWidget {
  final String title;
  final String content;
  final TextStyle? contentStyle;
  final bool isCentered;
  final Widget? child;
  final CardModel? placeCard;
  final List<CardModel> selectedCards; // Add this line
  final VoidCallback? onDelete;

  const BaseContainer({
    super.key,
    required this.title,
    required this.content,
    this.contentStyle,
    this.isCentered = false,
    this.child,
    this.placeCard,
    this.selectedCards = const [],
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (placeCard != null || selectedCards.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (placeCard != null) ...[
                          const SizedBox(height: 8.0),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Column(
                              children: [
                                MiniCard(card: placeCard!),
                                const SizedBox(height: 4.0),
                                const Text(
                                  "Place",
                                  style: TextStyle(fontSize: 12.0),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        ],
                        if (selectedCards.isNotEmpty) ...[
                          ...selectedCards.map<Widget>((card) {
                            String label = '';
                            if (card.type == CardType.Obstacle ||
                                card.type == CardType.Character) {
                              label = 'Challenge';
                            } else {
                              label = 'Pickup - ${card.type.name}';
                            }
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Column(
                                children: [
                                  MiniCard(card: card),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    label,
                                    style: const TextStyle(fontSize: 12.0),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ))
              ],
              const SizedBox(height: 8.0),
              Text(
                content,
                style: contentStyle ??
                    const TextStyle(
                      fontSize: 16.0,
                    ),
                textAlign: isCentered ? TextAlign.center : TextAlign.start,
              ),
            ],
          ),
          if (child != null || onDelete != null)
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (child != null) child!,
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
