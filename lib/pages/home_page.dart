import 'package:ecoDrive/pages/eco_drive_page.dart';
import 'package:ecoDrive/shared/app_settings.dart';
import 'package:ecoDrive/widgets/trip_list.dart';
import 'package:ecoDrive/widgets/iniciar_viagem.dart';
import 'package:flutter/material.dart';
import 'package:ecoDrive/pages/viagem_page.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:ecoDrive/widgets/bluetooth_status_widget.dart';
import '../widgets/faq_dialog.dart'; // importe aqui
import 'package:ecoDrive/controllers/eco_drive_controller.dart';
import 'package:ecoDrive/models/eco_drive_model.dart';

final EcoDriveController controller = EcoDriveController();

class HomePage extends StatelessWidget {
  @override

  void _showFAQ(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => const FAQDialog(),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EcoDrive',
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
        decoration: BoxDecoration(
          color: AppColors.colorWhite,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 1),
            Text("Conexão com o ODB",
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
            Text("Historico de Viagens",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Widget>>(
                future: listarHistorico(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final historicoWidgets = snapshot.data ?? [];

                  return ListView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    children: [
                      ...historicoWidgets,
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),



      floatingActionButton: FloatingActionButton.extended(
        /*
        onPressed: () async{
          final novaViagem = EcoDriveModel(
              avalicaoViagem: "Excelente",
              dataViagem: DateTime.now(),
          );
          await controller.salvarViagem(novaViagem);
          print("Viagem salva com sucesso!");
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        */
        onPressed: () async {
          final combustivel = await iniciarViagem(
            context: context,
            menssage: 'Informe o tipo de combustivel que está utilizando?',
          );
        },
        backgroundColor: AppColors.colorMain,
        foregroundColor: AppColors.colorMainText,
        label: Text('Iniciar Viagem'),
        icon: Icon(Icons.directions_car_rounded),
      ),
    );
  }

}