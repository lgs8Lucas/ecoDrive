import 'package:ecoDrive/services/ble_service.dart';
import 'package:ecoDrive/services/log_service.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:ecoDrive/widgets/terms_of_use_dialog.dart';
import 'package:flutter/material.dart';
import 'package:ecoDrive/pages/home_page.dart';
import 'package:ecoDrive/shared/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main()  async  {
  BleService.initialize(); // <- ESSENCIAL para o stream funcionar
  WidgetsFlutterBinding.ensureInitialized();
  AppSettings.logService = LogService();
  await AppSettings.logService?.initializeLogFile();
  await AppSettings.logService?.writeLog('Aplicativo iniciado');
  runApp(App());
}

class App extends StatelessWidget{

  Future<void> _checkAndShowTerms(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final termsAccepted = prefs.getBool('termsAccepted') ?? false;

    if (!termsAccepted || true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const TermsOfUseDialog(),
      ).then((_) async {
        await prefs.setBool('termsAccepted', true);
      });
    }
  }


  @override
  Widget build(BuildContext context){
    AppSettings.screenH = MediaQuery.of(context).size.height;
    AppSettings.screenW = MediaQuery.of(context).size.width;


    return MaterialApp(
      title: 'EcoDrive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.colorMain),
        scaffoldBackgroundColor: AppColors.colorWhite,
      ),
      home: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndShowTerms(context);
          });
          return HomePage();
        }
      )
    );
  }
}

