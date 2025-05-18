import 'package:flutter/material.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:ecoDrive/shared/app_styles.dart';
import 'package:ecoDrive/services/ble_service.dart';

class BluetoothStatusWidget extends StatefulWidget {
  const BluetoothStatusWidget({Key? key}) : super(key: key);

  @override
  _BluetoothStatusWidgetState createState() => _BluetoothStatusWidgetState();
}

class _BluetoothStatusWidgetState extends State<BluetoothStatusWidget> {
  bool _bluetoothEnabled = false;
  bool _odbConnected = false;

  void handleSearchODB() {
    if (_bluetoothEnabled) {
      BleService.startScanning(targetDeviceName: "OBD");
    } else {
      // Opcional: mostrar alerta que bluetooth está desligado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth está desligado')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    BleService.initialize();

    BleService.bluetoothStateStream.listen((enabled) {
      setState(() {
        _bluetoothEnabled = enabled;
      });

      // Opcional: iniciar scan automaticamente quando Bluetooth ativar
      if (enabled && !_odbConnected) {
        handleSearchODB();
      }
    });

    BleService.odbConnectionStateStream.listen((connected) {
      setState(() {
        _odbConnected = connected;
      });
    });

    // Busca inicial (se já estiver ligado)
    if (_bluetoothEnabled) {
      handleSearchODB();
    }
  }

  @override
  void dispose() {
    BleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool connection = _bluetoothEnabled && _odbConnected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.colorAlterBackground,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "Bluetooth: ", style: AppStyles.simpleText),
                    TextSpan(
                      text: _bluetoothEnabled ? "Ativo" : "Inativo",
                      style: TextStyle(
                        color: _bluetoothEnabled
                            ? AppColors.colorMain
                            : AppColors.colorError,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "OBD: ", style: AppStyles.simpleText),
                        TextSpan(
                          text: _odbConnected ? "Conectado" : "Desconectado",
                          style: TextStyle(
                            color: _odbConnected
                                ? AppColors.colorMain
                                : AppColors.colorError,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.colorBlack.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: GestureDetector(
                      onTap: handleSearchODB,
                      child: Icon(
                        Icons.bluetooth_searching, // Ícone mais adequado para conexão
                        size: 18,
                        color: AppColors.colorBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: connection ? AppColors.colorMain : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              connection ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
