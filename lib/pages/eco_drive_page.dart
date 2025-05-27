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
  double _fuelConsumed = 0.0;
  double _currentInclination = 0.0;
  StreamSubscription<int>? _rpmSubscription;
  StreamSubscription<double>? _inclinationSubscription;
  Timer? _timer;
  BluetoothDevice? _device;
  final InclinationService _inclinationService = InclinationService();
  double _totalFuel = 0.0;
  StreamSubscription<double>? _fuelSubscription;
  String _tipMessage = "Mantenha o RPM abaixo de 2500 para uma condução eficiente.";
  String _tipType = 'bad'; // Tipo da dica, pode ser 'good' ou 'bad'


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
    _timer?.cancel();
    _distanceSubscription?.cancel();
    BleService.dispose();
    _inclinationService.dispose();
    super.dispose();
    _fuelSubscription?.cancel();

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
              RpmAccelerometer(currentRpm: _currentRpm.toDouble(), greenEnd: 2500),
              VehicleInclinationVertical(angle: _currentInclination, threshold: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularInfoWidget(icon: Icons.map, label: "Distância percorrida", value: _currentDistance, unit: "Km"),
                  const SizedBox(width: 16),
                  CircularInfoWidget(icon: Icons.oil_barrel, label: "Consumo de Combustivel", value: _totalFuel, unit: "L"),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          double consumoCombustivelODB = _totalFuel; //dados que serão coletados do ODBII
          double emissaoCarbono = await controller.calcularEmissaoCarbono(widget.combustivel, consumoCombustivelODB); //Emissão de carbono

          final viagem = EcoDriveModel(
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
