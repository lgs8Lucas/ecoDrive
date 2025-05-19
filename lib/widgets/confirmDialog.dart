import 'package:flutter/material.dart';

Future<void> confirmDialog({
  required BuildContext context,
  required String menssage,
  required VoidCallback function,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirmação"),
        content: Text(menssage),
        actions: <Widget>[
          OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: BorderSide(color: Colors.red),
          ),
          child: Text("Não"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o dialog
              function(); // Executa ação confirmada
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text("Sim"),
          ),
        ],
      );
    },
  );
}
