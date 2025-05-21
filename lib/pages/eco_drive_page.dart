import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../shared/app_colors.dart';
import '../services/ble_service.dart'; // ajuste o caminho conforme necessário
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class EcoDrivePage extends StatefulWidget {
  const EcoDrivePage({super.key});

  @override
  State<EcoDrivePage> createState() => _EcoDrivePageState();
}

class _EcoDrivePageState extends State<EcoDrivePage> {
  int _currentRpm = 0;
  StreamSubscription<int>? _rpmSubscription;
  Timer? _timer;
  BluetoothDevice? _device;

  @override
  void initState() {
    super.initState();
    _initRpmListener();
  }

  Future<void> _initRpmListener() async {
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
    // if (devices.isEmpty) {
    //   // Voltar para a HomePage caso não tenha dispositivo conectado
    //   if (mounted) {
    //     Navigator.of(context).popUntil((route) => route.isFirst);
    //   }
    //   return;
    // }
    _device = devices.first;

    // Escuta o stream de RPM do BleService
    _rpmSubscription = BleService.rpmStream.listen((rpm) {
      setState(() {
        _currentRpm = rpm;
      });
    });

    // Solicita RPM a cada 1 segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      BleService.requestRpm();
    });
  }

  @override
  void dispose() {
    _rpmSubscription?.cancel();
    _timer?.cancel();
    BleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EcoDrive',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.colorMain,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.colorWhite,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'RPM do Motor',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 8000,
                    interval: 1000,
                    axisLineStyle: const AxisLineStyle(
                      thickness: 0.2,
                      cornerStyle: CornerStyle.bothCurve,
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    pointers: [
                      NeedlePointer(
                        value: _currentRpm.toDouble().clamp(0, 8000),
                        enableAnimation: true,
                        needleStartWidth: 1,
                        needleEndWidth: 4,
                        knobStyle: const KnobStyle(
                          color: Colors.red,
                          sizeUnit: GaugeSizeUnit.factor,
                          knobRadius: 0.06,
                        ),
                      )
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          '$_currentRpm RPM',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.75,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Viagem salva com sucesso!')),
          );
        },
        backgroundColor: AppColors.colorMain,
        foregroundColor: AppColors.colorMainText,
        label: const Text('Salvar Viagem'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
