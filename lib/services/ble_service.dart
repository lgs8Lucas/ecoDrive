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
  static StreamSubscription<List<ScanResult>>? _scanSubscription;
  static StreamSubscription<BluetoothConnectionState>? _deviceStateSubscription;

  static final List<Map<String, String>> devices = [];

  static final StreamController<List<Map<String, String>>>
  _deviceStreamController =
      StreamController<List<Map<String, String>>>.broadcast();

  static Stream<List<Map<String, String>>> get deviceStream =>
      _deviceStreamController.stream;

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
        if (!devices.any(
          (device) => device['id'] == r.device.remoteId.toString(),
        )) {
          devices.add({
            'id': r.device.remoteId.toString(),
            'name':
                r.device.name.isEmpty ? 'Dispositivo sem Nome' : r.device.name,
          });
          _deviceStreamController.add(List<Map<String, String>>.from(devices));
        }
      }
    });

    await Future.delayed(const Duration(seconds: 5));

    await _scanSubscription?.cancel();
    _scanSubscription = null;

    FlutterBluePlus.stopScan();
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

  static Future<void> connectToDevice(String deviceId) async {
    try {
      // Obtem o dispositivo com base no ID fornecido
      final device = BluetoothDevice.fromId(deviceId);

      // Conecta ao dispositivo
      await device.connect(autoConnect: false);

      // Atualiza o estado da conexão
      _deviceStateSubscription = device.connectionState.listen((state) async {
        final isConnected = state == BluetoothConnectionState.connected;
        _odbConnectionStateController.add(isConnected);

        if (!isConnected) {
          _cancelDeviceStateSubscription();
          AppSettings.connectedDevice = null;
        } else {
          AppSettings.connectedDevice = device;
          AppSettings.odbIsConnected = true;
          print("Conectado ao dispositivo ODB-II: ${device.name}");
          // Configura comunicação OBD
          await setupObdCommunication();
        }
      });
    } catch (e) {
      _odbConnectionStateController.add(false);

      rethrow;
    }
  }

  static void dispose() {
    _bluetoothStateSubscription?.cancel();
    stopScanning();
    _cancelDeviceStateSubscription();
    _bluetoothStateController.close();
    _odbConnectionStateController.close();
    _rpmController.close();
  }

  static Future<bool> isBluetoothOn() async {
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  // For ODB
  static BluetoothCharacteristic? _writeCharacteristic;
  static BluetoothCharacteristic? _notifyCharacteristic;

  static final StreamController<int> _rpmController =
      StreamController<int>.broadcast();

  static Stream<int> get rpmStream =>
      _rpmController.stream; // Stream para coleta do RPM

  static final Guid serviceUUID = Guid(
    '0000fff0-0000-1000-8000-00805f9b34fb',
  ); // Info pega do próprio OBD
  static final Guid notifyUUID = Guid('0000fff1-0000-1000-8000-00805f9b34fb');
  static final Guid writeUUID = Guid('0000fff2-0000-1000-8000-00805f9b34fb');

  // Notificações do ODB
  static Future<void> setupObdCommunication() async {
    final device = AppSettings.connectedDevice;
    if (device == null) return;

    List<BluetoothService> services = await device.discoverServices();

    final obdService = services.firstWhere(
      (s) => s.uuid == serviceUUID,
      orElse: () => throw Exception('Serviço OBD não encontrado'),
    );

    _notifyCharacteristic = obdService.characteristics.firstWhere(
      (c) => c.uuid == notifyUUID,
    );
    _writeCharacteristic = obdService.characteristics.firstWhere(
      (c) => c.uuid == writeUUID,
    );

    await _notifyCharacteristic!.setNotifyValue(true);

    _notifyCharacteristic!.value.listen(_onDataReceived);
  }

  // ENviando comandos ao RPM
  static Future<void> requestRpm() async {
    if (_writeCharacteristic == null) return;

    final command = '010C\r'.codeUnits;
    await _writeCharacteristic!.write(command, withoutResponse: true);
  }

  static void _onDataReceived(List<int> data) {
    final response = String.fromCharCodes(data);
    // Limpar resposta e tentar extrair RPM
    final rpm = _parseRpmResponse(response);
    if (rpm != null) {
      _rpmController.add(rpm);
    }
  }

  // Traduzir a resposta
  static int? _parseRpmResponse(String response) {
    try {
      final clean = response.replaceAll(RegExp(r'[^0-9A-Fa-f ]'), '').trim();
      final bytes = clean.split(' ');

      if (bytes.length >= 4 && bytes[0] == '41' && bytes[1] == '0C') {
        final A = int.parse(bytes[2], radix: 16);
        final B = int.parse(bytes[3], radix: 16);
        return ((A * 256) + B) ~/ 4;
      }
    } catch (_) {}
    return null;
  }

}
