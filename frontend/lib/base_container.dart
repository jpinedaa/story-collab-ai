import 'package:flutter/material.dart';

class BaseContainer extends StatelessWidget {
  final String title;
  final String content;
  final TextStyle? contentStyle;
  final bool isCentered;

  const BaseContainer({
    super.key,
    required this.title,
    required this.content,
    this.contentStyle,
    this.isCentered = false,
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
      child: Column(
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
    );
  }
}
