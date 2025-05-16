import 'package:ecoDrive/shared/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:ecoDrive/pages/viagemPage.dart';
import 'package:ecoDrive/shared/app_colors.dart';
import 'package:ecoDrive/widgets/stream_builder.dart';

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
            Text(
              "Conexão com o ODB",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.colorBlack,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 10),
            Container( child: BluetoothStatusWidget()),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Historico de Viagens",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Expanded(
                child: Container(
                  height: 300,
                  child: listaHistorico(context),
              )
            ),
          ],
        ),
      ),
      floatingActionButton: btnIniciaViagem(),
    );
  }

  // Função para a lista de categorias
  Widget listaCategorias(){
    return Container(
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          categoriaItens(),
          categoriaItens(),
          categoriaItens(),
          categoriaItens(),
          categoriaItens(),
        ],
      ),
    );
  }

  // Função para os itens da lista de categorias
  Widget categoriaItens(){
    return Container(
      width: 70,
      height: 70,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          new BoxShadow(
            color: Colors.black12,
            offset: new Offset(1, 7.0),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(64),
      ),
      child: Image.asset("assets/relatorio.png"),
    );
  }
  
  // Função para a lista de corridas
  Widget listaHistorico(BuildContext context) {
    return Container(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          itemViagem(context),
          itemViagem(context),
          itemViagem(context),
          itemViagem(context),
          itemViagem(context),
          itemViagem(context),
        ],
      ),
    );
  }

  // Função para os itens do historico
  Widget itemViagem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViagemPage()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        height: 100,
        color: AppColors.colorAlterBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.calendar_today, color: AppColors.colorMain),
                SizedBox(width: 10),
                Text(
                  "Data da Viagem",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Icon(Icons.title, color: AppColors.colorMain),
                SizedBox(width: 10),
                Text(
                  "Título da Viagem",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget btnIniciaViagem(){
    return FloatingActionButton.extended(
      label: Text("Iniciar Viagem", style: TextStyle(
        color: AppColors.colorMainText,
      ),), onPressed: () {},
      backgroundColor: AppColors.colorMain,
      icon: Icon(Icons.directions_car, color:AppColors.colorMainText),



    );
  }
}