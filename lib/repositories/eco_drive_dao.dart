import 'package:path/path.dart'; // Importa funções para manipular caminhos de arquivos
import 'package:ecoDrive/settings.dart'; // Importa constantes definidas no arquivo settings.dart
import 'package:sqflite/sqflite.dart'; // Importa a biblioteca sqflite
import 'package:ecoDrive/models/eco_drive_model.dart'; // Importa a classe EcoDriveModel

// Classe responsável por gerenciar o acesso ao banco de dados
class EcoDriveRepository {
  Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), databaseName),
      // Caminho para o banco de dados
      onCreate: (db, version) async {
        return await db.execute(
            createEcoDriveTableScript); // Cria a tabela no banco de dados
      },
      version: 1, // Versão do banco de dados
    );
  }

  // Metodo para inserir um novo registro no banco de dados
  Future create(EcoDriveModel model) async {
    try {
      final Database db = await _getDatabase();
      await db.insert(
        tableName,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (ex) {
      print(ex);
      return;
    }
  }

  // Metodo para retornar todos os registros do banco de dados
  Future<List<EcoDriveModel>> getEcoDrive() async {
    try {
      final Database db = await _getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(tableName);

      return List.generate(
        maps.length,
            (i) {
          return EcoDriveModel.fromMap(maps[i]);
        },
      );
    } catch (ex) {
      print(ex);
      return [];
    }
  }

  // Metodo para retornar um registro pelo ID
  Future<EcoDriveModel?> getEcoDriveById(int id) async {
    try {
      final Database db = await _getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return EcoDriveModel.fromMap(maps.first);
      } else {
        return null; // Nenhum registro encontrado com o ID fornecido
      }
    } catch (ex) {
      print('Erro ao buscar por ID: $ex');
      return null;
    }
  }

  // Metodo para atualizar um registro no banco de dados
  Future update(EcoDriveModel model) async {
    try {
      final Database db = await _getDatabase();
      await db.update(
        tableName,
        model.toMap(),
        where: "id = ?",
        whereArgs: [model.id],
      );
    }catch (ex){
      print(ex);
      return;
    }
  }

  // Metodo para deletar um registro no banco de dados
  Future delete(EcoDriveModel model) async {
    try {
      final Database db = await _getDatabase();
      await db.delete(
        tableName,
        where: "id = ?",
        whereArgs: [model.id],
      );
    }catch (ex){
      print(ex);
      return;
    }
  }
}