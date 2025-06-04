import 'dart:async';
import 'package:ecoDrive/shared/app_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import 'dart:collection';

class BleService {
  // Streams de estado
  static final _bluetoothStateController = StreamController<bool>.broadcast();
  static final _odbConnectionStateController = StreamController<bool>.broadcast();

  static Stream<bool> get bluetoothStateStream => _bluetoothStateController.stream;
  static Stream<bool> get odbConnectionStateStream => _odbConnectionStateController.stream;

  static StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;
  static StreamSubscription<List<ScanResult>>? _scanSubscription;
  static StreamSubscription<BluetoothConnectionState>? _deviceStateSubscription;

  static final List<Map<String, String>> devices = [];
  static final _deviceStreamController = StreamController<List<Map<String, String>>>.broadcast();
  static Stream<List<Map<String, String>>> get deviceStream => _deviceStreamController.stream;

  static final _distanceStreamController = StreamController<double>.broadcast();
  static Stream<double> get distanceStream => _distanceStreamController.stream;

  // Controladores para combustível e velocidade
  static final _fuelStreamController = StreamController<double>.broadcast();
  static Stream<double> get fuelStream => _fuelStreamController.stream;

  static final _fuelRateController = StreamController<double>.broadcast();
  static Stream<double> get fuelRateStream => _fuelRateController.stream;

  static final _speedStreamController = StreamController<double>.broadcast();
  static Stream<double> get speedStream => _speedStreamController.stream;

  static final StreamController<int> _rpmController = StreamController<int>.broadcast();
  static Stream<int> get rpmStream => _rpmController.stream;

  // Estados internos
  static int _lastDistanceTimestamp = DateTime.now().millisecondsSinceEpoch;
  static int _lastFuelTimestamp = DateTime.now().millisecondsSinceEpoch;

  static double _totalDistance = 0.0;
  static double _totalFuelConsumed = 0.0;
  static double _lastSpeed = 0.0;
  static DateTime? _lastSpeedUpdate;
  static String? _lastRequestedPid;
  static double? _lastMAP;
  static double? _lastIAT;
  static int? _lastRPM;
  static final Set<String> _supportedPids = {};

  // Características Bluetooth para comunicação OBD
  static BluetoothCharacteristic? _writeCharacteristic;
  static BluetoothCharacteristic? _notifyCharacteristic;

  // Inicialização Bluetooth e escuta estado
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

