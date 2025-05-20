import 'dart:ui';
import 'package:ecoDrive/services/ble_service.dart';
import 'package:flutter/material.dart';

import '../shared/app_styles.dart';

class BluetoothDevicesListWidget extends StatefulWidget {
  const BluetoothDevicesListWidget({super.key});

  @override
  _BluetoothDevicesListWidgetState createState() => _BluetoothDevicesListWidgetState();
}

class _BluetoothDevicesListWidgetState extends State<BluetoothDevicesListWidget> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  Future<void> _startScanning() async {
    setState(() {
      _isLoading = true; // Inicia o estado de carregamento
    });

    await BleService.startScanning();

    setState(() {
      _isLoading = false; // Finaliza o estado de carregamento
    });
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
                    const SizedBox(height: 20),
                    const Text(
                      'Escolha o seu ODB-II',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null // Desativa o botão enquanto está carregando
                          : () => _startScanning(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.search, size: 24),
                      label: Text(
                        _isLoading ? "Buscando..." : "Buscar Dispositivos",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 300,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator()) // Exibe carregamento
                          : StreamBuilder<List<Map<String, String>>>(
                        stream: BleService.deviceStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text("Erro ao carregar dispositivos"),
                            );
                          }

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
