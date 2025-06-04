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
    } else if (combustivel == 'Flex') {
      return 1.84;
    } else {
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
    } else if (combustivel == 'Flex') {
      return 1.84;
    } else {
      return 0.0;
    }
  }

  // Calcula a emissão de CO2 com base no tipo de combustível e no número de litros consumidos
  Future<double> calcularEmissaoCarbono(
    String combustivel,
    double litrosConsumidos,
  ) async {
    double fator = await determinarFatorCarbono(combustivel);
    return litrosConsumidos * fator;
  }

  double calcularEmissaoCarbonoSincrona(
    String combustivel,
    double litrosConsumidos,
  ) {
    double fator = determinarFatorCarbonoSincrono(combustivel);
    return litrosConsumidos * fator;
  }

  double estimarConsumoMedio(double quilometragem, double consumoCombustivel) {
    if (consumoCombustivel == 0) return 0.0; // Evita divisão por zero
    return quilometragem / consumoCombustivel;
  }

  static double calcularConsumoPorSegundo(
    double rpm,
    String combustivel,
  ) {
    double cilindrada = 1.0;
    int numeroCilindros = 4;
    // Configurações de densidade e relação ar-combustível por tipo de combustível
    final Map<String, Map<String, double>> configuracoesCombustivel = {
      "Gasolina": {"densidade": 0.74, "relacaoArCombustivel": 14.7},
      "Etanol": {"densidade": 0.79, "relacaoArCombustivel": 9.0},
      "Diesel": {"densidade": 0.85, "relacaoArCombustivel": 14.5},
      "Flex": {
        // Valores médios entre gasolina e etanol
        "densidade": (0.74 + 0.79) / 2,
        "relacaoArCombustivel": (14.7 + 9.0) / 2,
      },
    };

    if (!configuracoesCombustivel.containsKey(combustivel)) {
      combustivel = "Gasolina"; // Valor padrão se o combustível não for reconhecido
    }

    // Recupera os parâmetros do combustível
    final densidade = configuracoesCombustivel[combustivel]!["densidade"]!;
    final relacaoArCombustivel =
        configuracoesCombustivel[combustivel]!["relacaoArCombustivel"]!;

    const eficienciaVolumetrica = 0.85;

    // Volume consumido por ciclo (em litros)
    final volumePorCiclo = cilindrada * eficienciaVolumetrica;

    // Consumo em litros por segundo
    return (rpm * volumePorCiclo * numeroCilindros * densidade) /
        (relacaoArCombustivel * 2 * 60 * 60);
  }
}
