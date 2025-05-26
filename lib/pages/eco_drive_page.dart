import 'dart:async';
import 'package:ecoDrive/services/inclination_service.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../shared/app_colors.dart';
import '../services/ble_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ecoDrive/controllers/eco_drive_controller.dart';
import 'package:ecoDrive/models/eco_drive_model.dart';
final EcoDriveController controller = EcoDriveController();

class EcoDrivePage extends StatefulWidget {
  final String combustivel;  // variável que vai receber o valor

  // construtor com o parâmetro required
  const EcoDrivePage({Key? key, required this.combustivel}) : super(key: key);

  @override
  State<EcoDrivePage> createState() => _EcoDrivePageState();
}

class _EcoDrivePageState extends State<EcoDrivePage> {
  int _currentRpm = 0;
  int _allTime = 0;
  int _timeOnGreenRPM = 0;
  double _currentInclination = 0.0;
  StreamSubscription<int>? _rpmSubscription;
  StreamSubscription<double>? _inclinationSubscription;
  Timer? _timer;
  BluetoothDevice? _device;
  final InclinationService _inclinationService = InclinationService();

  double _currentDistance = 0.0;
  StreamSubscription<double>? _distanceSubscription;

  @override
  void initState() {
    super.initState();
    _initRpmListener();
    _initInclinationListener();
    _initDistanceListener();
  }

  Future<void> _initRpmListener() async {
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;

    _device = devices.first;

    // Escuta o stream de RPM do BleService
    _rpmSubscription = BleService.rpmStream.listen((rpm) {
      setState(() {
        _currentRpm = rpm;
      });
    });

    // Solicita RPM a cada 1 segundo
    _timer = Timer.periodic(const Duration(seconds: 0), (_) {
      BleService.requestRpm();
      _allTime++;
      if (_currentRpm <= 2500 || (_currentRpm <= 3000 && _currentInclination >= 15)) {
        _timeOnGreenRPM++;
      }
    });
  }

  Future<void> _initInclinationListener() async {
    _inclinationService.startListening();
    _inclinationSubscription = _inclinationService.inclinationStream.listen((
      angle,
    ) {
      setState(() {
        _currentInclination = angle;
      });
    });
  }

  void _initDistanceListener() {
    _distanceSubscription = BleService.distanceStream.listen((distance) {
      setState(() {
        _currentDistance = distance;
      });
    });
  }

  @override
  void dispose() {
    _rpmSubscription?.cancel();
    _inclinationSubscription?.cancel();
    _timer?.cancel();
    _distanceSubscription?.cancel();
    BleService.dispose();
    _inclinationService.dispose();
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      ),
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
              const SizedBox(height: 32),
              const Text(
                'Inclinação do Veículo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                '${_currentInclination.toStringAsFixed(2)}°',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentInclination > 10
                    ? 'Subida 🚗⬆️'
                    : _currentInclination < -10
                    ? 'Descida 🚗⬇️'
                    : 'Plano 🚗➖',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 32),
              const Text(
                'Distância Percorrida',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                '${_currentDistance.toStringAsFixed(2)} km',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          double consumoCombustivelODB = 10.2; //dados que serão coletados do ODBII
          double emissaoCarbono = await controller.calcularEmissaoCarbono(widget.combustivel, consumoCombustivelODB); //Emissão de carbono

          final viagem = EcoDriveModel(
            dataViagem: DateTime.now(),
            tipoCombustivel: widget.combustivel,
            quilometragemRodada: _currentDistance,
            consumoCombustivel: 1.2,
            emissaoCarbono: emissaoCarbono,
            avaliacaoViagem: "Excelente",
          );

          await controller.salvarViagem(viagem);
          print("Viagem salva com sucesso!");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Viagem salva com sucesso!')),
          );

          // Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(builder: (context) => HomePage()),
          // );
        },
        backgroundColor: AppColors.colorMain,
        foregroundColor: AppColors.colorMainText,
        label: const Text('Salvar Viagem'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
