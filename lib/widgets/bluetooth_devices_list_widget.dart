import 'dart:ui';
import 'package:ecoDrive/services/ble_service.dart';
import 'package:flutter/material.dart';

import '../shared/app_styles.dart';

class BluetoothDevicesListWidget extends StatefulWidget {
  const BluetoothDevicesListWidget({super.key});

  @override
  _BluetoothDevicesListWidgetState createState() =>
      _BluetoothDevicesListWidgetState();
}

class _BluetoothDevicesListWidgetState
    extends State<BluetoothDevicesListWidget> {
  @override
  void initState() {
    super.initState();
    BleService.startScanning();
  }

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
                      child: StreamBuilder<List<Map<String, String>>>(
                        stream: BleService.deviceStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return const Center(
                              child: Text("Erro ao carregar dispositivos"),
                            );
                          }

                          // Também trate ConnectionState.none e ConnectionState.active normalmente
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text("Nenhum dispositivo encontrado"),
                            );
                          }

                          final devices = snapshot.data!;

                          return ListView.builder(
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              final device = devices[index];
                              final deviceName =
                                  (device["name"]?.isNotEmpty ?? false)
                                      ? device["name"]!
                                      : 'Dispositivo sem Nome';
                              final deviceId =
                                  device["id"] ?? 'ID desconhecido';

                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(deviceName),
                                    subtitle: Text(deviceId),
                                  ),
                                  const Divider(height: 0),
                                ],
                              );
                            },
                          );
                        },
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
