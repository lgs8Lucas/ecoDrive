import 'package:flutter/material.dart';

Future<void> confirmDialogWithInput({
  required BuildContext context,
  required String menssage,
  required Future<void> Function(String inputText) onConfirmed,
}) async {
  TextEditingController controller = TextEditingController();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Alterar nome da viagem:"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(menssage),
            SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Novo nome",
                labelStyle: TextStyle(color: Colors.blueGrey),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            )
          ],
        ),
        actions: <Widget>[
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
            ),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await onConfirmed(controller.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text("Salvar"),
          ),
        ],
      );
    },
  );
}


