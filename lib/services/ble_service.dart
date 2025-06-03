import 'dart:async';
import 'package:ecoDrive/shared/app_settings.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

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

  static final _distanceStreamController = StreamController<double>.broadcast();

  static Stream<double> get distanceStream => _distanceStreamController.stream;
  static int _lastDistanceTimestamp = DateTime.now().millisecondsSinceEpoch;

  static int _lastFuelTimestamp =
      DateTime.now()
          .millisecondsSinceEpoch; // Timestamp do último consumo de combustível
  static final _fuelLevelController =
      StreamController<
        double
      >.broadcast(); // Stream para o nível de combustível
  static Stream<double> get fuelLevelStream =>
      _fuelLevelController.stream; // Stream para o nível de combustível
  static final _fuelStreamController =
      StreamController<
        double
      >.broadcast(); // Stream para o consumo de combustível
  static Stream<double> get fuelStream =>
      _fuelStreamController.stream; // Stream para o consumo de combustível

  static final StreamController<double> _fuelRateController =
      StreamController<
        double
      >.broadcast(); // controlador para o consumo instantâneo de combustível
  static Stream<double> get fuelRateStream =>
      _fuelRateController
          .stream; // Stream para o consumo instantâneo de combustível

  static final StreamController<double> _speedStreamController =
      StreamController.broadcast();

  static Stream<double> get speedStream => _speedStreamController.stream;

  static double _totalDistance = 0.0; // Distância acumulada em km
  static double _totalFuelConsumed =
      0.0; // Total de combustível consumido em litros
  static double _lastSpeed = 0.0; // Última velocidade registrada (em km/h)
  static DateTime? _lastSpeedUpdate;

  // Inicializar o Bluetooth
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

  // Iniciar a escaneamento
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

  // Parar a escaneamento
  static void stopScanning() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  // Cancelar a inscrição do estado do dispositivo
  static void _cancelDeviceStateSubscription() {
    _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;
  }

  // Conecta ao dispositivo
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

  // Desconecta do dispositivo
  static void dispose() {
    _bluetoothStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _cancelDeviceStateSubscription();

    _bluetoothStateController.close();
    _odbConnectionStateController.close();
    _rpmController.close();
    _fuelStreamController.close();
    _distanceStreamController.close();
    _fuelLevelController.close();
    _fuelRateController.close();
    _speedStreamController.close();
  }

  // Verificar se o Bluetooth está ligado
  static Future<bool> isBluetoothOn() async {
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  // For ODB
  static BluetoothCharacteristic? _writeCharacteristic;
  static BluetoothCharacteristic? _notifyCharacteristic;

  static final StreamController<int> _rpmController =
      StreamController<int>.broadcast();

  // Stream para coleta do RPM
  static Stream<int> get rpmStream =>
      _rpmController.stream; // Stream para coleta do RPM

  // // UUIDs do serviço e características OBD (definidos pelo dispositivo)
  // static final Guid serviceUUID = Guid(
  //   '0000fff0-0000-1000-8000-00805f9b34fb',
  // ); // Serviço OBD-II
  // static final Guid notifyUUID = Guid('0000fff1-0000-1000-8000-00805f9b34fb');
  // static final Guid writeUUID = Guid('0000fff2-0000-1000-8000-00805f9b34fb');
  //
  // // Configura a comunicação com o dispositivo OBD (descobre serviços e características)
  // static Future<void> setupObdCommunication() async {
  //   final device = AppSettings.connectedDevice;
  //   if (device == null) return; // Se não há dispositivo conectado, retorna
  //
  //   // Descobre serviços oferecidos pelo dispositivo
  //   List<BluetoothService> services = await device.discoverServices();
  //
  //   // Busca serviço OBD pelo UUID
  //   final obdService = services.firstWhere(
  //         (s) => s.uuid == serviceUUID,
  //     orElse: () => throw Exception('Serviço OBD não encontrado'),
  //   );
  //
  //   // Busca características de notificação e escrita dentro do serviço
  //   _notifyCharacteristic = obdService.characteristics.firstWhere(
  //         (c) => c.uuid == notifyUUID,
  //   );
  //   _writeCharacteristic = obdService.characteristics.firstWhere(
  //         (c) => c.uuid == writeUUID,
  //   );
  //
  //   // Ativa notificações para receber dados do dispositivo
  //   await _notifyCharacteristic!.setNotifyValue(true);
  //
  //   // Escuta os dados recebidos via notificação
  //   _notifyCharacteristic!.value.listen(_onDataReceived);
  // }

  // Setup OBD buscando UUIDs automaticamente
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

        // Procura característica com notify
        if (notifyChar == null && c.properties.notify) {
          notifyChar = c;
        }

        // Procura característica com write ou writeWithoutResponse
        if (writeChar == null &&
            (c.properties.write || c.properties.writeWithoutResponse)) {
          writeChar = c;
        }

        if (notifyChar != null && writeChar != null) break;
      }
      if (notifyChar != null && writeChar != null) break;
    }

    if (notifyChar == null || writeChar == null) {
      throw Exception(
        'Não foi possível encontrar características Notify e Write no dispositivo',
      );
    }

    _notifyCharacteristic = notifyChar;
    _writeCharacteristic = writeChar;

    await _notifyCharacteristic!.setNotifyValue(true);
    _notifyCharacteristic!.value.listen(_onDataReceived);

    print(
      'Configuração do OBD concluída. Notify: ${_notifyCharacteristic!.uuid}, Write: ${_writeCharacteristic!.uuid}',
    );
  }

  // Enviando comandos ao RPM
  static Future<void> requestRpm() async {
    if (_writeCharacteristic == null) return;

    final command = '010C\r'.codeUnits;
    await _writeCharacteristic!.write(command, withoutResponse: true);
  }

  // Recebendo dados
  static void _onDataReceived(List<int> data) {
    final response = String.fromCharCodes(data);
    unawaited(AppSettings.logService?.writeLog('Resposta OBD: $response')); // Log da resposta recebida);

    // Extraia o RPM ou Velocidade com base no comando enviado
    if (response.contains('41 0C')) {
      final rpm = _parseRpmResponse(response);
      if (rpm != null) {
        _rpmController.add(rpm);
      }
    }
    if (response.contains('41 0D')) {
      // PID para velocidade do veículo
      final speed = _parseSpeedResponse(response);
      if (speed != null) {
        updateDistance(speed);
      }
    }

    if (response.contains('41 5E') || response.contains('41 66')) {
       //PID para consumo instantâneo de combustível
       final fuelRate = _parseFuelRateResponse(response);
       if (fuelRate != null) {
         updateFuelConsumption(fuelRate);
       }
    }

    if (response.contains('41 10')) {
      // PID do MAF
      final fuelRateFromMAF = parseFuelRateFromMAF(
        response,
      ); // Função para extrair o consumo de combustível
      if (fuelRateFromMAF != null) {
        updateFuelConsumption(
          fuelRateFromMAF,
        ); // Atualiza o consumo usando sua função (mesma lógica que para o consumo direto)
        _fuelRateController.add(
          fuelRateFromMAF,
        ); // notificar um StreamController, atualizar UI, salvar, etc.
      } else {
        print("Erro ao calcular o consumo de combustível a partir do MAF");
        unawaited(AppSettings.logService?.writeLog('erro ao calcular o consumo de combustível a partir do MAF'));
      }
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

  // Atualizar a distância percorrida
  static void updateDistance(double currentSpeed) {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final timeElapsed =
        (currentTimestamp - _lastDistanceTimestamp) /
        3600000.0; // Tempo em horas

    final distance =
        _lastSpeed * timeElapsed; // Distância percorrida no intervalo
    _totalDistance += distance;

    _lastSpeed = currentSpeed;
    _lastDistanceTimestamp = currentTimestamp;

    _distanceStreamController.add(_totalDistance);
  }

  // Traduzir a resposta
  static double? _parseSpeedResponse(String response) {
    try {
      final clean = response.replaceAll(RegExp(r'[^0-9A-Fa-f ]'), '').trim();
      final bytes = clean.split(' ');

      if (bytes.length >= 3 && bytes[0] == '41' && bytes[1] == '0D') {
        final speed = int.parse(bytes[2], radix: 16); // Velocidade em km/h
        return speed.toDouble();
      }
    } catch (_) {}
    return null;
  }

  // Enviar comando para obter a velocidade
  static Future<void> requestSpeed() async {
    if (_writeCharacteristic == null) return;
    final command = '010D\r'.codeUnits; // PID 0x0D para velocidade
    await _writeCharacteristic!.write(command, withoutResponse: true);
  }

  // Enviar comando para obter o RPM
  static void resetDistance() {
    _totalDistance = 0.0;
    _distanceStreamController.add(_totalDistance);
  }

  // // Enviar comando para obter o consumo instantâneo de combustível
  static Future<void> requestFuelRate() async {
    if (_writeCharacteristic == null) return;
    final command = '015E\r'.codeUnits; // PID para consumo instantâneo de combustível
    await _writeCharacteristic!.write(command, withoutResponse: true);
  }

   // Traduzir a resposta
   static double? _parseFuelRateResponse(String response) {
     try {
       final clean = response.replaceAll(RegExp(r'[^0-9A-Fa-f ]'), '').trim();
       final bytes = clean.split(' ');

       if (bytes.length >= 4 &&
           (bytes[0] == '41' && (bytes[1] == '5E' || bytes[1] == '66'))) {
         final A = int.parse(bytes[2], radix: 16);
         final B = int.parse(bytes[3], radix: 16);
         return ((A * 256) + B) / 20.0; // Em litros por hora
       }
     } catch (_) {}
     return null;
   }

  // Enviar comando para obter o consumo instantâneo de combustível com MFA fluxo de ar em gramas por segundo (g/s)
  static Future<void> requestFuelRateViaMAF() async {
    if (_writeCharacteristic == null) return;
    final command = utf8.encode('0110\r'); // PID 01 10 = MAF
    await _writeCharacteristic!.write(command, withoutResponse: true);
  }

  // Traduzir a resposta
  static double? parseFuelRateFromMAF(String response) {
    try {
      final clean = response.replaceAll(RegExp(r'[^0-9A-Fa-f ]'), '').trim();
      final bytes = clean.split(' ');

      if (bytes.length >= 4 && bytes[0] == '41' && bytes[1] == '10') {
        final A = int.parse(bytes[2], radix: 16);
        final B = int.parse(bytes[3], radix: 16);
        final maf = ((256 * A) + B) / 100.0; // MAF em g/s

        const afr = 14.7; // gasolina
        const fuelDensity = 745.0; // g/L

        final fuelRateLph = (maf * 3600) / (afr * fuelDensity);

        return fuelRateLph;
      }
    } catch (e) {
      print("Erro ao interpretar a resposta do MAF: $e");
      unawaited(AppSettings.logService?.writeLog('Erro ao interpretar a resposta do MAF: $e'));
    }
    return null;
  }

  // Atualizar o consumo de combustível
  static void updateFuelConsumption(double fuelRate) {
    final now = DateTime.now().millisecondsSinceEpoch;

    final elapsedSeconds = (now - _lastFuelTimestamp) / 1000.0;
    _lastFuelTimestamp = now;

    // Converte L/h para L/s, multiplica pelo tempo decorrido para obter litros consumidos
    final fuelConsumedInLiters = (fuelRate / 3600.0) * elapsedSeconds;

    _totalFuelConsumed += fuelConsumedInLiters;
  }

  // Atualizar a velocidade
  static void updateSpeed(double speed) {
    final now = DateTime.now();
    //
    if (_lastSpeedUpdate != null) {
      final deltaTime = now.difference(_lastSpeedUpdate!).inSeconds;
      if (deltaTime > 0) {
        // velocidade (km/h) * tempo (s) / 3600 = km
        _totalDistance += speed * (deltaTime / 3600);
        _distanceStreamController.add(_totalDistance);
      }
    }

    _lastSpeedUpdate = now;

    _speedStreamController.add(speed);
  }

  // Resetar os valores
  static void reset() {
    _totalFuelConsumed = 0.0;
    _totalDistance = 0.0;
    _lastFuelTimestamp = DateTime.now().millisecondsSinceEpoch;
    _lastDistanceTimestamp = DateTime.now().millisecondsSinceEpoch;
    _lastSpeed = 0.0;
    _lastSpeedUpdate = null;

    _distanceStreamController.add(_totalDistance);
    _fuelStreamController.add(_totalFuelConsumed);
    _fuelRateController.add(0.0);
    _speedStreamController.add(0.0);
  }
}
