import 'dart:async';
import 'package:ecoDrive/services/inclination_service.dart';
import 'package:ecoDrive/widgets/circular_info_widget.dart';
import 'package:ecoDrive/widgets/confirmDialog.dart';
import 'package:ecoDrive/widgets/rpm_acelerometer.dart';
import 'package:ecoDrive/widgets/tip_box.dart';
import 'package:ecoDrive/widgets/vehicle_inclination_vertical.dart';
import 'package:flutter/material.dart';
import '../shared/app_colors.dart';
import 'package:ecoDrive/controllers/eco_drive_controller.dart';
import 'package:ecoDrive/models/eco_drive_model.dart';
import '../widgets/carbon_emission_widget.dart';
// Controller
final EcoDriveController controller = EcoDriveController();
// Classe para a página EcoDrive
class EcoDriveSimulatedPage extends StatefulWidget {
  final String combustivel; // variável que vai receber o valor
  final VoidCallback onReturn; // Callback para atualizar ao sair
  // construtor com o parâmetro required
  const EcoDriveSimulatedPage({Key? key, required this.combustivel, required this.onReturn}) : super(key: key);
  @override
  State<EcoDriveSimulatedPage> createState() => _EcoDrivePageState();
}
// Classe do estado do EcoDrivePage
class _EcoDrivePageState extends State<EcoDriveSimulatedPage> {
  Timer? _simulationTimer;
  final InclinationService _inclinationService = InclinationService();
  final _inclinationThreshold = 10.0; // Limite para considerar inclinação significativa

  String _tipTile = "Bem-vindo!";
  String _tipMessage = "Comece a dirigir para ver dicas.";
  String _tipType = "good";
  int _allTime = 0;
  int _timeOnGreenRPM = 0;
  int _greenRpm = 2500; // RPM verde padrão
  double _zeroInclination = 0.0; // Inclinação zero para referência
  double _currentInclination = 0.0;

  // Simulated Values
  int _rpm = 0;
  late Future<double> _emissaoCarbono;
  double _distanciaPercorrida = 0.0;
  double _fuelConsumed = 0.0;

  StreamSubscription<double>? _inclinationSubscription;

  // Função para resetar os valores
  @override
  void initState() {
    super.initState();
    _initInclinationListener();
    _startSimulationTimer();
    _emissaoCarbono = controller.calcularEmissaoCarbono(widget.combustivel, _fuelConsumed);
  }

  void _startSimulationTimer() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Simulação dos valores
        _rpm = (_rpm + 100) % 6000; // Incremento do RPM, voltando a 0 ao atingir 6000
        _fuelConsumed += 0.1; // Incremento do consumo de combustível
        _distanciaPercorrida += 0.05; // Incremento da distância percorrida
        _allTime++; // Incrementa o tempo total
        if (_rpm <= _greenRpm) {
          _timeOnGreenRPM++; // Incrementa o tempo no RPM verde
        }
      });
    });
  }

  // Função para resetar os valores
  void _reset() {
    setState(() {
      _distanciaPercorrida = 0.0;
      _rpm = 0;
      _allTime = 0;
      _timeOnGreenRPM = 0;
      _fuelConsumed = 0.0;
      _currentInclination = 0.0;
      _zeroInclination = 0.0;
      _tipTile = "Bem-vindo!";
      _tipMessage = "Comece a dirigir para ver dicas!";
      _tipType = "good";
    });
  }

  // Função para iniciar o listener da inclinação
  Future<void> _initInclinationListener() async {
    _inclinationService.startListening();
    _inclinationSubscription = _inclinationService.inclinationStream.listen((
        angle,
        ) {
      setState(() {
        _currentInclination = angle;
        int adjustedRpm = 2500 + ((angle - _zeroInclination) * 10).toInt();
        _greenRpm = adjustedRpm.clamp(2500, 3500); // entre 2500 e 3500
      });

    });
  }

  // Função para limpar os listeners
  @override
  void dispose() {
    _inclinationSubscription?.cancel();
    _simulationTimer?.cancel();
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
              menssage: "Deseja realmente cancelar está viagem simulada?",
              function: () {
                widget.onReturn();
                Navigator.pop(context);
              },
            );
          },
        ),
        title: Text(
          'EcoDrive Simulado',
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
                currentRpm: _rpm.toDouble(),
                greenEnd: _greenRpm.toDouble(),
              ),
              const SizedBox(height: 2),
              FutureBuilder<double>(
                key: ValueKey(_fuelConsumed),
                future: _emissaoCarbono,
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
                    value: _distanciaPercorrida,
                    unit: "Km",
                  ),
                  const SizedBox(width: 15),
                  CircularInfoWidget(
                    icon: Icons.oil_barrel,
                    label: "Consumo de Combustivel",
                    value: _fuelConsumed,
                    unit: "L/h",
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
                    onPressed: () {
                      setState(() {
                        _zeroInclination = _currentInclination;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Inclinação zero definida!')),
                      );
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
                      double emissaoCarbono = await controller.calcularEmissaoCarbono(
                        widget.combustivel,
                        _fuelConsumed,
                      );

                      final viagem = EcoDriveModel(
                        nomeViagem: "Viagem Simulada",
                        duracaoViagem: _allTime,
                        tempoRpmVerde: _timeOnGreenRPM,
                        dataViagem: DateTime.now(),
                        tipoCombustivel: widget.combustivel,
                        quilometragemRodada: _distanciaPercorrida,
                        consumoCombustivel: _fuelConsumed,
                        emissaoCarbono: emissaoCarbono,
                        avaliacaoViagem: _timeOnGreenRPM > (_allTime ~/ 2) ? 'Excelente' : 'Precisa Melhorar',
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
