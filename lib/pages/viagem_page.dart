import 'package:flutter/material.dart';
import 'package:ecoDrive/controllers/eco_drive_controller.dart';
import 'package:ecoDrive/models/eco_drive_model.dart';
import 'package:intl/intl.dart';


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
      appBar: AppBar(title: Text('Relatório da Viagem')),
      body: FutureBuilder<EcoDriveModel?>(
        future: controller.buscarViagemPorId(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final viagem = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        LinhaFormatacao("📅 Data", DateFormat('dd/MM/yyyy HH:mm').format(viagem.dataViagem)),
                        LinhaFormatacao("⛽ Tipo de combustível", viagem.tipoCombustivel),
                        LinhaFormatacao("📏 Quilometragem rodada", "${viagem.quilometragemRodada.toStringAsFixed(2)} km"),
                        LinhaFormatacao("⛽ Consumo de combustível", "${viagem.consumoCombustivel.toStringAsFixed(2)} L"),
                        LinhaFormatacao("🌍 Emissão de carbono", "${viagem.emissaoCarbono.toStringAsFixed(2)} kgCO₂"),
                        LinhaFormatacao("⭐ Avaliação", viagem.avaliacaoViagem),
                        SizedBox(height: 12),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 28),
                        onPressed: () => _deletarViagem(context, viagem),
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

Widget LinhaFormatacao(String titulo, String valor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$titulo:",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              backgroundColor: Colors.grey[60],
          ),
        ),
        Divider(),
      ],
    ),
  );
}


