import 'package:ecoDrive/pages/trip_page.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:ecoDrive/shared/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:ecoDrive/controllers/eco_drive_controller.dart';
import 'package:intl/intl.dart';
import 'package:ecoDrive/repositories/eco_drive_dao.dart';
import 'package:ecoDrive/widgets/confirmDialog.dart';
import 'package:ecoDrive/widgets/update_name.dart';

final EcoDriveController controller = EcoDriveController();
final EcoDriveRepository repository = EcoDriveRepository();

Future<List<Widget>> listarHistorico(
  BuildContext context,
  VoidCallback onReturnFromViagem,
) async {
  final viagens = await controller.listarViagens();

  return viagens.map((viagem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: AppColors.colorAlterBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        tileColor: AppColors.colorAlterBackground,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ViagemPage(id: viagem.id!)),
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
                fontSize: 16,
              ),
            ),
            Text(
              DateFormat('dd/MM/yyyy').format(viagem.dataViagem),
              style: AppStyles.simpleText.copyWith(fontSize: 14),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    "Distância: ",
                    style: AppStyles.simpleText.copyWith(fontSize: 14),
                  ),
                  Text(
                    "${viagem.quilometragemRodada.toStringAsFixed(2)} km",
                    style: AppStyles.simpleText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        formatTempoViagem(viagem.duracaoViagem),
                        style: AppStyles.simpleText.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Text("⛽", style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        viagem.tipoCombustivel,
                        style: AppStyles.simpleText.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("🌍", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    "Emissão de carbono: ",
                    style: AppStyles.simpleText.copyWith(fontSize: 14),
                  ),
                  Text(
                    "${viagem.emissaoCarbono.toStringAsFixed(2)} kg CO₂",
                    style: AppStyles.simpleText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'editar') {
              confirmDialogWithInput(
                context: context,
                menssage: "Insira um novo nome para a viagem:",
                onConfirmed: (novoNome) async {
                  viagem.nomeViagem = novoNome;
                  await repository.update(viagem);
                  onReturnFromViagem();
                },
              );
            } else if (value == 'excluir') {
              confirmDialog(
                context: context,
                menssage: "Deseja realmente excluir esta viagem?",
                function: () async {
                  await repository.delete(viagem);
                  onReturnFromViagem();
                },
              );
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
          ],
        ),
      ),
    );

  }).toList();
}

String formatTempoViagem(int duration) {
  String s = '';
  int hours = duration ~/ 3600;
  if (hours > 0)s += '$hours h ';
  int seconds = duration % 3600;
  int minutes = seconds ~/ 60;
  if (minutes > 0) s += '$minutes min ';
  seconds = seconds % 60;
  if (seconds > 0) s += '$seconds s';
  return s;
}
