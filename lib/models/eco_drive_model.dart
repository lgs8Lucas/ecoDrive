class EcoDriveModel {
  int? id = 0;
  DateTime dataViagem;
  String tipoCombustivel;
  double quilometragemRodada;
  double consumoCombustivel;
  double emissaoCarbono;
  String avaliacaoViagem;
  String nomeViagem;
  int duracaoViagem; //Duração da viagem em segundos
  int tempoRpmVerde; //Tempo em que o motor ficou na faixa de RPM verde

  // Construtor com parâmetros obrigatórios
  EcoDriveModel({
    this.id,
    required this.tipoCombustivel,
    required this.quilometragemRodada,
    required this.consumoCombustivel,
    required this.emissaoCarbono,
    required this.avaliacaoViagem,
    DateTime? dataViagem,
    required this.nomeViagem,
    required this.duracaoViagem,
    required this.tempoRpmVerde,
  }) : dataViagem =
           dataViagem ??
           DateTime.now(); //'dataViagem' é opcional se não for passado, será a data atual

  // Isso é necessário para salvar os dados no banco de dados SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipoCombustivel': tipoCombustivel,
      'quilometragemRodada': quilometragemRodada,
      'consumoCombustivel': consumoCombustivel,
      'emissaoCarbono': emissaoCarbono,
      'avaliacaoViagem': avaliacaoViagem,
      'dataViagem': dataViagem.toIso8601String(),
      //Formato compativel como banco de dados
      'nomeViagem': nomeViagem,
      'duracaoViagem': duracaoViagem,
      'tempoRpmVerde': tempoRpmVerde,
    };
  }

  // Converte Map em objeto para ler do banco
  factory EcoDriveModel.fromMap(Map<String, dynamic> map) {
    return EcoDriveModel(
      id: map['id'] ?? 0,
      tipoCombustivel: map['tipoCombustivel'] ?? '',
      quilometragemRodada: map['quilometragemRodada']?.toDouble() ?? 0.0,
      consumoCombustivel: map['consumoCombustivel']?.toDouble() ?? 0.0,
      emissaoCarbono: map['emissaoCarbono']?.toDouble() ?? 0.0,
      avaliacaoViagem: map['avaliacaoViagem'] ?? '',
      dataViagem: DateTime.tryParse(map['dataViagem'] ?? '') ?? DateTime.now(),
      nomeViagem: map['nomeViagem'] ?? '',
      duracaoViagem: map['duracaoViagem'] ?? 0,
      tempoRpmVerde: map['tempoRPMVerde'] ?? 0,
    );
  }
}
