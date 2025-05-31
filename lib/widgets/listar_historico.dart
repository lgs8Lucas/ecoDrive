import 'package:ecoDrive/pages/home_page.dart';
import 'package:ecoDrive/pages/viagem_page.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:ecoDrive/shared/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:ecoDrive/controllers/eco_drive_controller.dart';
import 'package:intl/intl.dart';
import 'package:ecoDrive/repositories/eco_drive_dao.dart';
import 'package:ecoDrive/widgets/confirmDialog.dart';

final EcoDriveController controller = EcoDriveController();
final EcoDriveRepository repository = EcoDriveRepository();

Future<List<Widget>> listarHistorico(BuildContext context, VoidCallback onReturnFromViagem) async {
  final viagens = await controller.listarViagens();

  return viagens.map((viagem) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.colorAlterBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViagemPage(id: viagem.id!),
            ),
          );
          onReturnFromViagem(); // Atualiza ao voltar
        },
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              viagem.nomeViagem,
              style: AppStyles.simpleText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${DateFormat('dd/MM/yyyy').format(viagem.dataViagem)}",
              style: AppStyles.simpleText,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Duração: ${formatTempoViagem(viagem.duracaoViagem)}",
              style: AppStyles.simpleText,
            ),
            Text(
              "Emissão de carbono: ${viagem.emissaoCarbono} kg CO₂",
              style: AppStyles.simpleText,
            ),
            Text(
              "Combustível: ${viagem.tipoCombustivel}",
              style: AppStyles.simpleText,
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            confirmDialog(
              context: context,
              menssage: "Deseja realmente excluir esta viagem?",
              function: () async {
                await repository.delete(viagem);
                onReturnFromViagem(); // Atualiza a lista ao voltar
              },
            );
          },
        ),
      ),

    );
  }).toList();
}

String formatTempoViagem(int duration) {
  return "$duration s";
}


