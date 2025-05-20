import 'package:ecoDrive/widgets/bluetooth_devices_list_widget.dart';
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
  void _showDevices(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => const BluetoothDevicesListWidget(),
    );
  }

  bool _bluetoothEnabled = false;
  bool _odbConnected = false;

  @override
  void initState() {
    super.initState();
    BleService.initialize();

    BleService.bluetoothStateStream.listen((enabled) {
      setState(() {
        _bluetoothEnabled = enabled;
      });
    });

    BleService.odbConnectionStateStream.listen((connected) {
      setState(() {
        _odbConnected = connected;
      });
    });
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
          // Coluna com textos Bluetooth e OBD
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
                        color: _bluetoothEnabled ? AppColors.colorMain : AppColors.colorError,
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
                    Text(
                      "ODB: ",
                      style: AppStyles.simpleText,
                    ),
                    GestureDetector(
                      onTap: () => _showDevices(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.colorBlack.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _odbConnected ? "Conectado" : "Desconectado",
                              style: TextStyle(
                                color: _odbConnected ? AppColors.colorMain : AppColors.colorError,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.bluetooth_searching,
                              size: 20,
                              color: _odbConnected ? AppColors.colorMain : AppColors.colorError,
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ],
          ),
          // Indicador circular do status da conexão
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
