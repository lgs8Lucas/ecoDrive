import 'package:ecoDrive/models/eco_drive_model.dart';
import 'package:ecoDrive/repositories/eco_drive_dao.dart';

class EcoDriveController{
  final EcoDriveRepository _repository = EcoDriveRepository();

  // Salvar Viagem no Banco de Dados
  Future<void> salvarViagem(EcoDriveModel model) async{
        await _repository.create(model);
  }

  // Retorna todas as viagens salvas
  Future<List<EcoDriveModel>> listarViagens() async {
    return await _repository.getEcoDrive();
  }

  // Atualiza uma viagem existente
  Future<void> atualizarViagem(EcoDriveModel viagem) async {
    await _repository.update(viagem);
  }

  // Remove uma viagem do banco
  Future<void> deletarViagem(EcoDriveModel viagem) async {
    await _repository.delete(viagem);
  }

}