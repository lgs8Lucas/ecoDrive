import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class InclinationService {
  // StreamController para emitir o ângulo de inclinação em graus
  final StreamController<double> _inclinationController = StreamController<double>.broadcast();
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Getter para o stream do ângulo de inclinação
  Stream<double> get inclinationStream => _inclinationController.stream;

  // Inicia a leitura do acelerômetro
  void startListening() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final z = event.z; // Componente Z do acelerômetro
      const g = 9.8; // Gravidade aproximada

      // Calcula o ângulo de inclinação em graus
      final angle = asin((z / g).clamp(-1.0, 1.0)) * (180 / pi);

      // Emite o valor calculado no stream
      _inclinationController.add(angle);
    });
  }

  // Para a leitura do acelerômetro e fecha os recursos
  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

  // Dispose do controller
  void dispose() {
    stopListening();
    _inclinationController.close();
  }
}
