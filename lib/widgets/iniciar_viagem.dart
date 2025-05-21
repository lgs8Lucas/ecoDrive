import 'package:flutter/material.dart';
import 'package:ecoDrive/pages/eco_drive_page.dart';

Future<String?> iniciarViagem({
  required BuildContext context,
  required String menssage,
}) async {
  String selectedFuel = 'Gasolina';

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Tipo de Combustivel"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menssage),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text("Combustível: "),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedFuel,
                      items: <String>['Gasolina', 'Etanol', 'Diesel']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedFuel = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(null); // Cancela
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red, // Cor do texto
                  side: const BorderSide(color: Colors.red), // Cor da borda
                ),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const EcoDrivePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,     // Cor de fundo
                  foregroundColor: Colors.white,     // Cor do texto
                ),
                child: const Text("Iniciar"),
              ),
            ],
          );
        },
      );
    },
  );
}

