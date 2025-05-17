import 'dart:async';

import 'package:ecoDrive/shared/app_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService{
  const BleService();
  static StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;

  static void startMonitoringBluetoothStatus() {
    // Escutando o estado do adaptador Bluetooth
    _bluetoothStateSubscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        AppSettings.bluetoothIsEnabled = true;
      } else {
        AppSettings.bluetoothIsEnabled = false;
      }
    });
  }

  static void stopMonitoringBluetoothStatus() {
    // Cancelando a assinatura quando não for mais necessário
    _bluetoothStateSubscription?.cancel();
  }

  static Future<void> connectedToODB() async {
    try{
      if (!AppSettings.bluetoothIsEnabled){
        AppSettings.odbIsConnected = false;
        // Se o Bluetooth não estiver habilitado, não faz nada
        return;
      }
      // Verifica dispositivos conectados atualmente
      List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
      print(connectedDevices);
      for (var device in connectedDevices){
        if (device.name.toLowerCase().contains("obd") || device.name.toLowerCase().contains("obd2")){
          print("Dispositivo OBD encontrado: ${device.name}");
          AppSettings.odbIsConnected = true;
          return;
        }
      }
    } catch (e) {
      print(e);
    }
  }

}