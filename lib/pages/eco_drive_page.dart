import 'dart:async';
import 'package:ecoDrive/services/inclination_service.dart';
import 'package:ecoDrive/widgets/circular_info_widget.dart';
import 'package:ecoDrive/widgets/confirmDialog.dart';
import 'package:ecoDrive/widgets/rpm_acelerometer.dart';
import 'package:ecoDrive/widgets/tip_box.dart';
import 'package:ecoDrive/widgets/vehicle_inclination_vertical.dart';
import 'package:flutter/material.dart';
import '../shared/app_colors.dart';
import '../services/ble_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:ecoDrive/controllers/eco_drive_controller.dart';
import 'package:ecoDrive/models/eco_drive_model.dart';
import '../widgets/carbon_emission_widget.dart';
import 'home_page.dart';

final EcoDriveController controller = EcoDriveController();

class EcoDrivePage extends StatefulWidget {
  final String combustivel; // variável que vai receber o valor
  final VoidCallback onReturn; // Callback para atualizar ao sair


  // construtor com o parâmetro required
  const EcoDrivePage({Key? key, required this.combustivel, required this.onReturn}) : super(key: key);

  @override
  State<EcoDrivePage> createState() => _EcoDrivePageState();
}

class _EcoDrivePageState extends State<EcoDrivePage> {
  Timer? _timer;
  BluetoothDevice? _device;

  final InclinationService _inclinationService = InclinationService();
  final _inclinationThreshold = 10.0; // Limite para considerar inclinação significativa

  String _tipTile = "Bem-vindo!";
  String _tipMessage = "Comece a dirigir para ver dicas.";
  String _tipType = "good";
  int _allTime = 0;
  int _timeOnGreenRPM = 0;
  int _greenRpm = 2500; // RPM verde padrão
  double _zeroInclination = 0.0; // Inclinação zero para referência

  double _totalFuel = 0.0;
  late Future<double> _emissaoCarbonoFuture;
  double _currentDistance = 0.0;
  int _currentRpm = 0;
  double _fuelConsumed = 0.0;
  double _currentInclination = 0.0;

  StreamSubscription<double>? _distanceSubscription;
  StreamSubscription<double>? _fuelSubscription;
  StreamSubscription<int>? _rpmSubscription;
  StreamSubscription<double>? _inclinationSubscription;

  // Função para resetar os valores
  @override
  void initState() {

    super.initState();
    _initRpmListener();
    _initInclinationListener();

    _emissaoCarbonoFuture = controller.calcularEmissaoCarbono(widget.combustivel, _totalFuel);

    // Supondo que você já esteja escutando fuelStream:
    _fuelSubscription = BleService.fuelStream.listen((fuel) {
      print('Combustível recebido: $fuel');

      setState(() {
        _totalFuel = fuel;
        _emissaoCarbonoFuture = controller.calcularEmissaoCarbono(widget.combustivel, _totalFuel);
      });
    });
  }

  // Função para resetar os valores
  void _reset() {
    setState(() {
      _currentDistance = 0.0;
      _currentRpm = 0;
      _allTime = 0;
      _timeOnGreenRPM = 0;
      _fuelConsumed = 0.0;
      _currentInclination = 0.0;
      _zeroInclination = 0.0;
      _totalFuel = 0.0;
      _currentDistance = 0.0;
      _tipTile = "Bem-vindo!";
      _tipMessage = "Comece a dirigir para ver dicas!";
      _tipType = "good";
    });
    BleService.reset();
  }

  // Função para iniciar o listener do RPM
  Future<void> _initRpmListener() async {
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;

    if (devices.isNotEmpty) {
      _device = devices.first;
    } else {
      print("Nenhum dispositivo conectado.");
      return;
    }

    // Escuta o stream de RPM do BleService
    _rpmSubscription = BleService.rpmStream.listen((rpm) {
      setState(() {
        _currentRpm = rpm;
        if (rpm > _greenRpm) {
          _tipTile = "Atenção!";
          _tipMessage = "Reduza as rotações para economizar combustível!";
          _tipType = 'bad';
        } else {
          _tipTile = "Ótima direção!";
          _tipMessage = "Você está dirigindo de forma eficiente! Continue assim!";
          _tipType = 'good';
        }
      });
    });

    // Escuta o stream de distância do BleService
    _distanceSubscription = BleService.distanceStream.listen((distance) {
      print('Distância recebida: $distance');
      setState(() {
        _currentDistance = distance;
      });
    });

    // Escuta o stream de consumo de combustível do BleService
    _fuelSubscription = BleService.fuelRateStream.listen((fuel) {
      print('Combustível recebido: $fuel');
      setState(() {
        _totalFuel = fuel;
      });
    });

    // Solicita DATA a cada 1 segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await BleService.requestFuelRateViaMAF();
      await Future.delayed(Duration(milliseconds: 300));
      await BleService.requestRpm();
      await Future.delayed(Duration(milliseconds: 300));
      await BleService.requestSpeed();
      _allTime++;
      if (_currentRpm <= _greenRpm) {
        _timeOnGreenRPM++;
      }
    });
  }

  // Função para iniciar o listener da inclinação
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

  // Função para limpar os listeners
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

  // Função para construir a página
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.colorMain),
          onPressed: () {
            confirmDialog(
              context: context,
              menssage: "Deseja realmente cancelar está viagem?",
              function: () {
                widget.onReturn();
                Navigator.pop(context);
              },
            );
          },
        ),
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
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TipCard(
                titulo: _tipTile,
                mensagem: _tipMessage,
                tipType: _tipType,
              ),
              RpmAccelerometer(
                currentRpm: _currentRpm.toDouble(),
                greenEnd: _greenRpm.toDouble(),
              ),
              const SizedBox(height: 2),
              FutureBuilder<double>(
                future: _emissaoCarbonoFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro: ${snapshot.error}');
                  } else {
                    return EmissaoCarbonoCard(
                      valor: snapshot.data!.toStringAsFixed(2),
                      unidade: "kgCO2",
                      status: "good", //
                    );
                  }
                },
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularInfoWidget(
                    icon: Icons.map,
                    label: "Distância percorrida",
                    value: _currentDistance,
                    unit: "Km",
                  ),
                  const SizedBox(width: 15),
                  CircularInfoWidget(
                    icon: Icons.oil_barrel,
                    label: "Consumo de Combustivel",
                    value: _totalFuel,
                    unit: "L",
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VehicleInclinationVertical(
                    angle: _currentInclination - _zeroInclination,
                    threshold: _inclinationThreshold,
                  ),
                  const SizedBox(width: 30),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                confirmDialog(
                    context: context,
                    menssage: "Deseja realmente resetar a viagem?",
                    function: _reset);
              },
              icon: Icon(Icons.restart_alt),
              label: Text('Resetar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                confirmDialog(
                    context: context,
                    menssage: "Deseja realmente salvar esta viagem?",
                    function: () async {
                      double consumoCombustivelODB = _totalFuel;
                      double emissaoCarbono = await controller.calcularEmissaoCarbono(
                        widget.combustivel,
                        consumoCombustivelODB,
                      );

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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Viagem salva com sucesso!')),
                      );

                      _reset();

                      widget.onReturn();
                      Navigator.pop(context);
                    });
              },
              icon: Icon(Icons.save),
              label: Text('Finalizar Viagem'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorMain,
                foregroundColor: AppColors.colorMainText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
