import 'dart:ui';
import 'package:flutter/material.dart';

import '../shared/app_styles.dart';

class BluetoothDevicesListWidget extends StatelessWidget {
  const BluetoothDevicesListWidget({super.key});

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
                      'Escolha o seu ODB-II',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 300,
                      child: ListView(
                        children: const <Widget>[
                          ListTile(
                            title: Text('ODB-II'),
                            subtitle: Text('MAC: '),
                          ),
                          Divider(height: 0),
                          ListTile(
                            title: Text('QCY-T13'),
                            subtitle: Text('MAC: '),
                          ),
                          Divider(height: 0),
                        ],
                      ),
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
