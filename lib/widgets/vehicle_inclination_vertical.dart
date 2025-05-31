import 'package:flutter/material.dart';

class VehicleInclinationVertical extends StatelessWidget {
  final double angle; // Ângulo de inclinação em graus (positivo = subida, negativo = descida)
  final double threshold; // Limite para considerar plano, subida ou descida (ex: 3 graus)

  const VehicleInclinationVertical({
    Key? key,
    required this.angle,
    this.threshold = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Rotação da seta:
    // Quando está no plano, seta para a direita (0 radianos)
    // Quando sobe, rota entre 0 e -45 graus (seta apontando pra cima)
    // Quando desce, rota entre 0 e +45 graus (seta apontando pra baixo)
    double rotationRadians = 0;

    Color color;
    if (angle.abs() <= threshold) {
      // Plano: seta para a direita (0 rad)
      rotationRadians = 0;
      color = Colors.grey;
    } else if (angle > threshold) {
      // Subida: rotação entre 0 e -45 graus (negativo para girar para cima)
      final clampedAngle = (angle > 45) ? 45 : angle;
      rotationRadians = -clampedAngle * (3.14159265 / 180);
      color = Colors.green;
    } else {
      // Descida: rotação entre 0 e +45 graus (positivo para girar para baixo)
      final clampedAngle = (angle < -45) ? -45 : angle;
      rotationRadians = -clampedAngle * (3.14159265 / 180); // Negativo pois a seta aponta pra cima no 0° e deve rotacionar pra baixo
      color = Colors.red;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Transform.rotate(
              angle: rotationRadians,
              child: Icon(Icons.arrow_forward, size: 40, color: color),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          "${angle.toStringAsFixed(1)}°",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        )
      ],
    );
  }
}
