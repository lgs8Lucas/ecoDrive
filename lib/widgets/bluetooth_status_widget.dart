import 'package:ecoDrive/shared/app_settings.dart';
import 'package:ecoDrive/shared/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ecoDrive/shared/app_colors.dart';

class BluetoothStatusWidget extends StatelessWidget {
  const BluetoothStatusWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothAdapterState>(
      stream: FlutterBluePlus.adapterState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        AppSettings.bluetoothIsEnabled = state == BluetoothAdapterState.on;
        bool connection = AppSettings.bluetoothIsEnabled && AppSettings.odbIsConnected;


        return Container(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.colorAlterBackground,
              borderRadius: BorderRadius.circular(40), // Define o raio da borda
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
                            TextSpan(
                              text: "Bluetooth: ",
                              style: AppStyles.simpleText,
                            ),
                            TextSpan(
                              text: AppSettings.bluetoothIsEnabled ? "Ativo" : "Inativo",
                              style: TextStyle(
                                color: AppSettings.bluetoothIsEnabled ? AppColors.colorMain : AppColors.colorError,
                                fontSize: 18
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "ODB: ",
                              style: AppStyles.simpleText,
                            ),
                            TextSpan(
                              text: AppSettings.odbIsConnected ? "Conectado ao..." : "Desconectado",
                              style: TextStyle(
                                  color: AppSettings.odbIsConnected ? AppColors.colorMain : AppColors.colorError,
                                  fontSize: 18
                              ),
                            ),
                          ],
                        ),
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
                  )
                ]
            )
        );
      },
    );
  }
}
