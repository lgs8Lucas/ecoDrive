import 'package:ecoDrive/shared/app_settings.dart';
import 'package:ecoDrive/widgets/trip_list.dart';
import 'package:flutter/material.dart';
import 'package:ecoDrive/pages/viagemPage.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:ecoDrive/widgets/bluetooth_status_widget.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EcoDrive',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.colorMainText,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: AppColors.colorMain,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        color: AppColors.colorMainText,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 1),
            Text("Conexão com o ODB",
                style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.colorBlack,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 10),
            BluetoothStatusWidget(),
            SizedBox(height: 25),
            Text("Historico de Viagens",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  TripList(),
                  TripList(),
                  TripList(),
                  TripList(),
                  TripList(),
                  TripList(),
                  TripList(),
                  TripList(),
                  TripList(),
                  TripList(),
                  TripList(),
                ],
              ),
            )
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){},
        backgroundColor: AppColors.colorMain,
        foregroundColor: AppColors.colorMainText,
        label: Text('Iniciar Viagem'),
        icon: Icon(Icons.directions_car_rounded),
      ),
    );
  }
}