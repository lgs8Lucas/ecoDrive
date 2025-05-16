import 'package:path/path.dart';
import 'package:ecoDrive/settings.dart';
import 'package:sqflite/sqflite.dart';

class EcoDriveRepository{
  Future<Database> _getDatabse() async{
    return openDatabase(
      join(await getDatabasesPath(), databaseName),
      onCreate: (db, version) async {
        return await db.execute(createEcoDriveTableScript);
      },
      version: 1,
    );
  }
}

