import 'package:flutter/material.dart';
import 'card_state.dart';
import 'card_detail_dialog.dart';

class MiniCard extends StatelessWidget {
  final CardModel card;

  const MiniCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
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
            return CardDetailDialog(
                card: card, showEditDelete: false); // Add showEditDelete: false
          },
        );
      },
      child: Container(
        width: 200, // Set a fixed width
        height: 180, // Set a fixed height
        padding: const EdgeInsets.all(8.0),
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
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4.0),
            if (card.imageBytes != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                height: 100,
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.memory(card.imageBytes!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 8.0),
            ],
            Text(
              card.description,
              style: const TextStyle(fontSize: 12.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
