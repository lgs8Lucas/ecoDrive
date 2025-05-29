import 'dart:async';
import 'package:ecoDrive/services/inclination_service.dart';
import 'package:ecoDrive/widgets/circular_info_widget.dart';
import 'package:ecoDrive/widgets/rpm_acelerometer.dart';
import 'package:ecoDrive/widgets/tip_box.dart';
import 'package:ecoDrive/widgets/vehicle_inclination_vertical.dart';
import 'package:flutter/material.dart';
import '../shared/app_colors.dart';
import '../services/ble_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ecoDrive/controllers/eco_drive_controller.dart';
import 'package:ecoDrive/models/eco_drive_model.dart';

import 'home_page.dart';

final EcoDriveController controller = EcoDriveController();

class EcoDrivePage extends StatefulWidget {
  final String combustivel; // variável que vai receber o valor

  // construtor com o parâmetro required
  const EcoDrivePage({Key? key, required this.combustivel}) : super(key: key);

  @override
  State<EcoDrivePage> createState() => _EcoDrivePageState();
}

class _EcoDrivePageState extends State<EcoDrivePage> {
  int _currentRpm = 0;
  int _allTime = 0;
  int _timeOnGreenRPM = 0;
  int _greenRpm = 2500; // RPM verde padrão
  double _fuelConsumed = 0.0;
  double _currentInclination = 0.0;
  double _zeroInclination = 0.0; // Inclinação zero para referência
  StreamSubscription<int>? _rpmSubscription;
  StreamSubscription<double>? _inclinationSubscription;
  Timer? _timer;
  BluetoothDevice? _device;
  final InclinationService _inclinationService = InclinationService();
  final _inclinationThreshold =
      10.0; // Limite para considerar inclinação significativa
  double _totalFuel = 0.0;
  StreamSubscription<double>? _fuelSubscription;
  String _tipMessage =
      "Você está dirigindo de forma eficiente! Continue assim!"; // Mensagem da dica
  String _tipType = 'good'; // Tipo da dica, pode ser 'good' ou 'bad'

  double _currentDistance = 0.0;
  StreamSubscription<double>? _distanceSubscription;

  @override
  void initState() {
    super.initState();
    _initRpmListener();
    _initInclinationListener();
    _initDistanceListener();
    _initFuelListener();
  }

  Future<void> _initRpmListener() async {
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;

    _device = devices.first;

    // Escuta o stream de RPM do BleService
    _rpmSubscription = BleService.rpmStream.listen((rpm) {
      setState(() {
        _currentRpm = rpm;
        if (rpm > _greenRpm) {
          _tipMessage = "Reduza as rotações para economizar combustível!";
          _tipType = 'bad';
        } else {
          _tipMessage = "Você está dirigindo de forma eficiente! Continue assim!";
          _tipType = 'good';
        }
      });
    });

    // Solicita RPM a cada 1 segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      BleService.requestRpm();
      BleService.requestSpeed();
      _allTime++;
      if (_currentRpm <= _greenRpm) {
        _timeOnGreenRPM++;
      }
    });
  }

  Future<void> _initInclinationListener() async {
    _inclinationService.startListening();
    _inclinationSubscription = _inclinationService.inclinationStream.listen((
      angle,
    ) {
      int greenRpm = 2500 + ((angle - _zeroInclination) * 10).toInt();
      setState(() {
        _currentInclination = angle;
        _greenRpm =
            greenRpm > 2500
                ? greenRpm
                : 2500; // Ajusta o RPM verde com base na inclinação
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

  void _initFuelListener() {
    _fuelSubscription = BleService.fuelStream.listen((fuel) {
      setState(() {
        _totalFuel = fuel;
      });
    });
  }

  @override
  void dispose() {
    _rpmSubscription?.cancel();
    _inclinationSubscription?.cancel();
    _fuelSubscription?.cancel();
    _distanceSubscription?.cancel();
    _timer?.cancel();
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
            children: [
              TipBox(tipMessage: _tipMessage, type: _tipType),
              RpmAccelerometer(
                currentRpm: _currentRpm.toDouble(),
                greenEnd: _greenRpm.toDouble(),
              ),
              CircularInfoWidget(
                icon: Icons.local_fire_department_rounded,
                label: "Emissão de carbono",
                value: 0,
                unit: "Kg",
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularInfoWidget(
                    icon: Icons.map,
                    label: "Distância percorrida",
                    value: _currentDistance,
                    unit: "Km",
                  ),
                  const SizedBox(width: 16),
                  CircularInfoWidget(
                    icon: Icons.oil_barrel,
                    label: "Consumo de Combustivel",
                    value: _totalFuel,
                    unit: "L",
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VehicleInclinationVertical(
                    angle: _currentInclination - _zeroInclination,
                    threshold: _inclinationThreshold,
                  ),
                  const SizedBox(width: 20),
                  FilledButton(
                    onPressed:
                        () => {
                          setState(() {
                            _zeroInclination = _currentInclination;
                          }),
                        },
                    child: const Text('Definir Inclinação Zero'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          double consumoCombustivelODB =
              _totalFuel; //dados que serão coletados do ODBII
          double emissaoCarbono = await controller.calcularEmissaoCarbono(
            widget.combustivel,
            consumoCombustivelODB,
          ); //Emissão de carbono

          final viagem = EcoDriveModel(
            nomeViagem: "Viagem ${DateTime.now().toIso8601String()}",
            duracaoViagem: _allTime,
            tempoRpmVerde: _timeOnGreenRPM,
            dataViagem: DateTime.now(),
            tipoCombustivel: widget.combustivel,
            quilometragemRodada: _currentDistance,
            consumoCombustivel: consumoCombustivelODB,
            emissaoCarbono: emissaoCarbono,
            avaliacaoViagem: "Excelente",
          );

          await controller.salvarViagem(viagem);
          print("Viagem salva com sucesso!");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Viagem salva com sucesso!')),
          );

          Navigator.pushReplacement(
               context,
               MaterialPageRoute(builder: (context) => HomePage()),
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
