import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/ble_service.dart';
import '../shared/app_styles.dart';

class BluetoothDevicesListWidget extends StatefulWidget {
  const BluetoothDevicesListWidget({super.key});

  @override
  State<BluetoothDevicesListWidget> createState() =>
      _BluetoothDevicesListWidgetState();
}

class _BluetoothDevicesListWidgetState
    extends State<BluetoothDevicesListWidget> {
  bool _filterOnlyOdb = false;

  @override
  void initState() {
    super.initState();
    BleService.startScanning();
  }

  @override
  void dispose() {
    BleService.stopScanning();
    super.dispose();
  }

  void _refreshScan() {
    BleService.startScanning();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 460),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    // Cabeçalho com título, botão refresh e filtro
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Dispositivos Bluetooth',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.blue),
                          tooltip: 'Recarregar',
                          onPressed: _refreshScan,
                        ),
                      ],
                    ),
                    // Switch para filtrar só ODB
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Mostrar só ODB'),
                        Switch(
                          value: _filterOnlyOdb,
                          onChanged: (value) {
                            setState(() {
                              _filterOnlyOdb = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: StreamBuilder<List<Map<String, String>>>(
                        stream: BleService.deviceStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('Nenhum dispositivo encontrado'),
                            );
                          }
                          var devices = List<Map<String, String>>.from(
                            snapshot.data!,
                          );

                          // Aplica filtro ODB se ligado
                          if (_filterOnlyOdb) {
                            devices =
                                devices.where((device) {
                                  final name =
                                      (device['name'] ?? '').toLowerCase();
                                  return name.contains('odb') ||
                                      name.contains('obd');
                                }).toList();
                          }

                          devices.sort((a, b) {
                            final nameA = a['name'] ?? '';
                            final nameB = b['name'] ?? '';

                            bool isAValid =
                                nameA.isNotEmpty &&
                                nameA != 'Dispositivo sem Nome';
                            bool isBValid =
                                nameB.isNotEmpty &&
                                nameB != 'Dispositivo sem Nome';

                            if (isAValid && !isBValid) return -1;
                            if (!isAValid && isBValid) return 1;
                            return 0;
                          });

                          if (devices.isEmpty) {
                            return const Center(
                              child: Text('Nenhum dispositivo encontrado'),
                            );
                          }

                          return ListView.separated(
                            itemCount: devices.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final device = devices[index];
                              return ListTile(
                                title: Text(
                                  device['name'] ?? 'Dispositivo sem nome',
                                ),
                                subtitle: Text(device['id'] ?? ''),
                                leading: const Icon(Icons.bluetooth),
                                onTap: () async {
                                  try {
                                    // Tenta conectar ao dispositivo
                                    await BleService.connectToDevice(
                                      device['id']!,
                                    );
                                    // Fecha o diálogo após a conexão
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    // Exibe um alerta em caso de erro
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            title: const Text('Erro'),
                                            content: Text(
                                              'Falha ao conectar ao dispositivo: $e',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                    );
                                  }
                                },
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
