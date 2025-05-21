import 'package:permission_handler/permission_handler.dart';

Future<bool> solicitarPermissoesBluetooth() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();

  bool allGranted = statuses.values.every((status) => status.isGranted);
  return allGranted;
}