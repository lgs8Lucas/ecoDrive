import 'package:ecoDrive/pages/home_page.dart';
import 'package:ecoDrive/pages/viagem_page.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:ecoDrive/shared/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:ecoDrive/controllers/eco_drive_controller.dart';
import 'package:ecoDrive/models/eco_drive_model.dart';
import 'package:intl/intl.dart';

final EcoDriveController controller = EcoDriveController();

// Função para deletar uma viagem
Future<void> _deletarViagem(EcoDriveModel viagem) async {
  await controller.deletarViagem(viagem);
  controller.listarViagens();
}

Future<List<Widget>> listarHistorico(BuildContext context) async {
  final viagens = await controller.listarViagens();

  return viagens.map((viagem) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.colorAlterBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ViagemPage()));
        },
        subtitle: Text("Avalição: ${viagem.avalicaoViagem}", style: AppStyles.simpleText),
        title: Text(
          "Data: " + DateFormat('dd/MM/yyyy HH:mm').format(viagem.dataViagem),
          style: AppStyles.simpleText),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            await _deletarViagem(viagem);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
      ),
    );
  }).toList();
}
