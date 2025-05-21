import 'dart:async';
import 'package:ecoDrive/shared/app_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static final _bluetoothStateController = StreamController<bool>.broadcast();
  static final _odbConnectionStateController = StreamController<bool>.broadcast();

  static Stream<bool> get bluetoothStateStream => _bluetoothStateController.stream;
  static Stream<bool> get odbConnectionStateStream => _odbConnectionStateController.stream;

  static StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;
  static StreamSubscription<List<ScanResult>>? _scanSubscription;
  static StreamSubscription<BluetoothConnectionState>? _deviceStateSubscription;

  static final List<Map<String, String>> devices = [];

  static final StreamController<List<Map<String, String>>> _deviceStreamController =
  StreamController<List<Map<String, String>>>.broadcast();

  static Stream<List<Map<String, String>>> get deviceStream => _deviceStreamController.stream;

  static void initialize() {
    _bluetoothStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      bool isEnabled = state == BluetoothAdapterState.on;
      _bluetoothStateController.add(isEnabled);

      if (!isEnabled) {
        _odbConnectionStateController.add(false);
        _cancelDeviceStateSubscription();
        AppSettings.connectedDevice = null;
      }
    });
  }

  static Future<void> startScanning() async {
    devices.clear();
    _deviceStreamController.add([]);

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devices.any((device) => device['id'] == r.device.remoteId.toString())) {
          devices.add({
            'id': r.device.remoteId.toString(),
            'name': r.device.name.isEmpty ? 'Dispositivo sem Nome' : r.device.name,
          });

          _deviceStreamController.add(List<Map<String, String>>.from(devices));
        }
      }
    });

    // Aguarda um tempo extra para garantir que dispositivos foram escaneados
    await Future.delayed(const Duration(seconds: 6));

    await _scanSubscription?.cancel();
    _scanSubscription = null;

    FlutterBluePlus.stopScan();

    // Emissão final para garantir que o StreamBuilder veja os dados
    _deviceStreamController.add(List<Map<String, String>>.from(devices));
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
    _deviceStreamController.close();
  }

  static Future<bool> isBluetoothOn() async {
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }
}
