import 'package:ecoDrive/shared/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:ecoDrive/pages/viagemPage.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:ecoDrive/widgets/stream_builder.dart';
import 'package:ecoDrive/models/ecoDriveModel.dart';
import 'package:ecoDrive/controllers/ecoDriveController.dart';

// Instância do controller
final EcoDriveController controller = EcoDriveController();

// Função para deletar uma viagem
void _deletarViagem(EcoDriveModel viagem) async {
  await controller.deletarViagem(viagem);
  controller.listarViagens();
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EcoDrive',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.colorMainText,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: AppColors.colorMain,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        color: AppColors.colorMainText,
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
            Container( child: BluetoothStatusWidget()),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Historico de Viagens",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Expanded(
                child: Container(
                  height: 300,
                  child: listaHistorico(context),
              )
            ),
          ],
        ),
      ),
      floatingActionButton: btnIniciaViagem(context),
    );
  }

  // Função para a listar viagens
  Widget listaHistorico(BuildContext context) {
    return FutureBuilder<List<EcoDriveModel>>(
      future: controller.listarViagens(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final viagens = snapshot.data ?? []; // Lista de viagens

        return ListView.builder(
          itemCount: viagens.length,
          itemBuilder: (context, index) {
            final viagem = viagens[index];
            return itemViagem(context, viagem);
          },
        );
      },
    );
  }

  // Função para a lista itens da viagem
  Widget itemViagem(BuildContext context, EcoDriveModel viagem) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViagemPage()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        height: 100,
        color: AppColors.colorAlterBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.calendar_today, color: AppColors.colorMain),
                SizedBox(width: 10),
                Text(
                  viagem.dataViagem.toString(), // pega do banco
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletarViagem(viagem),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: <Widget>[
                Icon(Icons.title, color: AppColors.colorMain),
                SizedBox(width: 10),
                Text(
                  viagem.nomeViagem, // pega do banco
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Função para o botão de iniciar viagem
  Widget btnIniciaViagem(BuildContext context) {
    return FloatingActionButton.extended(
      label: Text(
        "Iniciar Viagem",
        style: TextStyle(
          color: AppColors.colorMainText,
        ),
      ),
      onPressed: () async {
        final novaViagem = EcoDriveModel(
          nomeViagem: "Viagem Teste 4",
          dataViagem: DateTime.now(),
        );
        await controller.salvarViagem(novaViagem);
        print("Viagem salva com sucesso!");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
      backgroundColor: AppColors.colorMain,
      icon: Icon(Icons.directions_car, color: AppColors.colorMainText),
    );
  }

}