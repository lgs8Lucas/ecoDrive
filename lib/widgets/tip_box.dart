import 'package:flutter/material.dart';

class TipCard extends StatelessWidget {
  final String titulo;
  final String mensagem;
  final String tipType; // "good" ou "bad"

  const TipCard({
    Key? key,
    required this.titulo,
    required this.mensagem,
    required this.tipType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color iconColor;

    IconData iconData;

    if (tipType == "good") {
      backgroundColor = Colors.green.shade100;
      iconColor = Colors.green.shade700;
      iconData = Icons.check_circle_outline_rounded;
    } else {
      backgroundColor = Colors.amber.shade100;
      iconColor = Colors.amber.shade800;
      iconData = Icons.warning_amber_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mensagem,
                  style: TextStyle(
                    fontSize: 14,
                    color: iconColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
