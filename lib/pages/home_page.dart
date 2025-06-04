import 'package:ecoDrive/pages/trip_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../shared/app_colors.dart';
import '../widgets/bluetooth_status_widget.dart';
import '../widgets/confirmDialog.dart';
import '../widgets/faq_dialog.dart';
import '../widgets/start_viagem.dart';
import '../widgets/listar_historico.dart';
import 'eco_drive_page.dart';
import 'eco_drive_simulated_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Widget>> _historicoFuture;

  @override
  void initState() {
    super.initState();
    _loadHistorico();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistorico(); // Recarrega o histórico sempre que a página for reconstruída
  }

  void _loadHistorico() {
    setState(() {
      _historicoFuture = listarHistorico(context, () {
        _loadHistorico(); // callback para atualizar a lista após voltar da ViagemPage ou deletar
      });
    });
  }

  void _showFAQ(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => const FAQDialog(),
    );
  }

  Future<bool> _isOBDConnected() async {
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
    return devices.isNotEmpty;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () => _showFAQ(context),
            tooltip: 'Ajuda',
          ),
        ],
        backgroundColor: AppColors.colorWhite,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.colorWhite),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 1),
            Text(
              "Conexão com o ODB",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.colorBlack,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 10),
            BluetoothStatusWidget(),
            SizedBox(height: 25),
            Text(
              "Historico de Viagens",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
            Expanded(
              child: FutureBuilder<List<Widget>>(
                future: _historicoFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final historicoWidgets = snapshot.data ?? [];

                  return ListView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    children: [...historicoWidgets],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool simule = false;
          bool conectado = await _isOBDConnected();
          // Se o usuário não estiver conectado ao ODB, exibe um alerta de que a viagem será simulada
          if (!conectado) {
            await confirmDialog(
              context: context,
              menssage:
                  'O dispositivo OBD2 não está conectado. Deseja continuar com uma simulação?',
              function: () async {
                simule = true; // Inicia viagem simulada
              },
            );
          }

          // Se o usuário não confirmou a simulação, não inicia a viagem
          if (!simule && !conectado) {
            return; // Não inicia a viagem se não estiver conectado e não tiver confirmado a simulação
          }

          final combustivel = await iniciarViagem(
            context: context,
            menssage: 'Informe o tipo de combustível que está utilizando?',
          );

          if (combustivel != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        conectado
                            ? EcoDrivePage(
                              combustivel: combustivel,
                              onReturn: () {
                                setState(() {
                                  _loadHistorico(); // Atualiza a lista de histórico ao voltar
                                });
                              },
                            )
                            : EcoDriveSimulatedPage(
                              combustivel: combustivel,
                              onReturn: () {
                                setState(() {
                                  _loadHistorico(); // Atualiza a lista de histórico ao voltar
                                });
                              },
                            ),
              ),
            );
          }
        },
        backgroundColor: AppColors.colorMain,
        foregroundColor: AppColors.colorMainText,
        label: const Text('Iniciar Viagem'),
        icon: const Icon(Icons.directions_car_rounded),
      ),
    );
  }
}
