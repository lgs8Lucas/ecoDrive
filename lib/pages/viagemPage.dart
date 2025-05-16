import 'package:flutter/material.dart';
import 'package:ecoDrive/controllers/ecoDriveController.dart';
import 'package:ecoDrive/models/ecoDriveModel.dart';


class ViagemPage extends StatelessWidget {
  final EcoDriveController controller = EcoDriveController();

  // Função para deletar uma viagem
  void _deletarViagem(EcoDriveModel viagem) async {
    await controller.deletarViagem(viagem);
    controller.listarViagens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Viagens Salvas')),
      body: FutureBuilder<List<EcoDriveModel>>(
        future: controller.listarViagens(),
        builder: (context, snapshot) {
          final viagens = snapshot.data ?? [];

          return ListView.builder(
            itemCount: viagens.length,
            itemBuilder: (context, index) {
              final viagem = viagens[index];
              return ListTile(
                title: Text(viagem.nomeViagem),
                subtitle: Text(viagem.dataViagem.toString()),
                trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deletarViagem(viagem),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

