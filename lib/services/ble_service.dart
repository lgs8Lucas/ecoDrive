import 'dart:async';
import 'package:ecoDrive/shared/app_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static final _bluetoothStateController = StreamController<bool>.broadcast();
  static final _odbConnectionStateController = StreamController<bool>.broadcast();

  static Stream<bool> get bluetoothStateStream => _bluetoothStateController.stream;
  static Stream<bool> get odbConnectionStateStream => _odbConnectionStateController.stream;

  static StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;
  static StreamSubscription<ScanResult>? _scanSubscription;
  static StreamSubscription<BluetoothConnectionState>? _deviceStateSubscription;

  static void initialize() {
    // Escuta o estado do adaptador Bluetooth
    _bluetoothStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      bool isEnabled = state == BluetoothAdapterState.on;
      _bluetoothStateController.add(isEnabled);

      // Se Bluetooth desligar, desconecta OBD
      if (!isEnabled) {
        _odbConnectionStateController.add(false);
        _cancelDeviceStateSubscription();
        AppSettings.connectedDevice = null;
      }
    });
  }

  static void startScanning({required String targetDeviceName}) {
    if (_scanSubscription != null) return;

    _scanSubscription = FlutterBluePlus.scan().listen((ScanResult result) async {
      if (result.device.name.toLowerCase().contains(targetDeviceName.toLowerCase())) {
        stopScanning();

        try {
          // Conecta com timeout
          await result.device.connect(timeout: Duration(seconds: 10));
          AppSettings.connectedDevice = result.device;

          _odbConnectionStateController.add(true);

          // Escuta mudanças no estado do dispositivo (conectado/desconectado)
          _cancelDeviceStateSubscription();
          _deviceStateSubscription = result.device.state.listen((deviceState) {
            if (deviceState == BluetoothDeviceState.disconnected) {
              _odbConnectionStateController.add(false);
              AppSettings.connectedDevice = null;
              _cancelDeviceStateSubscription();
            }
          });
        } catch (e) {
          print("Erro ao conectar: $e");
          _odbConnectionStateController.add(false);
          AppSettings.connectedDevice = null;
        }
      }
    }, onError: (e) {
      print("Erro na varredura: $e");
      stopScanning();
    });
  }

  static void stopScanning() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  static void _cancelDeviceStateSubscription() {
    _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;
  }

  static void dispose() {
    _bluetoothStateSubscription?.cancel();
    stopScanning();
    _cancelDeviceStateSubscription();
    _bluetoothStateController.close();
    _odbConnectionStateController.close();
  }
}
