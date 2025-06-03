import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LogService {
  File? _logFile;

  void initializeLogFile() {
    getApplicationDocumentsDirectory().then((directory) {
      _logFile = File('${directory.path}/app_logs.txt');
      _logFile!.exists().then((exists) {
        if (!exists) {
          _logFile!.create();
        }
      });
    });
  }

  void writeLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message\n';

    if (_logFile != null) {
      _logFile!.writeAsString(logMessage, mode: FileMode.append);
    }
  }

  void readLogs(Function(String) callback) {
    if (_logFile != null) {
      _logFile!.exists().then((exists) {
        if (exists) {
          _logFile!.readAsString().then((logs) {
            callback(logs);
          });
        } else {
          callback('No logs found.');
        }
      });
    } else {
      callback('Log file not initialized.');
    }
  }
}
