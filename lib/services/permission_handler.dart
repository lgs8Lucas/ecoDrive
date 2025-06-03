import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> solicitarPermissoesBluetooth(BuildContext context) async {
  // Exibir diálogo explicando por que as permissões são necessárias
  bool aceitar = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Permissões necessárias'),
      content: Text(
          'Precisamos das permissões de Bluetooth e Localização para detectar e conectar aos dispositivos próximos.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Negar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Permitir'),
        ),
      ],
    ),
  ) ?? false;

  if (!aceitar) return false;

  // Solicitar permissões
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();

  // Verificar se alguma permissão foi permanentemente negada
  if (statuses.values.any((status) => status.isPermanentlyDenied)) {
    bool abrirConfiguracoes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permissões negadas permanentemente'),
        content: Text(
            'Você negou permanentemente uma ou mais permissões. Para continuar, abra as configurações do aplicativo e permita o acesso.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Abrir configurações'),
          ),
        ],
      ),
    ) ?? false;

    if (abrirConfiguracoes) {
      await openAppSettings();
    }

    return false;
  }

  // Verifica se todas as permissões foram concedidas
  bool todasPermitidas = statuses.values.every((status) => status.isGranted);
  return todasPermitidas;
}