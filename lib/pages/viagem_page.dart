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
      appBar: AppBar(title: Text('Detalhes da Viagem')),
      body: FutureBuilder<EcoDriveModel?>(
        future: controller.buscarViagemPorId(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Viagem não encontrada'));
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Relatório da Viagem",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  buildLinha("📅 Data", DateFormat('dd/MM/yyyy HH:mm').format(viagem.dataViagem)),
                  buildLinha("⛽ Tipo de combustível", viagem.tipoCombustivel),
                  buildLinha("📏 Quilometragem rodada", "${viagem.quilometragemRodada.toStringAsFixed(2)} km"),
                  buildLinha("⛽ Consumo de combustível", "${viagem.consumoCombustivel.toStringAsFixed(2)} L"),
                  buildLinha("🌍 Emissão de carbono", "${viagem.emissaoCarbono.toStringAsFixed(2)} kgCO₂"),
                  buildLinha("⭐ Avaliação", viagem.avaliacaoViagem),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 28),
                      onPressed: () => _deletarViagem(context, viagem),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget buildLinha(String titulo, String valor) {
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
          style: TextStyle(fontSize: 20),
        ),
      ],
    ),
  );
}


