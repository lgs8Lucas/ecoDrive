class EcoDriveModel{
  int id = 0;
  String nomeViagem;
  DateTime dataViagem;

  EcoDriveModel({
    required this.id,
    required this.nomeViagem,
    DateTime? dataViagem,
  }) : dataViagem = dataViagem ?? DateTime.now();
}

