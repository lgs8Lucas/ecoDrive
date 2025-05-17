// faq_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import '../shared/app_styles.dart';

class FAQDialog extends StatelessWidget {
  const FAQDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          // Fundo com blur e container com conteúdo
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Instruções de Uso',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '1. Garanta que seu dispositivo ODB-II esteja conectado ao seu veículo e que ambos estejam operantes\n'
                      '2. Conecte-se ao dispositivo ODB-II através do bluetooth do seu smartphone'
                      '3. Acompanhe suas métricas de emissão de CO₂.\n'
                      '4. Explore dicas para dirigir de forma mais sustentável.\n\n'
                      'Esse app visa ajudar você a ser mais ecológico no trânsito!',
                      style: AppStyles.simpleText,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botão de fechar
          Positioned(
            right: 10,
            top: 10,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const CircleAvatar(
                backgroundColor: Colors.red,
                radius: 16,
                child: Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
