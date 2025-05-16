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
}