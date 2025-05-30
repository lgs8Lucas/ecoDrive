import 'package:flutter/material.dart';
import '../shared/app_colors.dart';
import '../widgets/bluetooth_status_widget.dart';
import '../widgets/faq_dialog.dart';
import '../widgets/start_viagem.dart';
import '../widgets/trip_list.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Widget>> _historicoFuture;

  @override
  void initState() {
    super.initState();
    _loadHistorico();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistorico(); // Recarrega o histórico sempre que a página for reconstruída
  }

  void _loadHistorico() {
    setState(() {
      _historicoFuture = listarHistorico(context);
    });
  }

  void _showFAQ(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => const FAQDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EcoDrive',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.colorMain,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () => _showFAQ(context),
            tooltip: 'Ajuda',
          ),
        ],
        backgroundColor: AppColors.colorWhite,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.colorWhite,
        ),
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
            BluetoothStatusWidget(),
            SizedBox(height: 25),
            Text(
              "Historico de Viagens",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Widget>>(
                future: _historicoFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final historicoWidgets = snapshot.data ?? [];

                  return ListView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    children: [
                      ...historicoWidgets,
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final combustivel = await iniciarViagem(
            context: context,
            menssage: 'Informe o tipo de combustivel que está utilizando?',
          );
        },
        backgroundColor: AppColors.colorMain,
        foregroundColor: AppColors.colorMainText,
        label: Text('Iniciar Viagem'),
        icon: Icon(Icons.directions_car_rounded),
      ),
    );
  }
}
