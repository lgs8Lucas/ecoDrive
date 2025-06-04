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

  // Retorna uma viagem pelo ID
  Future<EcoDriveModel?> buscarViagemPorId(int id) async {
    return await _repository.getEcoDriveById(id);
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
  Future<double> determinarFatorCarbono(String combustivel) async {
    if (combustivel == 'Gasolina') {
      return 2.31;
    } else if (combustivel == 'Etanol') {
      return 1.37;
    } else if (combustivel == 'Diesel') {
      return 2.68;
    } else if (combustivel == 'Flex'){
      return 1.84;
    }else{
      return 0.0;
    }
  }

  double determinarFatorCarbonoSincrono(String combustivel) {
    if (combustivel == 'Gasolina') {
      return 2.31;
    } else if (combustivel == 'Etanol') {
      return 1.37;
    } else if (combustivel == 'Diesel') {
      return 2.68;
    } else if (combustivel == 'Flex'){
      return 1.84;
    }else{
      return 0.0;
    }
  }

  // Calcula a emissão de CO2 com base no tipo de combustível e no número de litros consumidos
  Future<double> calcularEmissaoCarbono(String combustivel, double litrosConsumidos) async {
    double fator = await determinarFatorCarbono(combustivel);
    return litrosConsumidos * fator;
  }

  double calcularEmissaoCarbonoSincrona(String combustivel, double litrosConsumidos) {
    double fator = determinarFatorCarbonoSincrono(combustivel);
    return litrosConsumidos * fator;
  }

}