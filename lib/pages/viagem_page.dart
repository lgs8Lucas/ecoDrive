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
            child: ListTile(
              title: Text("Data: " + DateFormat('dd/MM/yyyy HH:mm').format(viagem.dataViagem)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Combustível: ${viagem.tipoCombustivel}'),
                  Text('Quilometragem rodada: ${viagem.quilometragemRodada.toStringAsFixed(2)} km'),
                  Text('Consumo de combustível: ${viagem.consumoCombustivel.toStringAsFixed(2)} L'),
                  Text('Emissão de carbono: ${viagem.emissaoCarbono.toStringAsFixed(2)} kgCO2'),
                  Text('Avaliação: ${viagem.avaliacaoViagem}'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deletarViagem(context, viagem),
              ),
            ),
          );
        },
      ),
    );
  }
}


