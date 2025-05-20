import 'dart:async';
import 'package:ecoDrive/shared/app_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static final _bluetoothStateController = StreamController<bool>.broadcast();
  static final _odbConnectionStateController =
      StreamController<bool>.broadcast();

  static Stream<bool> get bluetoothStateStream =>
      _bluetoothStateController.stream;

  static Stream<bool> get odbConnectionStateStream =>
      _odbConnectionStateController.stream;

  static StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;
  static StreamSubscription<ScanResult>? _scanSubscription;
  static StreamSubscription<BluetoothConnectionState>? _deviceStateSubscription;

  static final List<Map<String, String>> devices = [];

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

  static Future<void> startScanning() async {
    // Limpa a lista de dispositivos encontrados
    devices.clear();

    // Inicia a varredura
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Inscreve-se nos resultados da varredura
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // Verifica se o dispositivo já está na lista
        if (!devices.any(
          (device) => device['id'] == r.device.remoteId.toString(),
        )) {
          devices.add({
            'id': r.device.remoteId.toString(),
            'name':
                r.device.name.isEmpty ? 'Dispositivo sem Nome' : r.device.name,
          });
        }
      }
    });

    // Aguarda o término da varredura e cancela a inscrição
    await Future.delayed(const Duration(seconds: 5));
    await subscription.cancel();

    // Para a varredura explicitamente
    FlutterBluePlus.stopScan();
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

  static Future<bool> isBluetoothOn() async {
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }
}
