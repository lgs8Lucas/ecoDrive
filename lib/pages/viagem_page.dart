import 'package:flutter/material.dart';
import 'package:ecoDrive/controllers/eco_drive_controller.dart';
import 'package:ecoDrive/models/eco_drive_model.dart';
import 'package:intl/intl.dart';
import 'package:ecoDrive/pages/home_page.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:ecoDrive/shared/app_styles.dart';
import 'package:ecoDrive/repositories/eco_drive_dao.dart';
import 'package:ecoDrive/widgets/confirmDialog.dart';

final EcoDriveController controller = EcoDriveController();
final EcoDriveRepository repository = EcoDriveRepository();

class ViagemPage extends StatelessWidget {
  final EcoDriveController controller = EcoDriveController();

  final int id;
  ViagemPage({super.key, required this.id});

  // Função para deletar uma viagem
  void _deletarViagem(BuildContext context, EcoDriveModel viagem) async {
    await controller.deletarViagem(viagem);
    Navigator.pop(context); // Voltar para página anterior após deletar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Relatório',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.colorMain,
          letterSpacing: 1.0,
          ),
        ),
      ),
      body: FutureBuilder<EcoDriveModel?>(
        future: controller.buscarViagemPorId(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final viagem = snapshot.data!;

          double consumoMedio = viagem.quilometragemRodada / viagem.consumoCombustivel;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black12,
                //     blurRadius: 6,
                //     offset: Offset(0, 3),
                //   ),
                // ],
              ),
              child: Row(
                  children: [
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(16),
                        children: [
                          SizedBox(height: 10),
                          LinhaFormatada("📅 Data", DateFormat('dd/MM/yyyy HH:mm').format(viagem.dataViagem)),
                          LinhaFormatada("⛽ Tipo de combustível", viagem.tipoCombustivel),
                          LinhaFormatada("🛣 Quilometragem rodada", "${viagem.quilometragemRodada.toStringAsFixed(2)} km"),
                          LinhaFormatada("⛽ Consumo total", "${viagem.consumoCombustivel.toStringAsFixed(2)} L"),
                          LinhaFormatada("⛽ Consumo médio", "${consumoMedio.toStringAsFixed(2)} km/L"),
                          LinhaFormatada("🌍 Emissão de carbono", "${viagem.emissaoCarbono.toStringAsFixed(2)} kgCO2"),
                          LinhaFormatada("⭐ Avaliação", viagem.avaliacaoViagem),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          confirmDialog(
                            context: context,
                            menssage: "Deseja realmente excluir esta viagem?",
                            function: () async {
                              await repository.delete(viagem);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage()),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ]
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget LinhaFormatada(String titulo, String valor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$titulo:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 15),
        Text(
          valor,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              //backgroundColor: Colors.grey[100],
          ),
        ),
        Divider(),
      ],
    ),
  );
}


