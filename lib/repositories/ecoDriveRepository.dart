import 'package:path/path.dart'; // Importa funções para manipular caminhos de arquivos
import 'package:ecoDrive/settings.dart'; // Importa constantes definidas no arquivo settings.dart
import 'package:sqflite/sqflite.dart'; // Importa a biblioteca sqflite
import 'package:ecoDrive/models/ecoDriveModel.dart'; // Importa a classe EcoDriveModel

// Classe responsável por gerenciar o acesso ao banco de dados
class EcoDriveRepository{
  Future<Database> _getDatabse() async{
    return openDatabase(
      join(await getDatabasesPath(), databaseName), // Caminho para o banco de dados
      onCreate: (db, version) async {
        return await db.execute(createEcoDriveTableScript); // Cria a tabela no banco de dados
      },
      version: 1, // Versão do banco de dados
    );
  }

  Future create(EcoDriveModel model) async{
    try{
      final Database db = await _getDatabse();
      await db.insert(
        tableName,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
  } catch(ex) {
      print(ex);
      return;
    }
  }
}

