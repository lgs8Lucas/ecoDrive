import 'package:ecoDrive/services/ble_service.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ecoDrive/pages/home_page.dart';
import 'package:ecoDrive/shared/app_settings.dart';
import 'settings.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main()  async  {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget{
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
      home: HomePage(),
    );
  }
}

