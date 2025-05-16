class EcoDriveModel{
  int id = 0;
  String nomeViagem;
  DateTime dataViagem;

  // Construtor com parâmetros obrigatórios
  EcoDriveModel({
    required this.id,
    required this.nomeViagem,
    DateTime? dataViagem,
  }) : dataViagem = dataViagem ?? DateTime.now(); //'dataViagem' é opcional se não for passado, será a data atual

  // Isso é necessário para salvar os dados no banco de dados SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeViagem': nomeViagem,
      'dataViagem': dataViagem.toIso8601String(), //Formato compativel como banco de dados
     };
  }

  // Converte Map em objeto para ler do banco
  factory EcoDriveModel.fromMap(Map<String, dynamic> map) {
    return EcoDriveModel(
      id: map['id'] ?? 0,
      nomeViagem: map['nomeViagem'] ?? '',
      dataViagem: DateTime.tryParse(map['dataViagem'] ?? '') ?? DateTime.now(),
    );
  }
}