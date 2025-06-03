import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LogService {
  File? _logFile;

  Future<void> initializeLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/app_logs.txt');

    // Cria o arquivo se não existir
    if (!(await _logFile!.exists())) {
      await _logFile!.create();
    }
  }

  Future<void> writeLog(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message\n';

    if (_logFile != null) {
      await _logFile!.writeAsString(logMessage, mode: FileMode.append);
    }
  }

  Future<String> readLogs() async {
    if (_logFile != null && await _logFile!.exists()) {
      return await _logFile!.readAsString();
    }
    return 'No logs found.';
  }
}