  // Escaneamento de dispositivos Bluetooth
  static Future<void> startScanning() async {
    devices.clear();
    _deviceStreamController.add([]);

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        if (!devices.any((d) => d['id'] == r.device.remoteId.toString())) {
          devices.add({
            'id': r.device.remoteId.toString(),
            'name': r.device.name.isEmpty ? 'Dispositivo sem Nome' : r.device.name,
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

  // Conecta ao dispositivo
  static Future<void> connectToDevice(String deviceId) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      await device.connect(autoConnect: false);

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
    _scanSubscription?.cancel();
    _cancelDeviceStateSubscription();

    if (!_bluetoothStateController.isClosed) _bluetoothStateController.close();
    if (!_odbConnectionStateController.isClosed)_odbConnectionStateController.close();
    if (!_deviceStreamController.isClosed)_deviceStreamController.close();
    if (!_distanceStreamController.isClosed)_distanceStreamController.close();
    if (!_fuelStreamController.isClosed)_fuelStreamController.close();
    if (!_fuelRateController.isClosed)_fuelRateController.close();
    if (!_speedStreamController.isClosed)_speedStreamController.close();
    if (!_rpmController.isClosed)_rpmController.close();
  }

  static Future<bool> isBluetoothOn() async {
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  // Configuração do OBD: busca característica notify e write automaticamente
  static Future<void> setupObdCommunication() async {
    final device = AppSettings.connectedDevice;
    if (device == null) return;

    List<BluetoothService> services = await device.discoverServices();

    BluetoothCharacteristic? notifyChar;
    BluetoothCharacteristic? writeChar;

    for (var service in services) {
      print('Serviço encontrado: ${service.uuid}');
      for (var c in service.characteristics) {
        print(' - Característica: ${c.uuid}');
        if (notifyChar == null && c.properties.notify) {
          notifyChar = c;
        }
        if (writeChar == null && (c.properties.write || c.properties.writeWithoutResponse)) {
          writeChar = c;
        }
        if (notifyChar != null && writeChar != null) break;
      }
      if (notifyChar != null && writeChar != null) break;
    }

    if (notifyChar == null || writeChar == null) {
      throw Exception('Não foi possível encontrar características Notify e Write no dispositivo');
    }

    _notifyCharacteristic = notifyChar;
    _writeCharacteristic = writeChar;

    await _notifyCharacteristic!.setNotifyValue(true);
    _notifyCharacteristic!.value.listen(_onDataReceived);

    print('Configuração do OBD concluída. Notify: ${_notifyCharacteristic!.uuid}, Write: ${_writeCharacteristic!.uuid}');

    await checkSupportedPids();
  }

  // Envia comando OBD genérico
  static Future<void> requestPid(String pid) async {
    _lastRequestedPid = pid;
    if (_writeCharacteristic == null) return;
    final command = utf8.encode('$pid\r');
    await _writeCharacteristic!.write(command, withoutResponse: true);
    unawaited(AppSettings.logService?.writeLog('Enviado PID: $pid'));
  }

  //Envio comandos específicos usando o método genérico
  static Future<void> requestRpm() => requestPid('010C');
  static Future<void> requestSpeed() => requestPid('010D');
  static Future<void> requestMAP() => requestPid('010B');
  static Future<void> requestIAT() => requestPid('010F');
  static Future<void> requestFuelRate() => requestPid('015E');
  static Future<void> requestFuelRateViaMAF() => requestPid('0110');

  //Apoio:
  static Future<void> checkSupportedPids() async {
    if (_writeCharacteristic == null) return;

    final completer = Completer<String>();

    late StreamSubscription<List<int>> subscription;

    subscription = _notifyCharacteristic!.value.listen((data) {
      final response = String.fromCharCodes(data).trim();
      if (response.contains('41 00')) {
        completer.complete(response);
      }
    });

    await _notifyCharacteristic!.setNotifyValue(true);

    final command = utf8.encode('0100\r');
    await _writeCharacteristic!.write(command, withoutResponse: true);

    final response = await completer.future.timeout(
        const Duration(seconds: 2), onTimeout: () {
      subscription.cancel();
      return '';
    });

    await subscription.cancel();

    if (response.isEmpty) return;

    _parseSupportedPids(response);
  }

  static Future<void> requestAllObdData() async {
    final Queue<String> pidQueue = Queue<String>();

    // Adiciona os PIDs na ordem desejada
    pidQueue.addAll([
      '010C', // RPM
      '010D', // Speed
      '015E', // Fuel Rate
      '0110', // Fuel Rate via MAF
      '010B', // MAP
      '010F', // IAT
    ]);

    while (pidQueue.isNotEmpty) {
      final pid = pidQueue.removeFirst();
      await requestPid(pid);

      // Delay ajustado conforme a criticidade e tempo de resposta do OBD
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Processamento dos dados  DE SErecebidos
  static String _responseBuffer = '';

  static void _onDataReceived(List<int> data) {
    final responsePart = String.fromCharCodes(data);
    print('Resposta recebida: $responsePart');
    unawaited(AppSettings.logService?.writeLog('Resposta recebida: $responsePart'));

    _responseBuffer += responsePart;

    while (_responseBuffer.contains('\r')) {
      final splitIndex = _responseBuffer.indexOf('\r');
      final line = _responseBuffer.substring(0, splitIndex).trim();
      _responseBuffer = _responseBuffer.substring(splitIndex + 1);

      if (line.isEmpty) continue;

      if (line.contains('NO DATA')) {
        print('PID não suportado ou resposta inválida para $_lastRequestedPid');
        unawaited(AppSettings.logService?.writeLog('PID errante: $_lastRequestedPid'));
        continue;
      }

      AppSettings.logService?.writeLog('Resposta OBD: $line');
      unawaited(AppSettings.logService?.writeLog('Resposta OBD: $line'));

      if (line.contains('41 0C')) {
        final rpm = _parseRpmResponse(line);
        if (rpm != null){
          _rpmController.add(rpm);
          _lastRPM = rpm;
          estimateFuelConsumption();
        }
      } else if (line.contains('41 0D')) {
        final speed = _parseSpeedResponse(line);
        if (speed != null) updateSpeed(speed);
      } else if (line.contains('41 5E') || line.contains('41 66')) {
        final fuelRate = _parseFuelRateResponse(line);
        if (fuelRate != null) {
          updateFuelConsumption(fuelRate);
          _fuelRateController.add(fuelRate);
        }
      } else if (line.contains('41 10')) {
        final fuelRateFromMAF = parseFuelRateFromMAF(line);
        if (fuelRateFromMAF != null) {
          updateFuelConsumption(fuelRateFromMAF);
          _fuelRateController.add(fuelRateFromMAF);
        }
      }else if (line.contains('41 0B')) {
        final map = _parseMAPResponse(line);
        if (map != null){
          _lastMAP = map;
          estimateFuelConsumption();
        }
      } else if (line.contains('41 0F')) {
        final iat = _parseIATResponse(line);
        if (iat != null){
          _lastIAT = iat;
          estimateFuelConsumption();
        }
      }
    }
  }

  // Parsers:
  static void _parseSupportedPids(String response) {
    final clean = response.replaceAll(RegExp(r'[^0-9A-Fa-f ]'), '').trim();
    final bytes = clean.split(' ');

    if (bytes.length < 6) return;

    final supportedBytes = bytes.sublist(2, 6);

    for (int i = 0; i < supportedBytes.length; i++) {
      final byte = int.parse(supportedBytes[i], radix: 16);
      for (int bit = 0; bit < 8; bit++) {
        if ((byte & (1 << (7 - bit))) != 0) {
          final pidNum = i * 8 + bit + 1;
          final pidHex = pidNum.toRadixString(16).padLeft(2, '0').toUpperCase();
          _supportedPids.add('01$pidHex');
        }
      }
    }

    print('PIDs suportados: $_supportedPids');
    unawaited(AppSettings.logService?.writeLog('PIDs suportados: $_supportedPids'));
  }

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

  static double? _parseSpeedResponse(String response) {
    try {
      final clean = response.replaceAll(RegExp(r'[^0-9A-Fa-f ]'), '').trim();
      final bytes = clean.split(' ');
      if (bytes.length >= 3 && bytes[0] == '41' && bytes[1] == '0D') {
        final speed = int.parse(bytes[2], radix: 16);
        print('Velocidade parseada: $speed km/h'); // ← Log adicionado
        unawaited(AppSettings.logService?.writeLog('Linha 299: Velocidade parseada: $speed km/h'));
        return speed.toDouble();
      }
    } catch (_) {}
    return null;
  }

  static double? _parseMAPResponse(String response) {
    try {
      final clean = response.replaceAll(RegExp(r'[^0-9A-Fa-f ]'), '').trim();
      final bytes = clean.split(' ');
      if (bytes.length >= 3 && bytes[0] == '41' && bytes[1] == '0B') {
        return int.parse(bytes[2], radix: 16).toDouble(); // MAP em kPa
      }
    } catch (_) {}
    return null;
  }

  static double? _parseIATResponse(String response) {
    try {
      final clean = response.replaceAll(RegExp(r'[^0-9A-Fa-f ]'), '').trim();
      final bytes = clean.split(' ');
      if (bytes.length >= 3 && bytes[0] == '41' && bytes[1] == '0F') {
        return int.parse(bytes[2], radix: 16).toDouble() - 40; // IAT em °C
      }
    } catch (_) {}
    return null;
  }

  static double? _parseFuelRateResponse(String response) {
    try {
      final clean = response.replaceAll(RegExp(r'[^0-9A-Fa-f ]'), '').trim();
      final bytes = clean.split(' ');
      if (bytes.length >= 4 && bytes[0] == '41' && (bytes[1] == '5E' || bytes[1] == '66')) {
        final A = int.parse(bytes[2], radix: 16);
        final B = int.parse(bytes[3], radix: 16);
        return ((A * 256) + B) / 20.0;
      }
    } catch (_) {}
    return null;
  }

  static double? parseFuelRateFromMAF(String response) {
    try {
      final clean = response.replaceAll(RegExp(r'[^0-9A-Fa-f ]'), '').trim();
      final bytes = clean.split(' ');
      if (bytes.length >= 4 && bytes[0] == '41' && bytes[1] == '10') {
        final A = int.parse(bytes[2], radix: 16);
        final B = int.parse(bytes[3], radix: 16);
        final maf = ((256 * A) + B) / 100.0;
        const afr = 14.7;
        const fuelDensity = 745.0;
        final fuelRateLph = (maf * 3600) / (afr * fuelDensity);
        return fuelRateLph;
      }
    } catch (e) {
      print("Erro ao interpretar a resposta do MAF: $e");
      unawaited(AppSettings.logService?.writeLog('Erro ao interpretar a resposta do MAF: $e'));
    }
    return null;
  }

  // Atualizações: DistÂncia, velocidade e combustível
  static void updateDistance(double currentSpeed) {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final timeElapsed = (currentTimestamp - _lastDistanceTimestamp) / 3600000.0; // em horas

    if (_lastSpeed > 0 && timeElapsed > 0) {
      final distanceDelta = _lastSpeed * timeElapsed;
      _totalDistance += distanceDelta;
      _distanceStreamController.add(_totalDistance);
      unawaited(AppSettings.logService?.writeLog('Linha 316: Distância acumulada: $_totalDistance km'));
    }

    _lastDistanceTimestamp = currentTimestamp;
    _lastSpeed = currentSpeed;
  }

  static void updateSpeed(double speed) {
    _lastSpeed = speed;
    _speedStreamController.add(speed);
    unawaited(AppSettings.logService?.writeLog('Linha 326: Velocidade atual: $speed km/h'));
    updateDistance(speed);
  }

  static void updateFuelConsumption(double fuelRate) {
    // final now = DateTime.now().millisecondsSinceEpoch;
    // final deltaTime = (now - _lastFuelTimestamp) / 3600000.0; // horas
    //
    // if (deltaTime > 0) {
    //   final fuelUsed = fuelRate * deltaTime;
    //   _totalFuelConsumed += fuelUsed;
    //   _fuelStreamController.add(_totalFuelConsumed);
    //   unawaited(AppSettings.logService?.writeLog('Linha 338: Combustível consumido: $_totalFuelConsumed litros'));
    // }
    //
    // _lastFuelTimestamp = now;
    _fuelStreamController.add(fuelRate);
  }

  static void estimateFuelConsumption() {

    if (_lastMAP != null && _lastIAT != null && _lastRPM != null) {
      const ve = 0.85; // Eficiência volumétrica estimada
      const engineDisplacement = 1.6; // em Litros
      const R = 8.314; // Constante dos gases
      const afr = 14.7;
      const fuelDensity = 745.0;

      final map = _lastMAP!; // kPa
      final iat = _lastIAT!; // °C
      final rpm = _lastRPM!; // RPM

      final maf = (rpm * map * engineDisplacement * ve) / (R * (iat + 273.15));

      // Conversão para taxa de combustível
      final fuelRateLph = (maf * 3600) / (afr * fuelDensity);
      print("FuelRateLph: $fuelRateLph");
      updateFuelConsumption(fuelRateLph);
      _fuelRateController.add(fuelRateLph);
    }
    print("Tem alguma variável vazia: MAP:$_lastMAP IAT:$_lastIAT RPM: $_lastRPM");
  }

  static void reset() {
    _totalDistance = 0.0;
    _totalFuelConsumed = 0.0;
    _lastSpeed = 0.0;
    _lastFuelTimestamp = DateTime.now().millisecondsSinceEpoch;
    _distanceStreamController.add(0.0);
    _fuelStreamController.add(0.0);
    _rpmController.add(0);
  }
}