import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class RpmAccelerometer extends StatelessWidget {
  final double currentRpm; // RPM atual do veículo
  final double greenStart; // Início da faixa verde
  final double greenEnd; // Fim da faixa verde

  const RpmAccelerometer({
    super.key,
    required this.currentRpm,
    this.greenStart = 0,
    this.greenEnd = 3000,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 8000,
            interval: 1000,
            radiusFactor: 0.95, // reduz o raio do círculo
            axisLineStyle: AxisLineStyle(
              thickness: 12, // espessura menor
              color: Colors.grey.shade300,
            ),
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: greenStart,
                endValue: greenEnd,
                color: Colors.green,
                startWidth: 12,
                endWidth: 12,
              ),
              GaugeRange(
                startValue: greenEnd,
                endValue: 8000,
                color: Colors.red,
                startWidth: 12,
                endWidth: 12,
              ),
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                value: currentRpm.clamp(0, 8000),
                enableAnimation: true,
                needleColor: Colors.black,
                needleLength: 0.5,  // reduz o comprimento da agulha
                needleStartWidth: 2,
                needleEndWidth: 4,
                knobStyle: KnobStyle(
                  color: Colors.black,
                  sizeUnit: GaugeSizeUnit.factor,
                  knobRadius: 0.05, // knob menor
                ),
                tailStyle: TailStyle(
                  color: Colors.black,
                  width: 3,
                  length: 0.12,
                ),
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  '${currentRpm.toStringAsFixed(0)} RPM',
                  style: TextStyle(
                    fontSize: 14,  // fonte menor
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                positionFactor: 0.7,
                angle: 90,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
