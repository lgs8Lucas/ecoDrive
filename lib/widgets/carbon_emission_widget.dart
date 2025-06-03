import 'package:flutter/material.dart';

class EmissaoCarbonoCard extends StatelessWidget {
  final String valor;
  final String unidade;
  final String status; // "good", "medium" ou "bad"

  const EmissaoCarbonoCard({
    Key? key,
    required this.valor,
    required this.unidade,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color iconColor;
    IconData iconData = Icons.eco;

    switch (status) {
      case "good":
        backgroundColor = Colors.green.shade100;
        iconColor = Colors.green.shade700;
        break;
      case "medium":
        backgroundColor = Colors.amber.shade100;
        iconColor = Colors.amber.shade700;
        break;
      case "bad":
        backgroundColor = Colors.red.shade100;
        iconColor = Colors.red.shade700;
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        iconColor = Colors.grey.shade600;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Texto à esquerda
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Emissão de carbono",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                "$valor $unidade",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Ícone à direita
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
