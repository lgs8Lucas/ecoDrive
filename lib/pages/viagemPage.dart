import 'package:flutter/material.dart';

class ViagemPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.green,
        child: Center(
          child: Text("Relatorio da Viagem"),
       ),
      ),
    );
  }
}