import 'package:ecoDrive/services/ble_service.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ecoDrive/pages/home_page.dart';
import 'package:ecoDrive/shared/app_settings.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    AppSettings.screenH = MediaQuery.of(context).size.height;
    AppSettings.screenW = MediaQuery.of(context).size.width;
    BleService.startMonitoringBluetoothStatus();
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

