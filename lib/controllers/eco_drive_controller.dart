import 'package:ecoDrive/models/eco_drive_model.dart';
import 'package:ecoDrive/repositories/eco_drive_dao.dart';

class EcoDriveController {
  final EcoDriveRepository _repository = EcoDriveRepository();

  // Salvar Viagem no Banco de Dados
  Future<void> salvarViagem(EcoDriveModel model) async {
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

  // Calcula o fator de emissão de CO2 com base no tipo de combustível
  Future<double> determinarFatorCO2(String combustivel) async {
    if (combustivel == 'Gasolina') {
      return 2.3;
    } else if (combustivel == 'Etanol') {
      return 1.5;
    } else if (combustivel == 'Diesel') {
      return 2.7;
    } else {
      return 0.0;
    }
  }

  // Calcula a emissão de CO2 com base no tipo de combustível e no número de litros consumidos
  Future<double> calcularEmissaoCO2(String combustivel, double litrosConsumidos) async {
    double fator = await determinarFatorCO2(combustivel);
    return litrosConsumidos * fator;
  }

}