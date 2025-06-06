import 'package:ecoDrive/services/log_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AppSettings {
  static double screenH = 0;
  static double screenW = 0;
  static bool bluetoothIsEnabled = false;
  static bool odbIsConnected = false;
  static BluetoothDevice? connectedDevice;
  static LogService? logService;
}
