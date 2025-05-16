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
}